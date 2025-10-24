`timescale 1ns / 1ps
//数据抽样模块，将波形的采样率限制到符号速率的4倍
//同时产生符号速率4倍时钟
module data_sample(
    input clk,
    input rst,
    input [31:0]i_sample_FTW,//对应符号速率的4倍
    input [15:0]i_data,
    output o_garder_clk,
    output [15:0]o_sample_data
    );
reg [31:0]r_phase=0;
reg r_garder_clk=0,r1_garder_clk=0;
reg o_garder_clk;
reg [15:0] r_data;
assign o_sample_data=r_data;
//NCO
always @(posedge clk ) begin
    if(rst)begin
        r_phase<=0;
    end
    else begin
        r_phase<={1'b0,r_phase[30:0]}+i_sample_FTW;
    end
end
always @(posedge clk ) begin
    r_garder_clk<= r_phase[31] ? ~r_garder_clk : r_garder_clk;
end
//garder时钟打两拍
always @(posedge clk ) begin
    r1_garder_clk<=r_garder_clk;
    o_garder_clk<=r1_garder_clk;
end
//在garder时钟下降沿更新数据
always @(posedge clk ) begin
    if((!r_garder_clk) & r1_garder_clk)begin
        r_data<=i_data;
    end
end
endmodule
