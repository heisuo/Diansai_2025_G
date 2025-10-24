`timescale 1ns / 1ps
module Gardner(
    input clk,
    input rst,
    output o_debug_sync,
    output [15:0]o_debug_u,
    output [15:0]o_debug_e,
    output [15:0]o_debug_w,
    input [31:0]i_sample_FTW,
    input [15:0]i_data,
    output [17:0]o_data,
    output reg o_valid
    );
(* ASYNC_REG = "TRUE" *)reg r_sync;
(* ASYNC_REG = "TRUE" *)reg [17:0]o_data;

wire [15:0]o_debug_u,o_debug_e,o_debug_w;
wire o_debug_sync;
wire w_gardner_clk;
wire w_gardner_clk_bufg;
wire w_sync;//位同步脉冲
wire [15:0]w_sample_data;
wire [17:0]yi;//18位有符号内插输出，还在gardner时钟域内
assign o_debug_sync=r_sync;
//抓sync上升沿
always @(posedge clk ) begin
    r_sync<=w_sync;
    if(w_sync & (!r_sync))begin
        o_data<=yi;
    end
    o_valid<=w_sync & (!r_sync);
end

BUFG BUFG_inst (
      .O(w_gardner_clk_bufg), // 1-bit output: Clock output.
      .I(w_gardner_clk)  // 1-bit input: Clock input.
);

// 模块例化
data_sample sampler_inst (
    // 输入
    .clk(clk),             // 系统主时钟（高采样率）
    .rst(rst),             // 复位信号
    .i_sample_FTW(i_sample_FTW), // 4倍符号速率相位步进值
    .i_data(i_data),       // 原始输入数据
    
    // 输出
    .o_garder_clk(w_gardner_clk), // Gardner模块时钟（4倍符号速率）
    .o_sample_data(w_sample_data) // 4倍符号速率的数据
);

FpgaGardner gardner_inst (
    // 输入
    .rst(rst),             // 复位信号
    .clk(w_gardner_clk_bufg),             // 4 MHz时钟
    .di(w_sample_data),               // 16位有符号输入数据
    
    // 输出
    .yi(yi),               // 18位有符号内插输出
    .u(o_debug_u),                 // 16位有符号内插间隔
    .e(o_debug_e),                 // 16位有符号定时误差
    .w(o_debug_w),                 // 16位有符号环路滤波输出
    .sync(w_sync)            // 位同步脉冲
);

endmodule
