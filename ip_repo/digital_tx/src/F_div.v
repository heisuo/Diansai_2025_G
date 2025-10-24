//分频模块
module F_div (
    input clk,
    input rst,
    input [31:0]i_sample_FTW,//对应符号速率
    input i_fifo_valid,
    input i_bit_data,
    output reg o_fifo_rd_en,
    output o_div_valid,
    output reg o_div_data,
    output o_tx_end_pulse
);
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1  
localparam WORK = 'd1 << 1; // 工作态
reg [7:0]state=IDLE,r_state;
reg [32:0]r_phase=0;
reg r_PWM;//在空闲态时一直输出PWM波(有助于gardner环工作)
// assign o_div_valid=(state==WORK);
assign o_div_valid=o_fifo_rd_en;
assign o_tx_end_pulse=(state==IDLE & r_state==WORK);
//r_PWM
always @(posedge clk ) begin
    if(rst)begin
        r_PWM<=0;
    end
    else if(state==IDLE)
        r_PWM<=r_phase[32] ? (~r_PWM) : r_PWM;
end
//NCO
always @(posedge clk ) begin
    if(rst)begin
        r_phase<=0;
    end
    else begin
        r_phase<={1'b0,r_phase[31:0]}+i_sample_FTW;
    end
end
//o_div_data,o_fifo_rd_en
always @(posedge clk ) begin
    if(i_fifo_valid & r_phase[32])begin
        o_div_data<=i_bit_data;
        o_fifo_rd_en<=1;
    end
    else if(state==IDLE)begin
        o_div_data<=r_PWM;
        o_fifo_rd_en<=0;
    end
    else begin
        o_div_data<=o_div_data;
        o_fifo_rd_en<=0;
    end
end
always @(posedge clk ) begin
    if(rst)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE: state<=(i_fifo_valid & r_phase[32]) ? WORK : state;
            WORK: state<=(!i_fifo_valid & r_phase[32]) ? IDLE : state;
            default:state<=IDLE; 
        endcase
    end
    r_state<=state;
end
endmodule