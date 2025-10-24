module AM_DSB_PSK_mod #(
    parameter IF_DSB_PSK=0
)(
    input clk,
    input rst,
    input [31:0]i_mod_FTW,
    input signed [15:0]i_data,
    //输入数据缩放因子，实际低16位有效，表示输入数据从0到1缩放，最大为2的16次方，具体值通过ps端计算
    //计算公式：（2^16-1）*缩放倍数
    input [31:0]i_zoom_factor,
    output reg o_valid,
    output reg signed [15:0]o_mod_data
);
reg signed[31:0]r_zoom_data;//缩放后数据
reg signed[30:0]r_mod_data;//调制后数据
wire signed [15:0]w_ad_DC_data;//加入直流偏置后的信号,15位无符号数
wire [15:0]w_zoom_factor;
wire signed [15:0]w_DDS_cos;
assign w_zoom_factor=i_zoom_factor[0 +:16];
assign w_ad_DC_data=IF_DSB ? i_data : ({1'b0,~r_zoom_data[31],r_zoom_data[30 -:14]});
assign o_mod_data=r_mod_data[30 -:16];
//r_zoom_data
always @(posedge clk ) begin
    r_zoom_data<=$signed(1'b0,w_zoom_factor) * i_data;
end
//r_mod_data
always @(posedge clk ) begin
    r_mod_data<=w_ad_DC_data * w_DDS_cos;
end
DDS_0 DDS_0 (
  .clk(clk),                  // input wire clk
  .rst(rst),                  // input wire rst
  .i_DDS_FTW(i_mod_FTW),      // input wire [31 : 0] i_DDS_FTW
  .o_DDS_cos(w_DDS_cos),      // output wire [15 : 0] o_DDS_cos
);
endmodule