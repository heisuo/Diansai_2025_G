`timescale 1ns / 1ps
module digital_rx (
    input clk,
    input rst,
    input i_rx_start_pulse,//开始接收脉冲
    input i_bit_valid,
    input i_bit_data,//判决得到的bit数据
    output o_error_pulse,//解码失败时产生脉冲，表示丢帧
    output [31:0]o_data_num,//数据段第一个字节，表示接收到的数据总量
    input i_rx_rd_pulse,//接收到的数据读取使能
    output [31:0]o_rx_data,
    output o_rx_end_pulse//接收结束脉冲
);
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1
localparam WORK = 'd1 << 1; // 工作状态
reg [7:0]state=IDLE,r_state;
// 帧同步与极性判定
wire w_sync_valid_pulse,w_sync_bit_valid,w_sync_bit_data;
// 解扰器
wire w_ds_data;
wire w_ds_valid;
// 汉明解码
wire [7:0]w_de_data;
wire w_de_valid;
//解码后数据分割，然后进fifo
wire w_rx_end_pulse;
reg [9:0]rx_cnt;
reg [7:0]r_fifo_i;
reg r_fifo_wr_en;
assign w_rx_end_pulse=(state==IDLE & r_state==WORK);
assign o_rx_end_pulse=w_rx_end_pulse;
// 帧同步与极性判定
FrameSync frame_sync_inst (
    // 系统信号
    .clk(clk),           // 输入：系统时钟
    .rst((rst | o_error_pulse)),           // 输入：复位信号（高有效）
    .i_rx_start_pulse(i_rx_start_pulse),
    // 数据输入接口
    .i_bit_valid(i_bit_valid),  // 输入：比特数据有效标志
    .i_bit_data(i_bit_data),    // 输入：串行比特数据
    // 控制信号
    .i_rx_end_pulse(w_rx_end_pulse), // 输入：接收结束脉冲（高有效）
    // 帧同步输出接口
    .o_sync_valid_pulse(w_sync_valid_pulse),//进入帧同步后的脉冲
    .o_bit_valid(w_sync_bit_valid), // 输出：帧同步后数据有效标志
    .o_bit_data(w_sync_bit_data)    // 输出：帧同步后的比特数据
);

// 解扰器
descrambler descrambler_inst (
    .clk(clk),
    .rst((rst | o_error_pulse)),
    .i_sync_valid(w_sync_bit_valid),        // 帧同步数据有效
    .i_sync_data(w_sync_bit_data),          // 帧同步数据
    .i_sync_valid_pulse(w_sync_valid_pulse), // 帧同步完成脉冲
    .i_rx_end_pulse(w_rx_end_pulse),    // 接收结束脉冲
    .o_ds_data(w_ds_data),             // 解扰后的数据
    .o_ds_valid(w_ds_valid)             // 解扰数据有效信号
);
// 汉明解码
hamm_de_top hamm_de_inst (
    // 系统信号
    .clk(clk), 
    .rst((rst | o_error_pulse)),
    // 输入接口
    .i_ds_valid(w_ds_valid),         // 解扰数据有效标志
    .i_ds_data(w_ds_data),           // 解扰数据输入
    .i_sync_valid_pulse(w_sync_valid_pulse), // 帧同步完成脉冲
    // 输出接口
    .o_de_data(w_de_data),           // 解码后数据输出（8位）
    .o_de_valid(w_de_valid),         // 解码数据有效标志
    .o_error_pulse(o_error_pulse),
    .o_data_num(o_data_num)
);
//解码后数据分割，然后进fifo
always @(posedge clk ) begin
    if(rst | o_error_pulse)begin
        rx_cnt<=0;
    end
    else if(state==WORK)begin
        if(w_de_valid)
            rx_cnt<=(rx_cnt=={o_data_num[7:0],2'b00}-1) ? 0 : (rx_cnt+1);
    end
    else rx_cnt<=0;
end
always @(posedge clk ) begin
    if(rst | o_error_pulse)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE:state<= w_de_valid ? WORK : state;//数据段第一个字节不要
            WORK:state<= ((rx_cnt=={o_data_num[7:0],2'b00}-1) & w_de_valid) ? IDLE : state;
            default: state<=IDLE;
        endcase
    end
    r_state<=state;
end
always @(posedge clk ) begin
    if(state==WORK)begin
        r_fifo_i<=w_de_valid ? w_de_data : r_fifo_i;
        r_fifo_wr_en<=w_de_valid;
    end
    else begin
        r_fifo_i<=0;
        r_fifo_wr_en<=0;
    end
end
fifo_8_32 fifo_8_32 (
  .clk(clk),      // input wire clk
  .srst((rst | i_rx_start_pulse | o_error_pulse)),    // input wire srst
  .din(r_fifo_i),      // input wire [7 : 0] din
  .wr_en(r_fifo_wr_en),  // input wire wr_en
  .rd_en(i_rx_rd_pulse),  // input wire rd_en
  .dout(o_rx_data)    // output wire [31 : 0] dout
);//i_rx_start_pulse会复位fifo,在重新开始接收前要先读取完所有数据
endmodule