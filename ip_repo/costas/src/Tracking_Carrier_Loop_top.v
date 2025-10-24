`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2025 04:18:00 AM
// Design Name: 
// Module Name: costas
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Tracking_Carrier_Loop_top(
    input                                           clk,
    input                                           rst,
    input [31:0]                                    iw_PLL_C1,
    input [31:0]                                    iw_PLL_C2,
    input [31:0]                                    Sample_Interval,
    input                                           iw_Loop_Filter_ReWork_h,//重新工作
    input                                           S_IQ_valid,    
    input   [16-1:0]                  S_DDC_I_tadta,
    input   [16-1:0]                  S_DDC_Q_tadta,
    
    output                                          ow_Carrier_Loop_Valid,       
	output [32-1:0]      ow_Carrier_Loop_data,
    output [12:0]       o_phase_error,//相位误差输出
    //这个端口的大小表示相位误差，如果该数值很小了说明已经锁定
    output [32-1:0]      ow_Carrier_Doppler   
    );

Tracking_Carrier_Loop #(
    // 输入数据位宽（默认：16）
    .INPUT_DATA_WIDTH                   (16), 
    // 本地载波NCO相位控制字位宽（默认：32）
    .LOCAL_CARRIER_NCO_PHASE_WIDTH      (32), 
    // 环路滤波器系数位宽，这个位宽必须比实际位宽大至少5位，不后后面环路滤波器积分的时候会溢出
    .FLL_PLL_COEFFICIENT_WIDTH          (32), 
    .Phase_error_WIDTH                  (13),
    // 锁频环独立工作时间，单位：ms（默认：20）
    .FLL_INDEPENDENT_OPERATION_TIME_MS  (20)  
) u_Tracking_Carrier_Loop (
    // 全局时钟
    .clk                                (clk), 
    // 全局复位（高有效）
    .rst                                (rst), 
    // Debug: 重新工作控制信号（高有效）
    .iw_Loop_Filter_ReWork_h            (iw_Loop_Filter_ReWork_h/* 连接控制信号 */), 
    .Sample_Interval                    (Sample_Interval),
    // 锁相环滤波器系数（需外部计算）
    // .iw_PLL_C1                          (40'd7/* 输入[36:0]系数 */), 
    // .iw_PLL_C2                          (40'd625620/* 输入[36:0]系数 */), 
    // .iw_PLL_C3                          (40'd109646610202/* 输入[36:0]系数 */), 
    // .iw_PLL_C1                          (40'd12/* 输入[36:0]系数 */), 
    // .iw_PLL_C2                          (40'd800794/* 输入[36:0]系数 */), 
    // .iw_PLL_C3                          (40'd109646610202/* 输入[36:0]系数 */), 
    //     .iw_PLL_C1                          (40'd0/* 输入[36:0]系数 */), 
    // .iw_PLL_C2                          (40'd32032/* 输入[36:0]系数 */), 
    // .iw_PLL_C3                          (40'd21929322040/* 输入[36:0]系数 */), 
    .iw_PLL_C1                          (iw_PLL_C1/* 输入[36:0]系数 */), 
    .iw_PLL_C2                          (iw_PLL_C2/* 输入[36:0]系数 */), 
    .iw_PLL_C3                          (32'd0/* 输入[36:0]系数 */), 
    // IQ 数据有效标志
    .S_IQ_valid                         (S_IQ_valid/* 连接有效信号 */), 
    // DDC 输出的 I 通道数据（补码格式）
    .S_DDC_I_tadta                      (S_DDC_I_tadta/* 连接I数据[15:0] */), 
    // DDC 输出的 Q 通道数据（补码格式）
    .S_DDC_Q_tadta                      (S_DDC_Q_tadta/* 连接Q数据[15:0] */), 
    
    .o_phase_error                      (o_phase_error),
    // 载波环输出有效标志
    .ow_Carrier_Loop_Valid              (ow_Carrier_Loop_Valid/* 输出有效信号 */), 
    // 载波环输出的NCO相位控制字
    .ow_Carrier_Loop_data               (ow_Carrier_Loop_data/* 输出相位[31:0] */), 
    // 载波多普勒频移（相位误差指示）
    .ow_Carrier_Doppler                 (ow_Carrier_Doppler/* 输出多普勒[31:0] */)  
);
endmodule
