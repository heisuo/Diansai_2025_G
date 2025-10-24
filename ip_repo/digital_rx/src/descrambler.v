//解扰器
`timescale 1ns / 1ps
module descrambler (
    input clk,
    input rst,
    input i_sync_valid,//帧同步数据有效
    input i_sync_data,//帧同步数据
    input i_sync_valid_pulse,//这是帧同步完成脉冲
    input i_rx_end_pulse,
    output reg o_ds_data,
    output reg o_ds_valid
);
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1
localparam WORK = 'd1 << 1; // 工作状态
reg [7:0]state=IDLE,r_state;
reg [7:0]   r8_lfsr_reg1;
assign w_tmp = r8_lfsr_reg1[0]^r8_lfsr_reg1[2]^r8_lfsr_reg1[4]^r8_lfsr_reg1[7];
//r8_lfsr_reg1，o_ds_data
always @(posedge clk ) begin
    if(rst)begin
        r8_lfsr_reg1 <= 8'b1010_1010;
        o_ds_data <= 0;
    end
    else if(state==WORK)begin
        if(i_sync_valid)begin
            r8_lfsr_reg1 <= {r8_lfsr_reg1[6:0],w_tmp};
            o_ds_data <= i_sync_data^r8_lfsr_reg1[7];
        end
    end
    else begin
        r8_lfsr_reg1 <= 8'b1010_1010;
        o_ds_data     <= i_sync_data;
    end
end
always @(posedge clk ) begin
    o_ds_valid<=i_sync_valid;
end
//state,r_state
always @(posedge clk ) begin
    if(rst)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE: state<=(i_sync_valid_pulse) ? WORK : state;
            WORK: state<=(i_rx_end_pulse) ? IDLE : state;
            default:state<=IDLE; 
        endcase
    end
end

endmodule