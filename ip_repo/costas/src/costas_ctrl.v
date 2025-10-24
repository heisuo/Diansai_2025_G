`timescale 1ns / 1ps
module costas_ctrl(
    input clk,
    input rst,
    input iw_Loop_Filter_ReWork_h,
    input [31:0]i_ftw_ini,//初始频率字
    input [31:0]i_Carrier_Loop_data,
    input i_Carrier_Loop_valid,

    output [31:0]o_ftw
    );
//控制DDS
// 确保 Fc 和 Fs 是实数类型（例如定义为 real 或通过宏定义）
// localparam real FTW_NUM_REAL = (Fc * (2.0**32)) / Fs;  // 直接计算实数
// localparam [31:0] FTW_NUM = $realtobits(FTW_NUM_REAL); // 转为32位位模式

reg [31:0]o_ftw;
always @(posedge clk) begin
    if(rst)begin
        o_ftw<=i_ftw_ini;
    end
    else if(iw_Loop_Filter_ReWork_h)begin
        o_ftw<=i_ftw_ini;
    end
    else if(i_Carrier_Loop_valid)begin
        o_ftw<=i_ftw_ini+i_Carrier_Loop_data;
    end
end

endmodule
