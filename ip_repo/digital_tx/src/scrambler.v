//加扰模块
module  scrambler (
    input clk,
    input rst,
    input i_bit_valid,//bit数据有效
    input i_bit_data,
    output reg o_scrambler_valid,
    output reg o_scrambler_data
);
//~ 状态定义
localparam IDLE = 'd1 << 0; // 空闲态, 'h1  
localparam WAIT_DATA = 'd1 << 1; // 等待数据到达，帧头不用加扰 
localparam WORK = 'd1 << 2; //发送帧头  
localparam DATA_TX = 'd1 << 3; // 发送数据  
reg [7:0]state=IDLE,r_state;
reg [$clog2(7)-1:0]r_Frame_cnt;
//线性反馈移位寄存器
wire        w_tmp;
reg [7:0]   r8_lfsr_reg1;
assign w_tmp = r8_lfsr_reg1[0]^r8_lfsr_reg1[2]^r8_lfsr_reg1[4]^r8_lfsr_reg1[7];
always @(posedge clk ) begin
    if(rst)begin
        r8_lfsr_reg1 <= 8'b1010_1010;
        o_scrambler_data <= 0;
    end
    else if(state==WORK & i_bit_valid)begin
        r8_lfsr_reg1 <= {r8_lfsr_reg1[6:0],w_tmp};
        o_scrambler_data <= i_bit_data^r8_lfsr_reg1[7];
    end
    else begin
        r8_lfsr_reg1 <= 8'b1010_1010;
        o_scrambler_data     <= i_bit_data;
    end
end
always @(posedge clk ) begin
    o_scrambler_valid<=i_bit_valid;
end
//r_Frame_cnt
always @(posedge clk ) begin
    if(rst)begin
        r_Frame_cnt<=0;
    end
    else if(i_bit_valid)begin
        r_Frame_cnt<=(r_Frame_cnt==7-1) ? 0 : (r_Frame_cnt+1);
    end
    else r_Frame_cnt<=0;
end
//state
always @(posedge clk ) begin
    if(rst)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE:state<= i_bit_valid ? WAIT_DATA : state; 
            WAIT_DATA:state<= (r_Frame_cnt==7-1) ? WORK : state;
            WORK:state<= (!i_bit_valid) ? IDLE : state;
            default: state<=IDLE;
        endcase
    end
end

endmodule