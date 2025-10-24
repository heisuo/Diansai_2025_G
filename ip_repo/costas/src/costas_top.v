//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
//Date        : Mon Apr 21 01:50:47 2025
//Host        : localhost.localdomain running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
//Command     : generate_target costas_wrapper.bd
//Design      : costas_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module costas_top#(
    parameter En_debug=0,
    parameter En_Carrier_Out=1
)(  o_ddc_valid,
    o_ddc_I_data,
    o_ddc_Q_data,
    o_Carrier_I,
    o_Carrier_Q,
    i_mod_data,
    i_mod_valid,
    iw_PLL_C1,
    iw_PLL_C2,
    Sample_Interval,
    clk,
    debug_I_mult,
    debug_Idds_data,
    debug_Q_mult,
    debug_Qdds_data,
    debug_mod_data,
    debug_loop_data,
    i_ftw_ini,
    iw_Loop_Filter_ReWork_h,
    o_phase_error,
    rst);
  output o_ddc_valid;
  output [15:0]o_ddc_I_data;
  output [15:0]o_ddc_Q_data;
  output [13:0] o_Carrier_I;
  output [13:0] o_Carrier_Q;
  input [15:0]i_mod_data;
  input i_mod_valid;
  input [31:0]iw_PLL_C1;
  input [31:0]iw_PLL_C2;
  input [31:0]Sample_Interval;
  input clk;
  output [27:0]debug_I_mult;
  output [13:0]debug_Idds_data;
  output [27:0]debug_Q_mult;
  output [13:0]debug_Qdds_data;
  output [13:0]debug_mod_data;
  output [31:0]debug_loop_data;
  input [31:0]i_ftw_ini;
  input iw_Loop_Filter_ReWork_h;
  output [12:0]o_phase_error;
  input rst;

  wire [15:0]i_mod_data;
  wire i_mod_valid;
  wire clk;
  wire [27:0]debug_I_mult;
  wire [13:0]debug_Idds_data;
  wire [27:0]debug_Q_mult;
  wire [13:0]debug_Qdds_data;
  wire [13:0]debug_mod_data;
  wire [31:0]i_ftw_ini;
  wire iw_Loop_Filter_ReWork_h;
  wire [12:0]o_phase_error;
  wire rst;
//锁相环控制模块
wire                      [31:0]           o_ftw                      ;
//DDS控制模块
    wire                      [15:0]           M_AXIS_PHASE_tdata         ;
    wire                                       M_AXIS_PHASE_tvalid        ;
//DDS
    wire                      [15:0]           M_AXIS_I_mult_tdata        ;
    wire                                       M_AXIS_I_mult_tvalid       ;
    wire                      [15:0]           M_AXIS_Q_mult_tdata        ;
    wire                                       M_AXIS_Q_mult_tvalid       ;
    wire                       [31:0]           S_AXIS_DDS_tdata            ;
    wire                                        S_AXIS_DDS_tvalid           ;
//环路滤波器
    wire                                        S_DDC_valid                 ;
    wire                       [16-1:0]         S_DDC_I_tadta              ;
    wire                       [16-1:0]         S_DDC_Q_tadta              ;
    wire                                       ow_Carrier_Loop_Valid      ;
    wire                      [32-1:0]         ow_Carrier_Loop_data       ;
    wire                      [32-1:0]         ow_Carrier_Doppler         ;
