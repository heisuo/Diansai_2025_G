`timescale 1ns / 1ps
module input_sel(
    input clk,
    input [31:0]i_mode,
    input [15:0]i_adc_1,
    input [15:0]i_adc_2,
    output reg[15:0]o_adc_1,
    output reg[15:0]o_adc_2
    );
always @(posedge clk ) begin
    if(i_mode==4)begin
        o_adc_1<=i_adc_2;
        o_adc_2<=0;
    end
    else begin
        o_adc_1<=i_adc_1;
        o_adc_2<=i_adc_2;
    end
end
endmodule
