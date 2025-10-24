//帧同步模块
//负责检测帧头和极性
`timescale 1ns / 1ps
module FrameSync (
    input clk,
    input rst,
    input i_rx_start_pulse,//开始接收脉冲
    input i_bit_valid,
    input i_bit_data,//判决得到的bit数据
    input i_rx_end_pulse,
    output o_sync_valid_pulse,
    output reg o_bit_data,
    output reg o_bit_valid
);
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1 
localparam SEARCH = 'd1 << 1; // 搜索态, 'h1  
localparam SYNC = 'd1 << 2; // 同步态
reg [7:0]state=SEARCH,r_state;

wire [6:0]FrameCode=7'b1110010;//帧同步码1110010
reg [6:0]r_frame;//帧头寄存
reg [1:0]r_jixin;//01表示正极性抓帧和10表示负极性抓帧，0表示没抓到
assign o_sync_valid_pulse = (state==SYNC) & (r_state==SEARCH);
//o_bit_data,o_bit_valid
always @(posedge clk ) begin
    case (r_jixin)
        2'b01: begin 
            o_bit_data<=i_bit_valid ? i_bit_data : o_bit_data; 
            o_bit_valid<=i_bit_valid; 
        end
        2'b10: begin 
            o_bit_data<=i_bit_valid ? (~i_bit_data) : o_bit_data; 
            o_bit_valid<=i_bit_valid;
        end
        default:begin
            o_bit_data<=0; 
            o_bit_valid<=0; 
        end
    endcase
end

//r_jixin
always @(posedge clk ) begin
    if(state==SEARCH)begin
        case (r_frame)
            7'b1110010: r_jixin<=2'b01;
            ~7'b1110010: r_jixin<=2'b10;
            default: r_jixin<=0;
        endcase
    end
    else if(i_rx_end_pulse)begin
        r_jixin<=0;
    end
end
//r_frame
always @(posedge clk ) begin
    if(rst) r_frame<=0;
    else if(state==SEARCH)begin
        r_frame<=(i_bit_valid) ? ({r_frame[5:0],i_bit_data}) : r_frame;
    end
    else r_frame<=0;
end
//state,r_state
always @(posedge clk ) begin
    if(rst)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE: state<= i_rx_start_pulse ? SEARCH : state;
            SEARCH: state<=(r_jixin!=0) ? SYNC : state;
            SYNC: state<=(i_rx_end_pulse) ? SEARCH : state;
            default:state<=IDLE; 
        endcase
    end
    r_state<=state;
end

endmodule