`timescale 1ns / 1ps
//组帧
//负责并串转换和组帧
module Framing(
    input clk,
    input rst,
    //开始
    input i_start_pulse,
    input i_fifo_valid,
    input [9:0]i_byte_num,
    input [11:0]i_fifo_data,
    output o_rd_fifo_en,//fifo读取使能
    output reg o_framing_valid,//帧输出有效
    output reg o_framing_tx//单bit输出
    );
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1  
localparam WAIT = 'd1 << 1; // 等待fifo数据有效
localparam FRAME_TX = 'd1 << 2; //发送帧头  
localparam DATA_TX = 'd1 << 3; // 发送数据  
reg [7:0]state=IDLE,r_state;
//帧发送
reg [$clog2(7)-1:0]r_Frame_cnt;
reg [$clog2(12)-1:0]r_data_cnt;
reg [$clog2(128)-1:0]r_byte_cnt;
wire [6:0]FrameCode=7'b0100111;//帧同步码1110010,因为从低到高输出，要反过来
//o_rd_fifo_en
assign o_rd_fifo_en = (r_data_cnt==12-1) & (state==DATA_TX);
//r_byte_cnt
always @(posedge clk ) begin
    if(rst)begin
        r_byte_cnt<=0;
    end
    else if(state==DATA_TX )begin
        if((r_data_cnt==12-1))
            r_byte_cnt<=(r_byte_cnt==i_byte_num) ? 0 : (r_byte_cnt+1);
    end
    else r_byte_cnt<=0;
end
//r_data_cnt
always @(posedge clk ) begin
    if(rst)begin
        r_data_cnt<=0;
    end
    else if(state==DATA_TX)begin
        r_data_cnt<=(r_data_cnt==12-1) ? 0 : (r_data_cnt+1);
    end
    else r_data_cnt<=0;
end
//r_Frame_cnt
always @(posedge clk ) begin
    if(rst)begin
        r_Frame_cnt<=0;
    end
    else if(state==FRAME_TX)begin
        r_Frame_cnt<=(r_Frame_cnt==7-1) ? 0 : (r_Frame_cnt+1);
    end
    else r_Frame_cnt<=0;
end

//o_framing_tx,o_framing_valid
always @(posedge clk ) begin
    case (state)
        FRAME_TX :  begin
            o_framing_tx<=FrameCode[r_Frame_cnt];
            o_framing_valid<=1;
        end
        DATA_TX:begin
            o_framing_tx<=i_fifo_data[r_data_cnt];
            o_framing_valid<=1;
        end
        default: begin o_framing_tx<=0;o_framing_valid<=0;end
    endcase
end
//state
always @(posedge clk ) begin
    if(rst)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE:state<= i_start_pulse ? WAIT : state; 
            WAIT:state<= i_fifo_valid ? FRAME_TX : state;
            FRAME_TX:state<= (r_Frame_cnt==7-1) ? DATA_TX : state;
            DATA_TX:state<= ((r_byte_cnt==i_byte_num) & (r_data_cnt==12-1)) ? IDLE : state;
            default: state<=IDLE;
        endcase
    end
end

endmodule
