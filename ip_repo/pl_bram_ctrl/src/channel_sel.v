`timescale 1ns / 1ps
module channel_sel(
    input clk,
    input [31:0]i_channel_sel,
    input [15:0]i_data,
    input i_valid,
    input [15:0]i_data1,
    input i_valid1,
    input [15:0]i_data2,
    input i_valid2,
    input [15:0]i_data3,
    input i_valid3,
    output o_data,
    output o_valid
    );
reg [15:0]o_data;
reg o_valid;
always @(posedge clk ) begin
    case(i_channel_sel)
        0:begin o_data<=i_data; o_valid<=i_valid;end
        1:begin o_data<=i_data1; o_valid<=i_valid1;end
        2:begin o_data<=i_data2; o_valid<=i_valid2;end
        3:begin o_data<=i_data3; o_valid<=i_valid3;end
        default:begin o_data<=i_data; o_valid<=i_valid;end
    endcase
end
endmodule
