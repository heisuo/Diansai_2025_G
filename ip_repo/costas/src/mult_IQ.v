//IQ信号与调制信号相乘基本模块
module mult_IQ#(
    parameter MOD_WIDTH = 14,
            OUT_WIDTH = 14
)(
    input clk,
    output [15:0]M_AXIS_I_mult_tdata,
    output M_AXIS_I_mult_tvalid,
    output [15:0]M_AXIS_Q_mult_tdata,
    output M_AXIS_Q_mult_tvalid,
    //debug
    output [13:0]debug_mod_data,
    output [13:0]debug_Idds_data,
    output [13:0]debug_Qdds_data,
    output [27:0]debug_I_mult,//混频信号
    output [27:0]debug_Q_mult,
    //调制信号输入通道
    input [15:0]S_AXIS_MOD_tdata, //调制信号输入
    input S_AXIS_MOD_tvalid,
    //DDS数据流通道
    input [31:0]S_AXIS_IQ_tdata,//本地IQ信号
    input S_AXIS_IQ_tvalid
    );
    wire signed [MOD_WIDTH-1:0]data_I,data_Q,data_MOD;
    reg signed [2*MOD_WIDTH-1:0]data_I_mult,data_Q_mult;
    reg M_AXIS_I_mult_tvalid,M_AXIS_Q_mult_tvalid;
    assign data_I = S_AXIS_IQ_tdata[0 +:MOD_WIDTH];// 从 a 的最低位开始选取 14 位，即 a[13:0]
    assign data_Q = S_AXIS_IQ_tdata[16 +:MOD_WIDTH];//a[29:16]
    assign data_MOD = S_AXIS_MOD_tdata[0 +:MOD_WIDTH];//a[13:0]

    assign M_AXIS_I_mult_tdata = data_I_mult[(2*MOD_WIDTH-1)-1 -:OUT_WIDTH];//两个有符号数相乘一般会产生两个符号位，可以放心舍去一个高位
    assign M_AXIS_Q_mult_tdata = data_Q_mult[(2*MOD_WIDTH-1)-1 -:OUT_WIDTH];
    //debug
    assign debug_mod_data=S_AXIS_MOD_tdata[0 +:MOD_WIDTH];
    assign debug_Idds_data=data_I;
    assign debug_Qdds_data=data_Q;
    assign debug_I_mult=data_I_mult;
    assign debug_Q_mult=data_Q_mult;

    always @(posedge clk)           
    begin
        if(S_AXIS_MOD_tvalid & S_AXIS_IQ_tvalid)begin
            data_I_mult<=data_I*data_MOD;
            data_Q_mult<=data_Q*data_MOD;
            M_AXIS_I_mult_tvalid<=1;
            M_AXIS_Q_mult_tvalid<=1;
        end
        else begin
            M_AXIS_I_mult_tvalid<=0;
            M_AXIS_Q_mult_tvalid<=0;
        end
    end

endmodule
