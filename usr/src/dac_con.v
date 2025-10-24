`timescale 1ns / 1ps
module dac_con(
    input signed [15:0]i_dac_data1,
    input signed [15:0]i_dac_data2,
    output [31:0]o_dac_data
    );
assign o_dac_data[0 +:16]=i_dac_data1;
assign o_dac_data[16 +:16]=i_dac_data2;
endmodule
