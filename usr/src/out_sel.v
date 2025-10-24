`timescale 1ns / 1ps
module out_sel(
    input clk,
    input [31:0]i_mode,
    input signed [31:0]i_out_zoom,
    input signed [15:0]i_DDS,
    input signed [15:0] i_IFFT_data,
    output reg signed [15:0]o_dac_data,
    output [35:0]r_dac_data
    );
reg signed [35:0]r_dac_data;//低30位是小数位,31~34是整数位
always @(posedge clk ) begin
    case (i_mode[7:0])
        8'd1: r_dac_data<=i_DDS;
        8'd2: r_dac_data<=i_DDS*i_out_zoom;
        8'd3: r_dac_data<=i_DDS*i_out_zoom;
        8'd4: r_dac_data<=i_IFFT_data*i_out_zoom;
        default: r_dac_data<=0;
    endcase
end
always @(posedge clk ) begin
    case (i_mode[7:0])
        8'd1: o_dac_data<=r_dac_data[0 +:16];
        8'd2: o_dac_data<=r_dac_data[30 -:16];//只需要缩小
        8'd3: o_dac_data<=r_dac_data[30 -:16];//只需要缩小
        8'd4: o_dac_data<=r_dac_data[30 -:16];//可能需要放大
        default: o_dac_data<=r_dac_data;
    endcase
end
endmodule
