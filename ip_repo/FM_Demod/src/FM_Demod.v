`timescale 1ns / 1ps
//FM解调模块
module FM_Demod#(
    parameter INPUT_DATA_WIDTH=16,
    //使能采样间隔
    parameter En_Sample_Interval=1,
    parameter En_debug=0
)(
    input clk,
    //debug
    output [15:0]debug_cnt,
    output debug_data_valid,
    //采用间隔
    input [7:0]Sample_Interval,
    //输出解调信号
    output [2*INPUT_DATA_WIDTH-1:0]M_FM_data,
    output M_FM_valid,
    //输入滤波插值后的IQ信号
    //虽然是截位16位，但实际上，数据还是从第15位开始的
    input signed[INPUT_DATA_WIDTH-1:0]S_I_data,
    input S_IQ_valid,
    input signed[INPUT_DATA_WIDTH-1:0]S_Q_data
    );

    //采样间隔
    reg [7:0]sample_cnt=0;
    reg r_data_valid;
    
    reg M_FM_valid;
    //存取5个点用于数值微分和解调FM
    reg signed[INPUT_DATA_WIDTH-1:0]r_I_b2,r_I_b1,r_I,r_I_a1,r_I_a2;
    reg signed[INPUT_DATA_WIDTH-1:0]r_Q_b2,r_Q_b1,r_Q,r_Q_a1,r_Q_a2;
    //微分结果
    reg signed[INPUT_DATA_WIDTH-1+4:0]r_I_temp1,r_I_temp2,r_Q_temp1,r_Q_temp2;
    reg signed[INPUT_DATA_WIDTH-1+5:0]r_diff_I,r_diff_Q;
    reg signed[2*INPUT_DATA_WIDTH-2+4:0]r_I_mult,r_Q_mult;//有符号数相乘减2位
    reg signed [2*INPUT_DATA_WIDTH-1:0]r_demod_data;//一共33位，相乘叠加，相减再加一位
    reg [3:0]r_valid_sync;//4阶流水延迟
    assign M_FM_data = r_demod_data;//仿真后发现符号位最高22位，注意如果实际解调中波形失真，则给这个加位
    //debug
    assign debug_cnt=sample_cnt;
    assign debug_data_valid=r_data_valid;
    //采样间隔
    always @(posedge clk)
    begin
        if(En_Sample_Interval)begin
            if(S_IQ_valid)begin
                if(sample_cnt>=Sample_Interval-1)begin
                    sample_cnt<=0;
                end 
                else sample_cnt<=sample_cnt+1;
            end
            if(S_IQ_valid & sample_cnt==Sample_Interval-1)begin
                r_data_valid<=1;
            end
            else r_data_valid<=0;
        end
        else begin
            r_data_valid<=S_IQ_valid;
        end
    end
    //采样数据
    always @(posedge clk)
    begin
        if(r_data_valid)begin
            r_I_b2<=S_I_data;
            r_I_b1<=r_I_b2;
            r_I<=r_I_b1;
            r_I_a1<=r_I;
            r_I_a2<=r_I_a1;
        end
        if(r_data_valid)begin
            r_Q_b2<=S_Q_data;
            r_Q_b1<=r_Q_b2;
            r_Q<=r_Q_b1;
            r_Q_a1<=r_Q;
            r_Q_a2<=r_Q_a1;
        end
    end
    //计算微分并解调
    //demod(i)=(I(i)*Q'(i)-I'(i)*Q(i));解调公式
    always @(posedge clk)
    begin
        r_valid_sync<={r_valid_sync[2:0],r_data_valid};
    end
    always @(posedge clk)
    begin
        if(r_valid_sync[0])begin
            r_I_temp1<=r_I_b2-8*r_I_b1;
            r_I_temp2<=8*r_I_a1-r_I_a2;
            r_Q_temp1<=r_Q_b2-8*r_Q_b1;
            r_Q_temp2<=8*r_Q_a1-r_Q_a2;
        end
        if(r_valid_sync[1])begin
            r_diff_I<=r_I_temp1+r_I_temp2;
            r_diff_Q<=r_Q_temp1+r_Q_temp2;
        end
        if(r_valid_sync[2])begin
            r_I_mult<=r_I*r_diff_Q;
            r_Q_mult<=r_Q*r_diff_I;
        end
        if(r_valid_sync[3])begin
            r_demod_data<=r_I_mult-r_Q_mult;
        end
        M_FM_valid<=r_valid_sync[3];
    end
    
    //FM解调
    
    
endmodule
