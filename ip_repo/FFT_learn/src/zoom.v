`timescale 1ns / 1ps
//缩放模块
//已经写的麻木了
module zoom#(
    parameter FFT_POINT = 8192,
    parameter ADDR_WIDTH=14
)(
    input clk,
    input rst,
    input [7:0]i_mode,
    input signed[31:0]i_zoom_data,//0~15位是小数位，高位都是整数位

    input signed[15:0]i_rotate_I_data,
    input signed[15:0]i_rotate_Q_data,
    input i_rotate_valid,
    input i_rotate_last,
    output reg [ADDR_WIDTH-1:0]o_ram_zoom_addr,

    output [15:0]o_zoom_I_data,
    output [15:0]o_zoom_Q_data,
    output reg o_zoom_valid,
    output reg o_zoom_last
);
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1
localparam WORK = 'd1 << 1;//工作态
reg [7:0]state=IDLE,r_state;
reg r_rotate_valid,r_rotate_last;
reg signed [30:0]r_zoom_I,r_zoom_Q;
reg signed [15:0]r_rotate_I_data,r_rotate_Q_data;
//2^30=1073741824，2^15=32768
assign o_zoom_I_data=r_zoom_I[30 -:16];
assign o_zoom_Q_data=r_zoom_Q[30 -:16];
//r_rotate_I_data,r_rotate_Q_data
//满足时序
always @(posedge clk ) begin
    r_rotate_I_data<=i_rotate_I_data;
    r_rotate_Q_data<=i_rotate_Q_data;
end
//r_rotate_valid,r_rotate_last
always @(posedge clk ) begin
    r_rotate_valid<=i_rotate_valid;
    r_rotate_last<=i_rotate_last;
end
//o_zoom_valid,o_zoom_last
always @(posedge clk ) begin
    if(state==WORK)begin
        o_zoom_valid<=r_rotate_valid;
        o_zoom_last<=r_rotate_last;
    end
    else begin
        o_zoom_valid<=0;
        o_zoom_last<=0;
    end
end
//o_ram_zoom_addr
always @(posedge clk ) begin
    if(state==WORK)begin
        if(i_rotate_valid)begin
            o_ram_zoom_addr<=(i_rotate_last) ? 0 : (o_ram_zoom_addr+1);
        end
    end
    else o_ram_zoom_addr<=0;
end
//r_zoom_I,r_zoom_Q
always @(posedge clk ) begin
    if(r_rotate_valid)begin
        r_zoom_I<=r_rotate_I_data*i_zoom_data;
        r_zoom_Q<=r_rotate_Q_data*i_zoom_data;
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
            WORK: state<=(i_mode!=4 & r_rotate_last) ? IDLE : state;
            default:state<=IDLE; 
        endcase
    end
end
endmodule
