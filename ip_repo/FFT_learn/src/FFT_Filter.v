`timescale 1ns / 1ps
//完成两个步骤，旋转和缩放
module FFT_Filter#(
    parameter FFT_POINT = 8192,
    parameter FFT_OUT_WIDTH=28,
    parameter jiewei=0,
    parameter ADDR_WIDTH=14
)(
    input clk,
    input rst,
    //参数
    input [31:0]i_FFT_zoom_data,
    input [31:0]i_FFT_phase_sin,
    input [31:0]i_FFT_phase_cos,
    input [31:0]i_FFT_wr_addr,
    input i_FFT_ram_wea,
    input [31:0]i_mode,
    //数据流
    input [63:0]i_flow_FFT_data,
    input i_flow_FFT_valid,
    input i_flow_FFT_last,
    output [31:0]o_FFT_Filter_data,
    output o_FFT_Filter_valid,
    output o_FFT_Filter_last
    );
wire [7:0]w_mode=i_mode[7:0];
wire signed [15:0]w_FFT_I_data,w_FFT_Q_data;
//读取的sin和cos值
wire [15:0]w_phase_sin,w_phase_cos;//-1~1
wire [31:0]w_zoom_data;//0~15位是小数位，高位都是整数位
wire [ADDR_WIDTH-1:0]w_ram_rotate_addr;//旋转ram地址
wire [ADDR_WIDTH-1:0]o_ram_rotate_addr;
wire [ADDR_WIDTH-1:0]w_ram_zoom_addr;//缩放ram地址
wire [ADDR_WIDTH-1:0]o_ram_zoom_addr;
//rotate
//旋转后IQ两路数据
wire [15:0]w_rotate_I_data,w_rotate_Q_data;
wire w_rotate_valid,w_rotate_last;
//zoom
wire [15:0]w_zoom_I_data,w_zoom_Q_data;
wire w_zoom_valid,w_zoom_last;
//o_FFT_Filter_data,o_FFT_Filter_valid,o_FFT_Filter_last
assign o_FFT_Filter_data={w_zoom_Q_data,w_zoom_I_data};
assign o_FFT_Filter_valid=w_zoom_valid;
assign o_FFT_Filter_last=w_zoom_last;
assign w_FFT_I_data=i_flow_FFT_data[(FFT_OUT_WIDTH-1-jiewei) -:16];
assign w_FFT_Q_data=i_flow_FFT_data[(32+FFT_OUT_WIDTH-1-jiewei) -:16];
//旋转ram地址选择
assign w_ram_rotate_addr = i_FFT_ram_wea ? i_FFT_wr_addr[ADDR_WIDTH-1:0] : o_ram_rotate_addr;
//缩放ram地址选择
assign w_ram_zoom_addr = i_FFT_ram_wea ? i_FFT_wr_addr[ADDR_WIDTH-1:0] : o_ram_zoom_addr;
// rotate
rotate #(
    .FFT_POINT(FFT_POINT),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_rotate (
    // 时钟和复位
    .clk               (clk),         // 输入时钟 (建议 >2×数据速率)
    .rst               (rst),          // 复位信号 (高/低有效需根据设计确定)
    // 控制信号
    .i_mode            (w_mode),    // 工作模式 [7:0]
    .i_phase_sin       (w_phase_sin),  // 旋转角度正弦值 signed[15:0]
    .i_phase_cos       (w_phase_cos),  // 旋转角度余弦值 signed[15:0]
    // FFT输入数据
    .i_FFT_I_data      (w_FFT_I_data),        // FFT I路输入 signed[15:0]
    .i_FFT_Q_data      (w_FFT_Q_data),        // FFT Q路输入 signed[15:0]
    .i_FFT_valid       (i_flow_FFT_valid),    // FFT数据有效信号
    .i_FFT_last        (i_flow_FFT_last),     // FFT帧结束信号
    // 旋转结果输出
    .o_ram_rotate_addr (o_ram_rotate_addr),  // 旋转后RAM地址 [13:0]
    .o_rotate_I_data   (w_rotate_I_data),   // 旋转后I路数据 [15:0]
    .o_rotate_Q_data   (w_rotate_Q_data),   // 旋转后Q路数据 [15:0]
    .o_rotate_valid    (w_rotate_valid),    // 旋转数据有效
    .o_rotate_last     (w_rotate_last)      // 旋转帧结束信号
);

zoom #(
    .FFT_POINT(FFT_POINT),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_zoom (
    // 时钟和复位
    .clk               (clk),         // 输入时钟 (建议 >2×数据速率)
    .rst               (rst),          // 复位信号 (高/低有效需根据设计确定)
    // 控制信号
    .i_mode            (w_mode),    // 工作模式 [7:0]
    .i_zoom_data       (w_zoom_data), 
    // FFT输入数据
    .i_rotate_I_data      (w_rotate_I_data),  
    .i_rotate_Q_data      (w_rotate_Q_data), 
    .i_rotate_valid       (w_rotate_valid), 
    .i_rotate_last        (w_rotate_last), 
    // 旋转结果输出
    .o_ram_zoom_addr (o_ram_zoom_addr),  // 旋转后RAM地址 [13:0]
    .o_zoom_I_data   (w_zoom_I_data),   // 旋转后I路数据 [15:0]
    .o_zoom_Q_data   (w_zoom_Q_data),   // 旋转后Q路数据 [15:0]
    .o_zoom_valid    (w_zoom_valid),    // 旋转数据有效
    .o_zoom_last     (w_zoom_last)      // 旋转帧结束信号
);
//旋转数组,最大16384点
ram ram_rotate_sin (
  .clka(clk),    // input wire clka
  .wea(i_FFT_ram_wea),      // input wire [0 : 0] wea
  .addra(w_ram_rotate_addr),  // input wire [13 : 0] addra
  .dina(i_FFT_phase_sin[0 +:16]),    // input wire [15 : 0] dina
  .douta(w_phase_sin)  // output wire [15 : 0] douta
);
ram ram_rotate_cos (
  .clka(clk),    // input wire clka
  .wea(i_FFT_ram_wea),      // input wire [0 : 0] wea
  .addra(w_ram_rotate_addr),  // input wire [13 : 0] addra
  .dina(i_FFT_phase_cos[0 +:16]),    // input wire [15 : 0] dina
  .douta(w_phase_cos)  // output wire [15 : 0] douta
);
ram_zoom ram_zoom (
  .clka(clk),    // input wire clka
  .wea(i_FFT_ram_wea),      // input wire [0 : 0] wea
  .addra(w_ram_zoom_addr),  // input wire [13 : 0] addra
  .dina(i_FFT_zoom_data),    // input wire [31 : 0] dina
  .douta(w_zoom_data)  // output wire [31 : 0] douta
);
endmodule
