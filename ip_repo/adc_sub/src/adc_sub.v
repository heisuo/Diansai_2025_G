`timescale 1ns / 1ps
module adc_sub(
    input  [31:0]ADC_data,
    output  signed [15:0]ADC_data0,
    output  signed [15:0]ADC_data1,
    output valid
    );
    assign valid=1;
    assign ADC_data0 = $signed(ADC_data[0 +:14]);
    assign ADC_data1 = $signed(ADC_data[16 +:14]);
endmodule
