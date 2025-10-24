`timescale 1ns / 1ps
//继电器控制模块
module jidianqi_ctrl(
    input clk,
    input [31:0]i_mode,
    output reg o_jidianqi
    );
always @(posedge clk ) begin
    if(i_mode==3|i_mode==4)
        o_jidianqi<=1;
    else o_jidianqi<=0;
end
endmodule
