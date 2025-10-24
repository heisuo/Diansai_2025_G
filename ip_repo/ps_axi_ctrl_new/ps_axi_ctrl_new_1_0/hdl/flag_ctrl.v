`timescale 1ns / 1ps
//标志位控制
module flag_ctrl(
    input clk,
    input rstn,
    input i_flag_pulse,
    input i_clear_flag_reg,//清除flag的寄存器
    output reg o_flag
    );
wire w_clear_flag_pusle;
always @(posedge clk) begin
    if(!rstn) o_flag<=0;
    else begin
        case ({i_flag_pulse,w_clear_flag_pusle})
            2'b10: o_flag<=1;
            2'b01: o_flag<=0;
            default: o_flag<=o_flag;
        endcase
    end
end
reg2pulse reg2pulse(
    .clk(clk),
    .i_reg(i_clear_flag_reg),
    .o_pulse(w_clear_flag_pusle)
);
endmodule
