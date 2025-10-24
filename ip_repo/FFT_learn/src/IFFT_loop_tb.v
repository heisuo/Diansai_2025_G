`timescale 1ns / 1ps
module IFFT_loop_tb();
// 时钟参数
localparam FFT_POINT=8192;
localparam CLK_PERIOD = 10;  // 100MHz时钟
localparam DATA_WIDTH = 14; // 数据位宽
reg clk;
reg rst;
reg i_start_FFT_pulse;
reg [31:0]i_FFT_index;
reg [31:0]i_mode;
reg [31:0]i_FFT_zoom_data;
reg signed [31:0]i_FFT_phase_sin;
reg [31:0]i_FFT_phase_cos;
reg [31:0]i_FFT_wr_addr;
reg [31:0]i_FFT_ram_wea;
// 生成时钟
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end
initial begin
  rst=1;
  i_start_FFT_pulse=0;
  i_FFT_index=1;
  i_mode=0;
  i_FFT_ram_wea=0;
  i_FFT_wr_addr=0;
  #10;
  rst=0;  
  #10;
  i_mode=3;
  #100;
  i_start_FFT_pulse=1;
  #10
  i_start_FFT_pulse=0;
  #247410;
  #50000;
  //开始写入数据
  #10
  i_FFT_ram_wea=1;
  //第0个频点缩放为1,相移为0
  #10
  i_FFT_wr_addr=0;
  #10
  i_FFT_zoom_data=(1<<15)-1;
  #10
  i_FFT_phase_sin=0;
  #10
  i_FFT_phase_cos=(1<<15)-1;

  //第1个频点缩放为1,相移为pi
  #10
  i_FFT_wr_addr=1;
  #10
  i_FFT_zoom_data=(1<<15)-2;//比较bram数据是否发生变化
  #10
  i_FFT_phase_sin=(1<<15)-1;
  #10
  i_FFT_phase_cos=0;
  #10
  //第FFT_POINT-1个频点缩放为1,相移为-pi
  i_FFT_wr_addr=FFT_POINT-1;
  #10
  i_FFT_zoom_data=(1<<15)-2;//比较bram数据是否发生变化
  #10
  i_FFT_phase_sin=-((1<<15)-1);
  #10
  i_FFT_phase_cos=0;
  #10
  //进入工作模式
  i_FFT_ram_wea=0;
  i_mode=4;
#247410;
#247410;
#247410;
#247410;
  #80000;
  #40000;
  i_mode=1;
  #20000;
  $finish;
end
reg cnt;
wire DDS_valid;
assign DDS_valid=(cnt==1);
wire signed [15:0]DDS_cos,DDS_sin;
wire signed [13:0]i_data1=DDS_cos>>>2;
wire signed [13:0]i_data2=DDS_sin>>>2;
always @(posedge clk ) begin
  if(rst) cnt<=0;
  else cnt<=cnt+1;
end
FFT_learn #(
  .FFT_POINT(FFT_POINT),
  .FFT_OUT_WIDTH(28),
  .IFFT_OUT_WIDTH(30),
  .Fiter_jie(2),
  .OUT_jie(16)
)FFT_inst(
  .clk(clk),                                // input wire clk
  .rst(rst),                                // input wire rst
  .i_FFT_zoom_data(i_FFT_zoom_data),
  .i_FFT_phase_sin(i_FFT_phase_sin),
  .i_FFT_phase_cos(i_FFT_phase_cos),
  .i_FFT_wr_addr(i_FFT_wr_addr),
  .i_FFT_ram_wea(i_FFT_ram_wea),
  .i_valid1(DDS_valid),                        // input wire i_valid
  .i_data1(i_data1),                          // input wire [13 : 0] i_data
  .i_data2(i_data2),
  .i_start_FFT_pulse(i_start_FFT_pulse),
  .i_FFT_index(i_FFT_index),
  .i_mode(i_mode)
);
DDS_0 DDS_inst (
  .clk(clk),                  // input wire clk
  .rst(rst),                  // input wire rst
  .i_DDS_FTW(32'd524288/2),      // input wire [31 : 0] i_DDS_FTW
  .o_DDS_cos(DDS_cos),      // output wire [15 : 0] o_DDS_cos
  .o_DDS_sin(DDS_sin)
  // .o_DDS_valid(DDS_valid)  // output wire o_DDS_valid
);
endmodule
