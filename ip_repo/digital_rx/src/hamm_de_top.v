//汉明码解码模块
//负责串并转换，计数，解码输出
`timescale 1ns / 1ps
module hamm_de_top (
    input clk,
    input rst,
    input i_ds_valid,
    input i_ds_data,
    input i_sync_valid_pulse,//这是帧同步完成脉冲
    output [7:0]o_de_data,
    output o_de_valid,
    output o_error_pulse ,//误码数过高，无法纠错时产生
    output reg [31:0]o_data_num   //一帧总数输出，32位对齐ps总线
);
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1
localparam DE_NUM = 'd1 << 1; // 解码第一个字节，得到一帧的总数
localparam DE_DATA = 'd1 << 2; // 解码后续数据
reg [7:0]state=IDLE,r_state;
//i_ds_valid
reg r_ds_valid;//时序配合
//串并转换
reg [11:0]r12_shift;
reg [$clog2(12)-1:0]shift_cnt,r_shift_cnt;
//解码帧字节数
reg [9:0]de_cnt;
//汉明解码
reg r_de_en=0;
reg [11:0]r_de_data_i;
wire [7:0]w_de_data_o;
wire w_de_valid;
//o_data_num,直接输出给ps端用
always @(posedge clk ) begin
    if(rst)o_data_num<=0;
    else if(state==DE_NUM)
        o_data_num<= (o_de_valid) ? o_de_data : o_data_num;
end
//r_ds_valid,时序配合
always @(posedge clk ) begin
    r_ds_valid<=i_ds_valid;
end
//de_cnt
always @(posedge clk ) begin
    if(rst) de_cnt<=0;
    else begin
        case (state)
            DE_NUM: de_cnt<= (o_de_valid) ? ({o_de_data,2'b00}) : 0;
            DE_DATA: if(o_de_valid) de_cnt<= (de_cnt==0) ? 0 : (de_cnt-1);
            default: de_cnt<=0;
        endcase
    end
end
//r_de_en,r_de_data_i
always @(posedge clk ) begin
    if(rst)begin
        r_de_en<=0;
        r_de_data_i<=0;
    end
    else if(state!=IDLE)begin
        r_de_en<=(r_shift_cnt==12-1 & r_ds_valid);
        r_de_data_i<=(r_shift_cnt==12-1 & r_ds_valid) ? r12_shift : r_de_data_i;
    end
end
//r12_shift
always @(posedge clk ) begin
    if(rst) r12_shift<=0;
    else if(state!=IDLE)begin
        r12_shift<=(i_ds_valid) ? ({i_ds_data,r12_shift[11:1]}) : r12_shift;
    end
    else r12_shift<=0;
end
//shift_cnt
always @(posedge clk ) begin
    if(rst) shift_cnt<=0;
    else if(state!=IDLE)begin
        if(i_ds_valid)
            shift_cnt<= (shift_cnt==12-1) ? 0 : (shift_cnt+1);
    end
    else shift_cnt<=0;
end
//r_shift_cnt
always @(posedge clk ) begin
    if(rst) r_shift_cnt<=0;
    else r_shift_cnt<=i_ds_valid ? shift_cnt : r_shift_cnt;
end
//state,r_state
always @(posedge clk ) begin
    if(rst)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE: state<=(i_sync_valid_pulse) ? DE_NUM : state;
            DE_NUM: state<=(o_de_valid) ? DE_DATA : state;
            DE_DATA: state<=(de_cnt==0) ? IDLE : state;
            default:state<=IDLE; 
        endcase
    end
    r_state<=state;
end
hamming_decoder hamming_decoder_inst (
    .clk(clk),
    .rden(r_de_en),
    .q(o_de_data),
    .decode_valid(o_de_valid),
    .hc_in(r_de_data_i),
    .error_pulse(o_error_pulse)
);
endmodule