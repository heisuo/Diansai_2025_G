`timescale 1ns / 1ps
//为了达到FFT计算的时序要求，使用两个fifo来把数据组合到一起给FFT模块使用
module fifo#(
    parameter FFT_POINT = 1024
)(
    input clk,
    input rst,
    input [7:0]i_mode,
    input i_start_FFT_pulse,
    input i_valid,
    input [13:0]i_data1,
    input [13:0]i_data2,
    output o_FFT_valid,
    output [13:0]o_FFT_data1,
    output [13:0]o_FFT_data2,
    input i_IFFT_valid,
    input [15:0]i_IFFT_data,
    output o_valid,
    output [15:0]o_data
    );
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1
localparam WRITE = 'd1 << 1;//写入数据
localparam READ = 'd1 << 2;//读取数据
reg [7:0]state=IDLE,r_state;

reg [13:0]fifo_din,fifo2_din;
reg fifo_wr_en,fifo_rd_en;
reg [$clog2(FFT_POINT)-1:0]wr_cnt,rd_cnt;
wire fifo16_valid;
assign o_FFT_valid=fifo_rd_en;
assign o_valid=(fifo16_valid & i_valid);
//fifo_rd_en
always @(posedge clk ) begin
    if(state==READ)begin
        rd_cnt<= (rd_cnt==FFT_POINT-1) ? 0 : (rd_cnt+1);
        fifo_rd_en<=1;
    end
    else begin
        rd_cnt<=0;
        fifo_rd_en<=0;
    end
end
//fifo_din,fifo_wr_en,fifo2_din
always @(posedge clk ) begin
    case (state)
        READ,WRITE:begin
            if(i_valid) begin 
                wr_cnt<= (wr_cnt==FFT_POINT-1) ? 0 : (wr_cnt+1);
            end
            fifo_wr_en<=i_valid;
            fifo_din<=i_data1;
            fifo2_din<=i_data2;
        end
        default:begin
            fifo_din<=0;
            fifo_wr_en<=0;
            fifo2_din<=0;
            wr_cnt<=0;
        end 
    endcase
end
always @(posedge clk ) begin
    if(rst) state<=IDLE;
    else begin
        case (state)
            IDLE:begin
                if(i_start_FFT_pulse | i_mode==4)
                    state<=WRITE; 
            end 
            WRITE : state <= (i_valid & (wr_cnt==FFT_POINT-1)) ? READ : state;
            READ: begin 
                if((rd_cnt==FFT_POINT-1) & i_mode==4)begin
                    state<=WRITE;
                end
                else if((rd_cnt==FFT_POINT-1) & i_mode!=4)begin
                    state<=IDLE;
                end
            end
            default: state<=IDLE;
        endcase
    end
    r_state<=state;
end

fifo_14 i_fifo_1 (
  .clk(clk),      // input wire clk
  .srst(rst | (state==IDLE & r_state==READ)),    // input wire srst
  .din(fifo_din),      // input wire [13 : 0] din
  .wr_en(fifo_wr_en),  // input wire wr_en
  .rd_en(fifo_rd_en),  // input wire rd_en
  .dout(o_FFT_data1)    // output wire [13 : 0] dout
);
fifo_14 i_fifo_2 (
  .clk(clk),      // input wire clk
  .srst(rst | (state==IDLE & r_state==READ)),    // input wire srst
  .din(fifo2_din),      // input wire [13 : 0] din
  .wr_en(fifo_wr_en),  // input wire wr_en
  .rd_en(fifo_rd_en),  // input wire rd_en
  .dout(o_FFT_data2)    // output wire [13 : 0] dout
);

fifo_16 fifo_16 (
  .clk(clk),      // input wire clk
  .srst(rst),    // input wire srst
  .din(i_IFFT_data),      // input wire [15 : 0] din
  .wr_en(i_IFFT_valid),  // input wire wr_en
  .rd_en((fifo16_valid & i_valid)),  // input wire rd_en
  .valid(fifo16_valid),
  .dout(o_data)    // output wire [15 : 0] dout
);
endmodule
