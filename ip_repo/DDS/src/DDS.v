`timescale 1ns / 1ps
module DDS (
    input clk,
    input rst,
    input [31:0]i_DDS_FTW,
    output [15:0]o_DDS_sin,
    output [15:0]o_DDS_cos,
    output o_DDS_valid
);
wire [15:0]M_AXIS_PHASE_tdata;
wire M_AXIS_PHASE_tvalid;
wire [31:0]S_AXIS_DDS_tdata;
assign o_DDS_cos=S_AXIS_DDS_tdata[0 +:16];
assign o_DDS_sin=S_AXIS_DDS_tdata[16 +:16];
//DDS控制模块
DDS_Ctrl#(
   .PHASE_WIDTH    (16             )
)
 u_DDS_Ctrl(
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .Freq                               (i_DDS_FTW                      ),// 频率控制字
    .M_AXIS_PHASE_tdata                 (M_AXIS_PHASE_tdata        ),// 低16位为相位控制字
    .M_AXIS_PHASE_tvalid                (M_AXIS_PHASE_tvalid       )
);
//DDS
dds_compiler_0 DDS_gen_IQ (
  .aclk(clk),                                // input wire aclk
  .s_axis_phase_tvalid(M_AXIS_PHASE_tvalid),  // input wire s_axis_phase_tvalid
  .s_axis_phase_tdata(M_AXIS_PHASE_tdata),    // input wire [15 : 0] s_axis_phase_tdata
  .m_axis_data_tvalid(o_DDS_valid),    // output wire m_axis_data_tvalid
  .m_axis_data_tdata(S_AXIS_DDS_tdata)      // output wire [31 : 0] m_axis_data_tdata
);
endmodule