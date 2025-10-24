`timescale 1ns / 1ps
module IFFT_loop #(
    parameter FFT_POINT = 8192
)(
    input clk,
    input rst,
    input i_valid,
    input signed[13:0]i_data,
    output o_valid,
    output [15:0]o_data,
    output debug_FFT_s_ready,
    output debug_FFT_m_valid,
    output debug_FFT_m_last,
    output debug_IFFT_s_ready,
    output debug_IFFT_m_last
);
//debug
wire debug_FFT_s_ready,debug_FFT_m_valid,debug_FFT_m_last;
//FFT IP输入端
wire [31:0]w_FFT_s_data;
wire signed[15:0]w_FFT_s_R_data;
wire w_FFT_s_valid;
wire w_FFT_s_last;
reg [$clog2(FFT_POINT)-1:0]FFT_cnt;
//FFT IP输出端
wire [31:0]w_FFT_m_data;
wire w_FFT_m_valid,w_FFT_m_last;
//FFT IP输入端
assign w_FFT_s_data={16'd0,w_FFT_s_R_data};
assign w_FFT_s_R_data=i_data<<<2;
assign w_FFT_s_valid=i_valid;
//IFFT
reg [$clog2(FFT_POINT)-1:0]IFFT_cnt;
reg w_IFFT_s_last;
//debug
assign debug_FFT_m_valid=w_FFT_m_valid;
assign debug_FFT_m_last=w_FFT_m_last;
assign w_FFT_s_last=(i_valid & FFT_cnt==FFT_POINT-1);
//w_IFFT_s_last,IFFT_cnt
// assign w_IFFT_s_last=(w_FFT_m_valid & IFFT_cnt==FFT_POINT-1);
// always @(posedge clk ) begin
//     if(rst) IFFT_cnt<=0;
//     else if(w_FFT_m_valid)
//         IFFT_cnt<=(IFFT_cnt==FFT_POINT-1) ? 0 : (IFFT_cnt+1);
// end
//w_FFT_s_last,FFT_cnt
always @(posedge clk ) begin
    if(rst) FFT_cnt<=0;
    else if(i_valid)
        FFT_cnt<=(FFT_cnt==FFT_POINT-1) ? 0 : (FFT_cnt+1);
end
// always @(posedge clk) begin
//     if(i_valid)begin
//         w_FFT_s_last<=(FFT_cnt==FFT_POINT-1);
//     end
// end
xfft_0 FFT_inst (
  .aclk(clk),                                                // input wire aclk
  .s_axis_config_tdata(8'd1),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b1),                // input wire s_axis_config_tvalid
  .s_axis_data_tdata(w_FFT_s_data),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(w_FFT_s_valid),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(debug_FFT_s_ready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(w_FFT_s_last),                      // input wire s_axis_data_tlast
  .m_axis_data_tdata(w_FFT_m_data),                      // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(w_FFT_m_valid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                    // input wire m_axis_data_tready
  .m_axis_data_tlast(w_FFT_m_last),                      // output wire m_axis_data_tlast
  .m_axis_status_tready(1'b1)                // input wire m_axis_status_tready
); 
xfft_0 IFFT_inst (
  .aclk(clk),                                                // input wire aclk
  .s_axis_config_tdata(8'd0),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b1),                // input wire s_axis_config_tvalid
  .s_axis_data_tdata(w_FFT_m_data),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(w_FFT_m_valid),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(debug_IFFT_s_ready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(w_FFT_m_last),                      // input wire s_axis_data_tlast
  .m_axis_data_tdata(o_data),                      // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(o_valid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                    // input wire m_axis_data_tready
  .m_axis_data_tlast(debug_IFFT_m_last),                      // output wire m_axis_data_tlast
  .m_axis_status_tready(1'b1)
); 
endmodule