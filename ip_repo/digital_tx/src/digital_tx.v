`timescale 1ns / 1ps
module digital_tx(
    input clk,
    input rst,
    input [31:0]i_tx_FTW,
    input i_valid,//IP核传来的数据有效脉冲
    input [31:0]i_data,//IP核数据
    input [31:0]i_data_num,//32位数据个数，低8位有效
    input i_tx_start,//开始传输脉冲
    output o_tx_data,
    output o_tx_valid,   //输出时应该是一直置1
    output o_tx_end_pulse //发射结束脉冲
    ); 
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1  
localparam ENCODE = 'd1 << 1; // 编码状态, 'h2  
localparam DONE = 'd1 << 2; // 结束态, 'h4  
reg [7:0]state=IDLE,r_state;
reg [9:0]r_data_cnt=0;//数据计数器
reg rd_en;//fifo读使能
wire [7:0]w_fifo_rd_data;//fifo读出的数据
wire [7:0]w_data_num;//待读数据
//汉明码编码
reg [7:0]r_hanmming_i;
reg r_hanmming_en;
wire [11:0]w_hamming_o;//汉明编码输出数据
wire w_encode_valid;//汉明码编码有效
//组帧
wire w_fifo_12_empty,w_fifo_12_rd_en,w_fifo_12_valid;
wire [11:0]w_fifo_12_data;
wire w_frame_tx,w_frame_valid;
//加扰
wire w_scrambler_valid,w_scrambler_data;
assign w_data_num=i_data_num[0 +:8];
assign o_tx_valid=o_div_valid;
//r_hanmming_i,r_hanmming_en
always @(posedge clk ) begin
    if(state==IDLE & i_tx_start)begin
        r_hanmming_i<=w_data_num;
        r_hanmming_en<=1;
    end
    else begin
        r_hanmming_i<=w_fifo_rd_data;
        r_hanmming_en<=rd_en;
    end
end
//state
always @(posedge clk ) begin
    if(rst)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE:state<= i_tx_start ? ENCODE : state;
            ENCODE:state<= (r_data_cnt>={w_data_num,2'b00}) ? IDLE : state;
            default: state<=IDLE;
        endcase
    end
end
//rd_en
always @(posedge clk ) begin
    if(rst) rd_en<=0;
    else if(state==ENCODE)begin
        if(r_data_cnt>={w_data_num,2'b00})begin
            rd_en<=0;
        end
        else rd_en<=1;
    end
    else rd_en<=0;
end
//r_data_cnt
always @(posedge clk ) begin
    if(rst) r_data_cnt<=0;
    else if(state==ENCODE)begin
        r_data_cnt<=(r_data_cnt>={w_data_num,2'b00}) ? 0 : (r_data_cnt+1'b1);
    end
    else r_data_cnt<=0;
end
//r_state
always @(posedge clk ) begin
    r_state<=state;
end
fifo_32_8 fifo_32_8 (
  .clk(clk),      // input wire clk
  .srst((rst | o_tx_end_pulse)),    // input wire srst
  .din(i_data),      // input wire [31 : 0] din
  .wr_en(i_valid),  // input wire wr_en
  .rd_en(rd_en),  // input wire rd_en
  .dout(w_fifo_rd_data)    // output wire [7 : 0] dout
);
//汉明码编码
hamming_encoder encoder_inst (
    .clk(clk),           // 时钟信号
    .rst(rst),      // 复位信号
    .wren(r_hanmming_en),        // 写使能信号
    .data(r_hanmming_i),        // 输入数据
    .hc_out(w_hamming_o),     // 校验输出
    .encode_valid(w_encode_valid)
);
fifo_12_12 fifo_12_12 (
  .clk(clk),      // input wire clk
  .srst((rst | o_tx_end_pulse)),    // input wire srst
  .din(w_hamming_o),      // input wire [11 : 0] din
  .wr_en(w_encode_valid),  // input wire wr_en
  .rd_en(w_fifo_12_rd_en),  // input wire rd_en
  .dout(w_fifo_12_data),    // output wire [11 : 0] dout
  .empty(w_fifo_12_empty),
  .valid(w_fifo_12_valid)  // output wire valid
);
// 组帧模块
Framing framing_inst (
    // 输入端口
    .clk(clk),                // 系统时钟
    .rst(rst),                // 系统复位（高有效）
    .i_start_pulse(i_tx_start), // 开始发送帧的脉冲信号
    .i_fifo_valid(w_fifo_12_valid), // FIFO数据有效信号
    .i_byte_num({w_data_num,2'd0}), // FIFO空标志
    .i_fifo_data(w_fifo_12_data),   // 12位FIFO数据输入
    // 输出端口
    .o_rd_fifo_en(w_fifo_12_rd_en), // FIFO读取使能（从FIFO读取下一个数据）
    .o_framing_valid(w_frame_valid), // 帧输出有效信号（当输出帧数据时置高）
    .o_framing_tx(w_frame_tx)  // 单bit串行帧数据输出
);
// 加扰模块
scrambler scrambler_inst (
    // 系统信号
    .clk(clk),              // 输入：系统时钟（通常大于串行数据速率）
    .rst(rst),              // 输入：复位信号（高有效）
    
    // 数据输入接口
    .i_bit_valid(w_frame_valid),  // 输入：比特数据有效标志
    .i_bit_data(w_frame_tx),    // 输入：待加扰数据比特（MSB first/LSB first取决于系统）
    
    // 加扰输出接口
    .o_scrambler_valid(w_scrambler_valid), // 输出：加扰后数据有效标志
    .o_scrambler_data(w_scrambler_data)     // 输出：加扰后的数据比特
);
wire w_fifo1_valid;
wire w_fifo1_dout;
wire w_fifo1_rd_en;
fifo_1_1 fifo_1_1 (
  .clk(clk),      // input wire clk
  .srst((rst | o_tx_end_pulse)),    // input wire srst
  .din(w_scrambler_data),      // input wire [0 : 0] din
  .wr_en(w_scrambler_valid),  // input wire wr_en
  .rd_en(w_fifo1_rd_en),  // input wire rd_en
  .dout(w_fifo1_dout),    // output wire [0 : 0] dout
  .valid(w_fifo1_valid)  // output wire valid
);
// 模块例化
F_div f_div_inst (
    // 系统信号
    .clk(clk),           // 输入：主时钟
    .rst(rst),           // 输入：复位信号（高有效）
    .i_sample_FTW(i_tx_FTW),
    // 数据输入接口
    .i_fifo_valid(w_fifo1_valid),  // 输入：FIFO数据有效标志
    .i_bit_data(w_fifo1_dout),      // 输入：待处理比特数据
    .o_fifo_rd_en(w_fifo1_rd_en),
    // 分频输出接口
    .o_div_valid(o_div_valid),   // 输出：分频后数据有效标志
    .o_div_data(o_tx_data),      // 输出：分频后的数据
    .o_tx_end_pulse(o_tx_end_pulse)
);
endmodule