//FIR数据输出
assign o_ddc_valid = S_DDC_valid;
assign o_ddc_I_data=S_DDC_I_tadta;
assign o_ddc_Q_data=S_DDC_Q_tadta;
//debug
assign debug_loop_data=ow_Carrier_Loop_data;
//Carrier
assign o_Carrier_I=debug_Idds_data;
assign o_Carrier_Q=debug_Qdds_data;
//fir滤波器，输出下变频数据
fir_IQ fir_I (
  .aclk(clk),                              // input wire aclk
  .s_axis_data_tvalid(M_AXIS_I_mult_tvalid),  // input wire s_axis_data_tvalid
  .s_axis_data_tdata(M_AXIS_I_mult_tdata),    // input wire [15 : 0] s_axis_data_tdata
  .m_axis_data_tvalid(S_DDC_valid),  // output wire m_axis_data_tvalid
  .m_axis_data_tdata(S_DDC_I_tadta)    // output wire [15 : 0] m_axis_data_tdata
);
fir_IQ fir_Q (
  .aclk(clk),                              // input wire aclk
  .s_axis_data_tvalid(M_AXIS_Q_mult_tvalid),  // input wire s_axis_data_tvalid
  .s_axis_data_tdata(M_AXIS_Q_mult_tdata),    // input wire [15 : 0] s_axis_data_tdata
//   .m_axis_data_tvalid(),  // output wire m_axis_data_tvalid
  .m_axis_data_tdata(S_DDC_Q_tadta)    // output wire [15 : 0] m_axis_data_tdata
);
//环路滤波器
Tracking_Carrier_Loop_top u_Tracking_Carrier_Loop_top(
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .iw_Loop_Filter_ReWork_h            (iw_Loop_Filter_ReWork_h   ),// 重新工作
    .S_IQ_valid                         (S_DDC_valid                ),
    .S_DDC_I_tadta                      (S_DDC_I_tadta             ),
    .S_DDC_Q_tadta                      (S_DDC_Q_tadta             ),
    .iw_PLL_C1(iw_PLL_C1),
    .iw_PLL_C2(iw_PLL_C2),
    .Sample_Interval(Sample_Interval),
    .ow_Carrier_Loop_Valid              (ow_Carrier_Loop_Valid     ),
    .ow_Carrier_Loop_data               (ow_Carrier_Loop_data      ),
    .o_phase_error                      (o_phase_error             ),// 相位误差输出
//这个端口的大小表示相位误差，如果该数值很小了说明已经锁定
    .ow_Carrier_Doppler                 (ow_Carrier_Doppler        )
);

//锁相环控制模块
costas_ctrl u_costas_ctrl(
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .iw_Loop_Filter_ReWork_h            (iw_Loop_Filter_ReWork_h   ),
    .i_ftw_ini                          (i_ftw_ini                 ),// 初始频率字
    .i_Carrier_Loop_data                (ow_Carrier_Loop_data       ),
    .i_Carrier_Loop_valid               (ow_Carrier_Loop_Valid      ),
    .o_ftw                              (o_ftw                     )
);

//DDS控制模块
DDS_Ctrl#(
   .PHASE_WIDTH    (16             )
)
 u_DDS_Ctrl(
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .phase_ad_valid                     (i_mod_valid             ),
    .Freq                               (o_ftw                      ),// 频率控制字
    .M_AXIS_PHASE_tdata                 (M_AXIS_PHASE_tdata        ),// 低16位为相位控制字
    .M_AXIS_PHASE_tvalid                (M_AXIS_PHASE_tvalid       )
);
//DDS
dds_compiler_0 DDS_gen_IQ (
  .aclk(clk),                                // input wire aclk
  .s_axis_phase_tvalid(M_AXIS_PHASE_tvalid),  // input wire s_axis_phase_tvalid
  .s_axis_phase_tdata(M_AXIS_PHASE_tdata),    // input wire [15 : 0] s_axis_phase_tdata
  .m_axis_data_tvalid(S_AXIS_DDS_tvalid),    // output wire m_axis_data_tvalid
  .m_axis_data_tdata(S_AXIS_DDS_tdata)      // output wire [31 : 0] m_axis_data_tdata
);

mult_IQ#(
   .MOD_WIDTH      (14             )
)
 u_mult_IQ(
    .clk                                (clk                       ),
    .M_AXIS_I_mult_tdata                (M_AXIS_I_mult_tdata       ),
    .M_AXIS_I_mult_tvalid               (M_AXIS_I_mult_tvalid      ),
    .M_AXIS_Q_mult_tdata                (M_AXIS_Q_mult_tdata       ),
    .M_AXIS_Q_mult_tvalid               (M_AXIS_Q_mult_tvalid      ),
//debug
    .debug_mod_data                     (debug_mod_data            ),
    .debug_Idds_data                    (debug_Idds_data           ),
    .debug_Qdds_data                    (debug_Qdds_data           ),
    .debug_I_mult                       (debug_I_mult              ),// 混频信号
    .debug_Q_mult                       (debug_Q_mult              ),
//调制信号输入通道
    .S_AXIS_MOD_tdata                   (i_mod_data          ),// 调制信号输入
    .S_AXIS_MOD_tvalid                  (i_mod_valid         ),
//DDS数据流通道
    .S_AXIS_IQ_tdata                    (S_AXIS_DDS_tdata           ),// 本地IQ信号
    .S_AXIS_IQ_tvalid                   (S_AXIS_DDS_tvalid          )
);

endmodule
