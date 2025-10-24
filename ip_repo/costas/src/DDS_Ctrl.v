`timescale 1ns / 1ps

module DDS_Ctrl#(
    parameter PHASE_WIDTH = 14
)(
    input clk,
    input rst,
    input phase_ad_valid,//相位递增有效
    input [31:0]Freq,//频率控制字
    output [15:0]M_AXIS_PHASE_tdata,//低16位为相位控制字
    output M_AXIS_PHASE_tvalid
    );
reg [31:0]phase_r=0;
assign M_AXIS_PHASE_tdata = phase_r[31 -:PHASE_WIDTH];//从 a 的最高位开始向右选取 14 位，即 a[31:31-13]
assign M_AXIS_PHASE_tvalid = 1;
always @(posedge clk)
begin
    if(rst)begin
        phase_r <= 0;
    end
    else if(phase_ad_valid)begin
        phase_r<=phase_r+Freq;
    end
end

endmodule
