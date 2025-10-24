`timescale 1ns / 1ps
module FFT_learn #(
    parameter FFT_POINT = 32768,
    parameter FFT_OUT_WIDTH=30,
    parameter IFFT_OUT_WIDTH=32,
    parameter Fiter_jie=2,
    parameter OUT_jie=16,
    parameter ADDR_WIDTH=15
)(
    input clk,
    input rst,
    //debug
    output [FFT_OUT_WIDTH-1:0]debug_FFT_flow_I,
    output [FFT_OUT_WIDTH-1:0]debug_FFT_flow_Q,
    output w_flow_FFT_valid,
    output w_flow_FFT_last,
    output [15:0]FFT_Filter_I_data,
    output [15:0]FFT_Filter_Q_data,
    output w_FFT_Filter_valid,
    output w_FFT_Filter_last,
    output [15:0]phase_cos,
    output [15:0]phase_sin,
    output [15:0]FFT_zoom,
    output [15:0]rotate_I,
    output [15:0]rotate_Q,
    output [15:0]zoom_I,
    output [15:0]zoom_Q,
    output w_IFFT_m_valid,
    output [IFFT_OUT_WIDTH-1:0]IFFT_m_data_R,
    //控制信号
    input i_start_FFT_pulse,
    output o_FFT_end_pulse,
    input [31:0]i_FFT_index,
    input [31:0]i_mode,
    input [31:0]i_FFT_zoom_data,
    input [31:0]i_FFT_phase_sin,
    input [31:0]i_FFT_phase_cos,
    input [31:0]i_FFT_wr_addr,
    input [31:0]i_FFT_ram_wea,
    //测量信号
    output signed [31:0]o_FFT1_I,
    output signed [31:0]o_FFT1_Q,
    output signed [31:0]o_FFT2_I,
    output signed [31:0]o_FFT2_Q,
    //通道1是在滤波器之前的信号
    input i_valid1,
    input signed[13:0]i_data1,
    //通道2是在滤波器之后的信号
    input i_valid2,
    input signed[13:0]i_data2,
    output o_valid,
    output [15:0]o_data
);

//FFT_ctrl
wire [63:0]w_FFT1_m_data;
wire w_FFT1_m_valid;
wire [63:0]w_FFT2_m_data;
wire w_FFT2_m_valid;
wire [63:0]w_flow_FFT_data;
wire w_flow_FFT_valid;
wire w_flow_FFT_last;
//cordic_Rotate
wire [31:0]w_FFT_Filter_data;
wire w_FFT_Filter_valid;
wire w_FFT_Filter_last;


//IFFT
wire [31:0]w_IFFT_data;
wire [63:0]w_IFFT_m_data;
wire      w_IFFT_m_valid;
assign w_IFFT_data[0 +:16]=w_FFT_Filter_data[0 +:16];
assign w_IFFT_data[16 +:16]=w_FFT_Filter_data[16 +:16];
// assign o_data=w_IFFT_m_data[OUT_jie -:16];
assign o_FFT_end_pulse=w_FFT2_m_valid;
assign o_FFT1_I=$signed(w_FFT1_m_data[0 +:FFT_OUT_WIDTH]);
assign o_FFT1_Q=$signed(w_FFT1_m_data[32 +:FFT_OUT_WIDTH]);
assign o_FFT2_I=$signed(w_FFT2_m_data[0 +:FFT_OUT_WIDTH]);
assign o_FFT2_Q=$signed(w_FFT2_m_data[32 +:FFT_OUT_WIDTH]);
//debug
assign debug_FFT_flow_I=w_flow_FFT_data[0 +:FFT_OUT_WIDTH];
assign debug_FFT_flow_Q=w_flow_FFT_data[32 +:FFT_OUT_WIDTH];
assign FFT_Filter_I_data=w_FFT_Filter_data[0 +:16];
assign FFT_Filter_Q_data=w_FFT_Filter_data[16 +:16];
assign phase_cos=FFT_Filter.w_phase_cos;
assign phase_sin=FFT_Filter.w_phase_sin;
assign FFT_zoom=FFT_Filter.w_zoom_data;
assign rotate_I=FFT_Filter.w_rotate_I_data;
assign rotate_Q=FFT_Filter.w_rotate_Q_data;
assign zoom_I=FFT_Filter.w_zoom_I_data;
assign zoom_Q=FFT_Filter.w_zoom_Q_data;
assign IFFT_m_data_R=w_IFFT_m_data[IFFT_OUT_WIDTH-1:0];
// FIFO模块例化
wire w_FFT_valid;
wire [13:0]w_FFT_data1,w_FFT_data2;
fifo #(
    .FFT_POINT(FFT_POINT)       // 可修改FFT点数（支持1024/2048/4096等）
) u_data_fifo (
    // 时钟和复位
    .clk               (clk),        // 系统主时钟 (建议100MHz以上)
    .rst               (rst),        // 系统复位 (高有效或低有效)
    // 控制信号
    .i_mode            (i_mode[7:0]),      // 工作模式 [7:0] 
    .i_start_FFT_pulse (i_start_FFT_pulse), // FFT启动脉冲 (宽度≥1个时钟周期)
    // 输入数据接口 (FFT方向)
    .i_valid           (i_valid1),      // ADC输入数据有效
    .i_data1            (i_data1), // ADC输入数据 [13:0]
    .i_data2            (i_data2),

    .o_FFT_valid       (w_FFT_valid),    // 给FFT的有效信号
    .o_FFT_data1        (w_FFT_data1),     // 给FFT的数据 [13:0]
    .o_FFT_data2        (w_FFT_data2),     // 给FFT的数据 [13:0]

    .i_IFFT_valid      (w_IFFT_m_valid),   // IFFT输出有效
    .i_IFFT_data       (w_IFFT_m_data[OUT_jie -:16]),    // IFFT输出数据 [15:0]
    // 输出数据接口
    .o_valid           (o_valid),      // 输出有效
    .o_data            (o_data)        // 输出数据 [15:0]
);
FFT_ctrl #(
  .FFT_POINT(FFT_POINT)
)u_FFT_ctrl(
    // 时钟和复位
    .clk                (clk),                  // input - 主时钟
    .rst                (rst),                  // input - 异步复位（高有效）
    // 控制信号
    .i_start_FFT_pulse  (i_start_FFT_pulse),      // input - FFT启动脉冲
    .i_FFT_index        (i_FFT_index),            // input [31:0] - FFT索引/配置
    .i_mode             (i_mode),             // input [7:0] - 工作模式
    // 通道1数据
    .i_valid1           (w_FFT_valid),           // input - 通道1数据有效
    .i_data1            (w_FFT_data1),            // input signed [13:0] - 通道1数据
    // 通道2数据
    .i_valid2           (w_FFT_valid),           // input - 通道2数据有效
    .i_data2            (w_FFT_data2),            // input signed [13:0] - 通道2数据
    // 通道1输出
    .o_FFT1_m_data      (w_FFT1_m_data),        // output [63:0] - FFT1结果数据
    .o_FFT1_m_valid     (w_FFT1_m_valid),       // output - FFT1结果有效
    // 通道2输出
    .o_FFT2_m_data      (w_FFT2_m_data),        // output [63:0] - FFT2结果数据
    .o_FFT2_m_valid     (w_FFT2_m_valid),        // output - FFT2结果有效
    .o_flow_FFT_data    (w_flow_FFT_data),
    .o_flow_FFT_valid   (w_flow_FFT_valid),
    .o_flow_FFT_last    (w_flow_FFT_last)
);
FFT_Filter #(
  .FFT_POINT(FFT_POINT),
  .FFT_OUT_WIDTH(FFT_OUT_WIDTH),
  .jiewei(Fiter_jie),
  .ADDR_WIDTH(ADDR_WIDTH)
)FFT_Filter(
  .clk(clk),
  .rst(rst),
  //参数
  .i_FFT_zoom_data(i_FFT_zoom_data),
  .i_FFT_phase_sin(i_FFT_phase_sin),
  .i_FFT_phase_cos(i_FFT_phase_cos),
  .i_FFT_wr_addr(i_FFT_wr_addr),
  .i_FFT_ram_wea(i_FFT_ram_wea[0]),
  .i_mode(i_mode),
  //数据流
  .i_flow_FFT_data(w_flow_FFT_data),
  .i_flow_FFT_valid(w_flow_FFT_valid),
  .i_flow_FFT_last(w_flow_FFT_last),
  .o_FFT_Filter_data(w_FFT_Filter_data),
  .o_FFT_Filter_valid(w_FFT_Filter_valid),
  .o_FFT_Filter_last(w_FFT_Filter_last)
  );

xfft_1 IFFT1_inst (
  .aclk(clk),                                                // input wire aclk
  .s_axis_config_tdata(8'd0),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b1),                // input wire s_axis_config_tvalid
  .s_axis_data_tdata(w_IFFT_data),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(w_FFT_Filter_valid),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(debug_IFFT_s_ready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(w_FFT_Filter_last),                      // input wire s_axis_data_tlast
  .m_axis_data_tdata(w_IFFT_m_data),                      // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(w_IFFT_m_valid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                    // input wire m_axis_data_tready
  // .m_axis_status_tready(1'b1),
  .m_axis_data_tlast(debug_IFFT_m_last)                      // output wire m_axis_data_tlast
); 
endmodule