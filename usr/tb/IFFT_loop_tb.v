`timescale 1ns / 1ps
module IFFT_loop_tb();
// 时钟参数
localparam CLK_PERIOD = 10;  // 100MHz时钟
localparam DATA_WIDTH = 14; // 数据位宽
reg clk;
reg rst;
reg i_valid;
reg [DATA_WIDTH-1:0] i_data;
reg[$clog2(8192)-1:0]cnt;
always @(posedge clk ) begin
  if(rst)begin
    cnt<=0;
    i_data<=0;
    i_valid<=0;
  end
  else begin
    i_valid<=1;
    cnt<=(cnt==8192-1) ? 0 : cnt+1;
    i_data<=cnt;
  end
end

// 生成时钟
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end
initial begin
  rst=1;
  #10;
  rst=0;  
  #81930
  #600000;
  $finish;
end
IFFT_loop_0 IFFT_inst (
  .clk(clk),                                // input wire clk
  .rst(rst),                                // input wire rst
  .i_valid(i_valid),                        // input wire i_valid
  .i_data(i_data),                          // input wire [13 : 0] i_data
  .o_valid(o_valid),                        // output wire o_valid
  .o_data(o_data)                          // output wire [15 : 0] o_data
);

endmodule
