`timescale 1ns / 1ps
module rotate#(
    parameter FFT_POINT = 8192,
    parameter ADDR_WIDTH=14
)(
    input clk,
    input rst,
    input [7:0]i_mode,
    input signed[15:0]i_phase_sin,
    input signed[15:0]i_phase_cos,

    input signed[15:0]i_FFT_I_data,
    input signed[15:0]i_FFT_Q_data,
    input i_FFT_valid,
    input i_FFT_last,
    output reg [ADDR_WIDTH-1:0]o_ram_rotate_addr,

    output [15:0]o_rotate_I_data,
    output [15:0]o_rotate_Q_data,
    output reg o_rotate_valid,
    output reg o_rotate_last
    );
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1
localparam WORK = 'd1 << 1;//工作态
reg [7:0]state=IDLE,r_state;
reg r_FFT_valid,r_FFT_last;
reg signed [30:0]r_I,r_Q;
reg signed [15:0]r_FFT_I_data,r_FFT_Q_data;
assign o_rotate_I_data=r_I[30 -:16];
assign o_rotate_Q_data=r_Q[30 -:16];
//r_FFT_I_data,r_FFT_Q_data
//满足时序
always @(posedge clk ) begin
    r_FFT_I_data<=i_FFT_I_data;
    r_FFT_Q_data<=i_FFT_Q_data;
end
//r_FFT_valid，r_FFT_last
always @(posedge clk ) begin
    r_FFT_valid<=i_FFT_valid;
    r_FFT_last<=i_FFT_last;
end
//o_rotate_valid,o_rotate_last
always @(posedge clk ) begin
    if(state==WORK)begin
        o_rotate_valid<=r_FFT_valid;
        o_rotate_last<=r_FFT_last;
    end
    else begin
        o_rotate_valid<=0;
        o_rotate_last<=0;
    end
end
//o_ram_rotate_addr
always @(posedge clk ) begin
    if(state==WORK)begin
        if(i_FFT_valid)begin
            o_ram_rotate_addr<=(i_FFT_last) ? 0 : (o_ram_rotate_addr+1);
        end
    end
    else o_ram_rotate_addr<=0;
end
//r_I,r_Q
always @(posedge clk ) begin
    if(r_FFT_valid)begin
        r_I<=r_FFT_I_data*i_phase_cos-r_FFT_Q_data*i_phase_sin;
        r_Q<=r_FFT_I_data*i_phase_sin+r_FFT_Q_data*i_phase_cos;
    end
end

//state
always @(posedge clk ) begin
    if(rst)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE: state<=(i_mode==4) ? WORK : state;
            WORK: state<=(i_mode!=4 & r_FFT_last) ? IDLE : state;
            default:state<=IDLE; 
        endcase
    end
end
endmodule
