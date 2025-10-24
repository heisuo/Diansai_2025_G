`timescale 1ns / 1ps
module Sliding_average_filter#(
    parameter WINDOW_WIDTH = 10,//窗口位宽
    parameter en_sample_interval = 0,//使能采样间隔
    parameter DATA_WIDTH = 16  //数据位宽
)(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0]i_data,
    input i_valid,
    input [7:0]i_sample_interval,
    output [DATA_WIDTH-1:0]o_data,
    output o_valid
    );
localparam WINDOW_LENGTH = 2**WINDOW_WIDTH;
reg o_valid;
//--------------------------------------------------------
//   256级寄存器移位缓存数据
//--------------------------------------------------------
reg signed[DATA_WIDTH-1:0] din_reg [WINDOW_LENGTH-1:0];
integer j; 
//采样
reg [7:0]samp_cnt=0;
reg signed[DATA_WIDTH-1:0]r_data;
reg r_valid;
always @(posedge clk) begin
    if(en_sample_interval)begin
        if(i_valid)begin
            if(samp_cnt>=i_sample_interval-1)begin
                samp_cnt<=0;
                r_data<=i_data;
            end
            else begin
                samp_cnt<=samp_cnt+1;
            end
        end
        r_valid<=(i_valid & samp_cnt==i_sample_interval-1) ? 1:0;
    end
    else begin
        if(i_valid)begin
            r_data<=i_data;
            r_valid<=1;
        end
        else r_valid<=0;
    end
end
always @ (posedge clk)
begin
    if(rst)begin
        for (j=0; j<WINDOW_LENGTH; j=j+1)
            din_reg[j] <= 0;
    end
    else if(r_valid)begin
        din_reg[0] <= r_data;
        for (j=0; j<WINDOW_LENGTH-1; j=j+1)
            din_reg[j+1] <= din_reg[j];
    end
end
//输出有效计数器
reg [$clog2(WINDOW_LENGTH)-1:0]cnt_ouput_valid;
always @ (posedge clk)begin
    if(rst)begin
        cnt_ouput_valid<=0;
    end
    else if(r_valid)begin
        if(cnt_ouput_valid>=WINDOW_LENGTH-1)begin
        end
        else begin
            cnt_ouput_valid<=cnt_ouput_valid+1;
        end
    end
    o_valid<=(cnt_ouput_valid>=WINDOW_LENGTH-1) ? r_valid:0;
end
//--------------------------------------------------------
//   计算基带信号连续256个数据的均值
//--------------------------------------------------------    
reg signed [DATA_WIDTH+WINDOW_WIDTH-1:0] sum=0;
always @ (posedge clk)begin
    if(r_valid)begin
        //将最老的数据换为最新的数据
        sum <= sum + {{(WINDOW_WIDTH){r_data[DATA_WIDTH-1]}},r_data} 
                    - {{(WINDOW_WIDTH){din_reg[WINDOW_LENGTH-1][DATA_WIDTH-1]}},din_reg[WINDOW_LENGTH-1]};   
    end
end
assign o_data = sum[DATA_WIDTH+WINDOW_WIDTH-1:WINDOW_WIDTH];  //右移8bit等效为÷256    
endmodule
