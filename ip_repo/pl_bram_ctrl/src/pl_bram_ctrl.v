`timescale 1ns / 1ps
module pl_bram_ctrl#(
    parameter CHANNEL_NUM=1
)(
    //ps配置
    output o_pl2ps_done_pulse,//完成一次传输的标志位
    input [31:0]i_data_len,//采样的数据点数
    // input i_clear_done_flag_pulse,//清楚标志位
    input i_start_pulse,

    input clk,
    input rst,
    //地址
    input [31:0]i_start_addr,
    //数据通道
    input [31:0]i_channel_sel,
    input [15:0]i_data,
    input i_valid,
    input [15:0]i_data1,
    input i_valid1,
    input [15:0]i_data2,
    input i_valid2,
    input [15:0]i_data3,
    input i_valid3,

    //bram控制总线
    output reg[31:0]o_addr,
    output o_clk,
    input [31:0]i_rdata,
    output reg[31:0]o_wdata,
    output reg o_en,
    output o_rst,
    output [3:0]o_we
    );

localparam IDLE=1<<0,WAIT_START=1<<1,WRITE_RAM=1<<2,WRITE_END=1<<3;
reg [3:0]state=IDLE,state_o;
reg r_valid;
reg [31:0]r_data;
reg sel=0;
//通道选择器输出的数据
wire o_valid;
wire [15:0]o_data;
assign o_clk=clk;
assign o_rst=rst;
assign o_we=4'b1111;
assign o_pl2ps_done_pulse = (state==IDLE) & (state_o==WRITE_RAM);
always @(posedge clk) begin
    if(o_valid)begin
        case(sel)
            0:begin r_data[0 +:16]<=o_data; sel<=1; end
            1:begin r_data[16 +:16]<=o_data; sel<=0; end 
        endcase
    end
    r_valid<=(o_valid & sel==1);
end
always @(posedge clk) begin
    state_o<=state;
end
always @(posedge clk) begin
    if(rst)begin
        o_addr<=0;
        o_wdata<=0;
        o_en<=0;
        state<=IDLE;
        // o_pl2ps_done_flag<=0;
    end
    else begin
        case (state)
            IDLE :begin
                if(i_start_pulse)begin
                    state<=WAIT_START;
                end
            end 
            WAIT_START:begin
                if(r_valid)begin
                    state<=WRITE_RAM;
                    o_en<=1;
                    o_wdata<=r_data;
                    o_addr<=i_start_addr;
                end
            end
            WRITE_RAM:begin
                if(r_valid)begin
                    if ((o_addr - i_start_addr) >= (i_data_len<<1) - 4)begin
                        state<=IDLE;
                        o_en<=0;
                        o_wdata<=0;
                        o_addr<=0;
                    end
                    else begin
                        o_addr<=o_addr+4;
                        o_wdata<=r_data;
                    end
                end
            end
            // WRITE_END:begin
            //     if(i_clear_done_flag_pulse)begin
            //         state<=IDLE;
            //         o_pl2ps_done_flag<=0;
            //     end
            //     else o_pl2ps_done_flag<=1;
            // end
            default: state <= IDLE ;
        endcase
    end
end
//例化通道选择器
channel_sel u_channel_sel (
    .clk          (clk),          // 输入时钟
    .i_channel_sel(i_channel_sel),// 32 位通道选择信号
    .i_data       (i_data),       // 通道 0 的 16 位输入数据
    .i_valid      (i_valid),      // 通道 0 的有效标志
    .i_data1      (i_data1),      // 通道 1 的 16 位输入数据
    .i_valid1     (i_valid1),     // 通道 1 的有效标志
    .i_data2      (i_data2),      // 通道 2 的 16 位输入数据
    .i_valid2     (i_valid2),     // 通道 2 的有效标志
    .i_data3      (i_data3),      // 通道 3 的 16 位输入数据
    .i_valid3     (i_valid3),     // 通道 3 的有效标志
    .o_data       (o_data),       // 输出数据
    .o_valid      (o_valid)       // 输出有效标志
);

endmodule
