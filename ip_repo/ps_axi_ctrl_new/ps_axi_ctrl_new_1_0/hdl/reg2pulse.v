module reg2pulse (
    input clk,
    input i_reg,
    output o_pulse
);
reg r_reg;
assign o_pulse = i_reg & ~r_reg;
always @(posedge clk ) begin
    r_reg<=i_reg;
end
endmodule