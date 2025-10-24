`timescale 1ns / 1ps
module ila_div_trigger(
    input clk,
    output trigger
    );

wire [31:0] vio_freq_div;
vio_div u_vio_div (
  .clk(clk),                 // input wire clk
  .probe_out0(vio_freq_div)  // output wire [31 : 0] probe_out0
);
 
reg [31:0] trigger_cnt;
wire trigger;
always@(posedge clk)
begin
    if(trigger_cnt >= vio_freq_div-1) 
        begin
            trigger_cnt <= 0;
        end
    else 
        begin
            trigger_cnt <= trigger_cnt + 1;
        end
end
    
assign trigger = (trigger_cnt==vio_freq_div-1);

endmodule
