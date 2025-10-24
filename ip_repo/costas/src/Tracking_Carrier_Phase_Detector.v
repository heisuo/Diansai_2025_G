`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Beihang
// Engineer: YangXu
// 
// Create Date:    01:49:01 09/29/2020 
// Design Name: 
// Module Name:    Tracking_Carrier_Phase_Detector 
// Project Name:   Dual_Frequency_Receiver
// Target Devices: 7k325t
// Tool versions:  ISE14.7
// Description:
//
// Dependencies:
//
// Revision: 1.0
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module Tracking_Carrier_Phase_Detector
#
(
    parameter   CORR_OUTPUT_DATA_WIDTH              = 32'd19,   // 37 相干积分位宽,37=log2(120_000)+INPUT_DATA_WIDTH+LOCAL_CARRIER_NCO_OUTPUT_WIDTH
    parameter   CORDIC_OUTPUT_DATA_WIDTH            = 32'd13,   // cordic输出位宽,由IP核决定,注意,该值越大,输出潜伏期越大                                                                
    parameter   CORDIC_OUTPUT_LATENCY               = 32'd17,   // cordic输出潜伏期,由IP核决定
    parameter   FLL_INDEPENDENT_OPERATION_TIME_MS   = 8'd20     // 锁相环工作之前,锁频环独立工作时间,单位ms,默认20ms
)
(
    input                                           iw_Clk_p_g,
    input                                           iw_Rst_n_g,

    input                                           iw_Loop_Filter_ReWork_h,
    
    input                                           iw_Integration_Result_Valid_CarrLoop,
    input   signed  [CORR_OUTPUT_DATA_WIDTH-1:0]    iw_Integration_Result_I_P,
    input   signed  [CORR_OUTPUT_DATA_WIDTH-1:0]    iw_Integration_Result_Q_P,
  
    output                                          ow_Carr_Error_Rdy_h,
    output  signed  [CORDIC_OUTPUT_DATA_WIDTH-1:0]  ow_Carr_Phase_Error    
);
//*************************************************************************************************************
    function integer log2(input integer n);
        integer i;     
        for( i=0; 2**i<=n; i=i+1) 
            log2 = i + 1;
    endfunction    

//*************************************************************************************************************

    reg r_Integration_Result_Valid_CarrLoop_Sync1;
    reg r_Integration_Result_Valid_CarrLoop_Sync2;
    reg r_Integration_Result_Valid_CarrLoop_Sync3;
    
    always@( posedge iw_Clk_p_g)
    begin
        r_Integration_Result_Valid_CarrLoop_Sync1 <= iw_Integration_Result_Valid_CarrLoop;
        r_Integration_Result_Valid_CarrLoop_Sync2 <= r_Integration_Result_Valid_CarrLoop_Sync1;
        r_Integration_Result_Valid_CarrLoop_Sync3 <= r_Integration_Result_Valid_CarrLoop_Sync2;
    end

//*************************************************************************************************************
// POS_PI=π*2^10≈3217,phase_out输出数据格式:2QN,默认IP参数N=10

localparam signed POS_PI   = 14'd3217;          // 前缀signed很重要
localparam signed POS_PI_2 = 14'd1608;          // 前缀signed很重要
localparam signed NEG_PI_2 = -POS_PI_2;         // 前缀signed很重要

//*************************************************************************************************************
// 鉴相器,atan(Qp/Ip)方法,IP核是ArcTan模式

    wire signed [CORR_OUTPUT_DATA_WIDTH-1:0] w_I_P;
    wire signed [CORR_OUTPUT_DATA_WIDTH-1:0] w_Q_P;

    localparam VAL_MAX = {1'b0, {(CORR_OUTPUT_DATA_WIDTH-1){1'b1}}};
    localparam VAL_MIN = {1'b1, {(CORR_OUTPUT_DATA_WIDTH-1){1'b0}}};

    // 取绝对值
    assign w_I_P = (iw_Integration_Result_I_P==VAL_MIN)?VAL_MAX:(iw_Integration_Result_I_P[CORR_OUTPUT_DATA_WIDTH-1] ? (~iw_Integration_Result_I_P+1'b1) : iw_Integration_Result_I_P);
    assign w_Q_P = (iw_Integration_Result_Q_P==VAL_MIN)?VAL_MAX:(iw_Integration_Result_Q_P[CORR_OUTPUT_DATA_WIDTH-1] ? (~iw_Integration_Result_Q_P+1'b1) : iw_Integration_Result_Q_P);

    // 为了保证CORDIC IP运算的准确性,CORDIC_IP输入数据位宽总是至少比 CORR_OUTPUT_DATA_WIDTH 多1位
    wire signed [CORR_OUTPUT_DATA_WIDTH:0] w_I_P_CORDIC;
    wire signed [CORR_OUTPUT_DATA_WIDTH:0] w_Q_P_CORDIC;

    assign w_I_P_CORDIC = w_I_P=={(CORR_OUTPUT_DATA_WIDTH){1'b0}} ? {{(CORR_OUTPUT_DATA_WIDTH){1'b0}},{1'b1}} : {w_I_P[CORR_OUTPUT_DATA_WIDTH-1],w_I_P};
    assign w_Q_P_CORDIC = {w_Q_P[CORR_OUTPUT_DATA_WIDTH-1],w_Q_P};
    //翻转鉴相，让数据从I路输出
    // assign w_Q_P_CORDIC = w_Q_P=={(CORR_OUTPUT_DATA_WIDTH){1'b0}} ? {{(CORR_OUTPUT_DATA_WIDTH){1'b0}},{1'b1}} : {w_Q_P[CORR_OUTPUT_DATA_WIDTH-1],w_Q_P};
    // assign w_I_P_CORDIC = {w_I_P[CORR_OUTPUT_DATA_WIDTH-1],w_I_P};

    reg signed [CORR_OUTPUT_DATA_WIDTH:0] r_I_P_CORDIC;
    reg signed [CORR_OUTPUT_DATA_WIDTH:0] r_Q_P_CORDIC;
    reg r_cartesian_tvalid;
    reg [1:0] state;

    // w_I_P_CORDIC 和 w_Q_P_CORDIC 如果值太小,鉴相误差会很大,所以通过同比例放大,使 w_I_P_CORDIC 和 w_Q_P_CORDIC 接近+1
    // 副作用是 ow_Carr_Error_Rdy_h 的高有效潜伏期不再固定,如果输入数据较小,潜伏期会变大，反之亦然
    always@( posedge iw_Clk_p_g)
    begin
        if(iw_Integration_Result_Valid_CarrLoop)
        begin
            r_I_P_CORDIC <= w_I_P_CORDIC;
            r_Q_P_CORDIC <= w_Q_P_CORDIC;

            r_cartesian_tvalid <= 1'b0;

            state <= 2'd1;
        end
        else if((state==2'd1)&&(r_I_P_CORDIC[CORR_OUTPUT_DATA_WIDTH:CORR_OUTPUT_DATA_WIDTH-2]==3'b000)&&(r_Q_P_CORDIC[CORR_OUTPUT_DATA_WIDTH:CORR_OUTPUT_DATA_WIDTH-2]==3'b000))
        begin
            r_I_P_CORDIC <= r_I_P_CORDIC<<1; 
            r_Q_P_CORDIC <= r_Q_P_CORDIC<<1;

            r_cartesian_tvalid <= 1'b0;

            state <= state;
        end
        else if(state==2'd1)
        begin
            r_I_P_CORDIC <= r_I_P_CORDIC; 
            r_Q_P_CORDIC <= r_Q_P_CORDIC;            

            r_cartesian_tvalid <= 1'b1;

            state <= 2'd2;
        end
        else
        begin
            r_I_P_CORDIC <= r_I_P_CORDIC; 
            r_Q_P_CORDIC <= r_Q_P_CORDIC;            

            r_cartesian_tvalid <= 1'b0;

            state <= 2'd0;            
        end
    end

    wire w_atan_phase_error_out_rdy;
    wire signed [CORDIC_OUTPUT_DATA_WIDTH-1:0] w_atan_phase_error_out; 
    reg  signed [CORDIC_OUTPUT_DATA_WIDTH-1:0] r_atan_phase_error_out;
    
    // IP:cordic 模式:ArcTan
    // 注意:数学上,ArcTan的结果在[-π/2,+π/2],但这个IP的结果在[-π,+π],所以必须对由于电文正负变化带来的鉴相结果进行纠正
    // 具体纠正措施是:大于π/2的结果减去π,对小于-π/2的结果加上π,使鉴相结果落在正确区间
    // x_in和y_in输入数据格式:1QN,输入范围[-1,+1],而这里不对原始输入数据范围进行处理的原因是 w_I_P 和 w_Q_P 统一进行数据缩放,对最终结果输出的正确没有影响
    // phase_out输出数据格式:2QN,输出范围[-π,+π],如果直接使用该值,可以认为在[-π,+π]的基础上左移了N,即乘以2^N,默认IP参数N=10,即 CORDIC_OUTPUT_DATA_WIDTH-2-1
     TrackingCarrierLoopPhaseDetector TrackingCarrierLoopPhaseDetector_Inst
                                                                        (
                                                                            .aclk(iw_Clk_p_g),
                                                                            
                                                                            .s_axis_cartesian_tvalid(r_cartesian_tvalid),
                                                                            .s_axis_cartesian_tdata({r_Q_P_CORDIC,r_I_P_CORDIC}),

                                                                            .m_axis_dout_tvalid(w_atan_phase_error_out_rdy),    // Latency=17
                                                                            .m_axis_dout_tdata(w_atan_phase_error_out)          // output [12 : 0]
                                                                        );

    reg r_Quadrant_Flg; 
    reg r_I_Flg; 
    reg r_Q_Flg;

    always@( posedge iw_Clk_p_g)
    begin
        if(iw_Integration_Result_Valid_CarrLoop)
        begin
            r_Quadrant_Flg <= iw_Integration_Result_I_P[CORR_OUTPUT_DATA_WIDTH-1]^iw_Integration_Result_Q_P[CORR_OUTPUT_DATA_WIDTH-1];
            r_I_Flg <= iw_Integration_Result_I_P[CORR_OUTPUT_DATA_WIDTH-1]; // 取出I支路符号
            r_Q_Flg <= iw_Integration_Result_Q_P[CORR_OUTPUT_DATA_WIDTH-1]; // 取出Q支路符号          
        end
        else
        begin
            r_Quadrant_Flg <= r_Quadrant_Flg;
            r_I_Flg <= r_I_Flg;
            r_Q_Flg <= r_Q_Flg;
        end
    end                                                                        

    // 根据输入信号相位的象限修正输出相位的符号,相位格式2QN,输出范围[-π,+π],如果直接使用该值,可以认为在[-π,+π]的基础上左移了N,即乘以2^N,默认IP参数N=10,即 CORDIC_OUTPUT_DATA_WIDTH-2-1
    // 之后的环路系数需要对此作出修正
    localparam signed MAX_VAL = {{(1){1'b0}}, {(CORDIC_OUTPUT_DATA_WIDTH-1){1'b1}}}; 
    localparam signed MIN_VAL = {{(1){1'b1}}, {(CORDIC_OUTPUT_DATA_WIDTH-1){1'b0}}};
    wire signed [CORDIC_OUTPUT_DATA_WIDTH-1:0] w_atan_phase_error_out_op = (w_atan_phase_error_out==MIN_VAL)?MAX_VAL:(~w_atan_phase_error_out+1'b1);
    always@( posedge iw_Clk_p_g)
    begin
        if(w_atan_phase_error_out_rdy)  
            r_atan_phase_error_out <= r_Quadrant_Flg ? w_atan_phase_error_out_op : w_atan_phase_error_out; // 正确
        else
            r_atan_phase_error_out <= r_atan_phase_error_out;
    end

//*************************************************************************************************************

    reg r_pahse_error_rdy_sync1;

    always@(posedge iw_Clk_p_g)
    begin
        r_pahse_error_rdy_sync1 <= w_atan_phase_error_out_rdy; // ArcTan鉴相器
    end
   
    assign ow_Carr_Error_Rdy_h = r_pahse_error_rdy_sync1;
    assign ow_Carr_Phase_Error = r_atan_phase_error_out; 

//*************************************************************************************************************
endmodule
