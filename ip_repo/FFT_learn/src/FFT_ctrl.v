`timescale 1ns / 1ps
module FFT_ctrl#(
    parameter FFT_POINT = 1024
)(
    input clk,
    input rst,
    //控制信号
    input i_start_FFT_pulse,
    input [31:0]i_FFT_index,
    input [31:0]i_mode,
    //两路数据信号
    input i_valid1,
    input signed[13:0]i_data1,
    input i_valid2,
    input signed[13:0]i_data2,
    output reg [63:0]o_FFT1_m_data,
    output reg o_FFT1_m_valid,
    output reg [63:0]o_FFT2_m_data,
    output reg o_FFT2_m_valid,
    output [63:0]o_flow_FFT_data,
    output o_flow_FFT_valid,
    output o_flow_FFT_last
    );
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1
localparam WAIT_LEARN = 'd1 << 1;//等待学习态
localparam LEARN = 'd1 << 2;//学习态
localparam WORK = 'd1 << 3; //工作状态
reg [7:0]state=IDLE,r_state;
wire [7:0]w_mode=i_mode[7:0];
reg [$clog2(FFT_POINT)-1:0]learn_cnt;
reg [$clog2(FFT_POINT)-1:0]work_cnt;
//FFT1输入端
reg [31:0]r_FFT1_s_data;
wire signed[15:0]w_FFT1_s_R_data=i_data1;
reg r_FFT1_s_valid;
reg r_FFT1_s_last;
wire w_FFT1_s_last;
assign w_FFT1_s_last=(state==WAIT_LEARN & r_state==LEARN) | r_FFT1_s_last;
//FFT2输入端
reg [31:0]r_FFT2_s_data;
wire signed[15:0]w_FFT2_s_R_data=i_data2;;
reg r_FFT2_s_valid;
reg r_FFT2_s_last;
wire w_FFT2_s_last;
assign w_FFT2_s_last=(state==WAIT_LEARN & r_state==LEARN);
//FFT1输出端
wire [63:0]w_FFT1_m_data;
wire w_FFT1_m_valid,w_FFT1_m_last;
//FFT2输出端
wire [63:0]w_FFT2_m_data;
wire w_FFT2_m_valid,w_FFT2_m_last;
//数据输出，只输出index的值
reg [31:0]index_cnt;
assign o_flow_FFT_data=w_FFT1_m_data;
assign o_flow_FFT_valid=w_FFT1_m_valid;
assign o_flow_FFT_last=w_FFT1_m_last;
//o_FFT1_m_data,o_FFT1_m_valid,o_FFT2_m_data,o_FFT2_m_valid
always @(posedge clk ) begin
    if(state==WAIT_LEARN)begin
        o_FFT1_m_data<=(index_cnt==i_FFT_index & w_FFT1_m_valid) ? w_FFT1_m_data : o_FFT1_m_data;
        o_FFT1_m_valid<=(index_cnt==i_FFT_index & w_FFT1_m_valid);
        o_FFT2_m_data<=(index_cnt==i_FFT_index & w_FFT1_m_valid) ? w_FFT2_m_data : o_FFT2_m_data;
        o_FFT2_m_valid<=(index_cnt==i_FFT_index & w_FFT1_m_valid);
    end
    else begin
        o_FFT1_m_data<=0;
        o_FFT1_m_valid<=0;
        o_FFT2_m_data<=0;
        o_FFT2_m_valid<=0;
    end
end
//index_cnt
always @(posedge clk ) begin
    if(rst) index_cnt<=0;
    else if(state==WAIT_LEARN)begin
            index_cnt<=w_FFT1_m_valid ? (index_cnt+1) : index_cnt;
    end
    else index_cnt<=0;
end
//r_FFT1_s_last，r_FFT2_s_last
always @(posedge clk ) begin
  r_FFT1_s_last<=((state==WORK & (work_cnt==FFT_POINT-1) & i_valid1));
end
//r_FFT1_s_data,r_FFT1_s_valid
//r_FFT2_s_data,r_FFT2_s_valid
always @(posedge clk ) begin
    case (state)
     LEARN : begin
      r_FFT1_s_data<={16'd0,w_FFT1_s_R_data};
      r_FFT1_s_valid<=i_valid1;
     end
     WORK : begin
      r_FFT1_s_data<={16'd0,w_FFT1_s_R_data};
      r_FFT1_s_valid<=i_valid1;
     end
     default:begin
        r_FFT1_s_data<=0;
        r_FFT1_s_valid<=0;
     end
    endcase
    if(state==LEARN)begin
      r_FFT2_s_data<={16'd0,w_FFT2_s_R_data};
      r_FFT2_s_valid<=i_valid1;
    end
    else begin
        r_FFT2_s_data<=0;
        r_FFT2_s_valid<=0;
    end
end
//work_cnt
always @(posedge clk ) begin
  if(rst) begin 
    work_cnt<=0;
  end
  else if(state==WORK)begin
    if(i_valid1)
      work_cnt<= (work_cnt==FFT_POINT-1) ? 0 : (work_cnt+1);
  end
  else work_cnt<=0;
end
//learn_cnt
always @(posedge clk ) begin
  if(rst) begin 
    learn_cnt<=0;
  end
  else if(state==LEARN)begin
    if(i_valid1)
      learn_cnt<= (learn_cnt==FFT_POINT-1) ? 0 : (learn_cnt+1);
  end
  else learn_cnt<=0;
end
//state
always @(posedge clk ) begin
  if(rst)begin
    state<=IDLE;
  end
  else begin
    case (state)
      IDLE: begin
        if(w_mode==3)
          state<=WAIT_LEARN;
        else if(w_mode==4)
          state<=WORK;
      end
      WAIT_LEARN : begin 
        if(i_start_FFT_pulse) state<=LEARN;
        else if(w_mode==4) state<=WORK;
      end
      LEARN : state<=(learn_cnt==FFT_POINT-1 & i_valid1) ? WAIT_LEARN : state;
      WORK: state<=(w_mode!=4 & work_cnt==FFT_POINT-1 & i_valid1) ? IDLE : state;
      default:state<=IDLE; 
    endcase
  end
  r_state<=state;
end

xfft_0 FFT1_inst (
  .aclk(clk),                                                // input wire aclk
  .s_axis_config_tdata(8'd1),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b1),                // input wire s_axis_config_tvalid
  .s_axis_data_tdata(r_FFT1_s_data),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(r_FFT1_s_valid),                    // input wire s_axis_data_tvalid
  .s_axis_data_tlast(w_FFT1_s_last),                      // input wire s_axis_data_tlast
  .m_axis_data_tdata(w_FFT1_m_data),                      // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(w_FFT1_m_valid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                    // input wire m_axis_data_tready
  // .m_axis_status_tready(1'b1),
  .m_axis_data_tlast(w_FFT1_m_last),                      // output wire m_axis_data_tlast
  .event_frame_started(event_frame_started),                  // output wire event_frame_started
  .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
  .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
  .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
); 
xfft_0 FFT2_inst (
  .aclk(clk),                                                // input wire aclk
  .s_axis_config_tdata(8'd1),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b1),                // input wire s_axis_config_tvalid
  .s_axis_data_tdata(r_FFT2_s_data),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(r_FFT2_s_valid),                    // input wire s_axis_data_tvalid
  .s_axis_data_tlast(w_FFT2_s_last),                      // input wire s_axis_data_tlast
  .m_axis_data_tdata(w_FFT2_m_data),                      // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(w_FFT2_m_valid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                    // input wire m_axis_data_tready
  // .m_axis_status_tready(1'b1),
  .m_axis_data_tlast(w_FFT2_m_last)                      // output wire m_axis_data_tlast
); 
endmodule
