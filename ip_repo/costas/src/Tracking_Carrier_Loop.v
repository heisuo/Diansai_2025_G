`timescale 1ns / 1ps
//环路滤波器
module Tracking_Carrier_Loop#(
    parameter   INPUT_DATA_WIDTH              = 16,               // 输入位宽      
    // 本地载波NCO相位控制字位宽,不由IP决定,IP相位控制字位宽固定为16位
    parameter   LOCAL_CARRIER_NCO_PHASE_WIDTH       = 32,               
    // 环路滤波器系数位宽,提前算好
    parameter   FLL_PLL_COEFFICIENT_WIDTH           = 32, 
    //鉴相器截位位宽     
    parameter   Phase_error_WIDTH                   = 13,
    // 锁相环工作之前,锁频环独立工作时间,1个valid信号工作一次
    parameter   FLL_INDEPENDENT_OPERATION_TIME_MS   = 20                    
)(
    input                                           clk,
    input                                           rst,
    //debug
    input                                           iw_Loop_Filter_ReWork_h,//重新工作
    //环路滤波器参数
    input [FLL_PLL_COEFFICIENT_WIDTH-1:0]           iw_PLL_C1,    
    input [FLL_PLL_COEFFICIENT_WIDTH-1:0]           iw_PLL_C2,    
    input [FLL_PLL_COEFFICIENT_WIDTH-1:0]           iw_PLL_C3,
    //工作周期
    input [31:0]                                    Sample_Interval,// 采样间隔，对应锁相环路的更新周期
    input                                           S_IQ_valid,    
    input   [INPUT_DATA_WIDTH-1:0]                  S_DDC_I_tadta,
    input   [INPUT_DATA_WIDTH-1:0]                  S_DDC_Q_tadta,
    
    output [Phase_error_WIDTH-1:0]                  o_phase_error,//相位误差输出
    output                                          ow_Carrier_Loop_Valid,       
	output [LOCAL_CARRIER_NCO_PHASE_WIDTH-1:0]      ow_Carrier_Loop_data,
    //这个端口的大小表示相位误差，如果该数值很小了说明已经锁定
    output [LOCAL_CARRIER_NCO_PHASE_WIDTH-1:0]      ow_Carrier_Doppler   
    );
        
// //鉴相器
wire w_Phase_error_valid;
wire [Phase_error_WIDTH-1:0]w_Phase_error;
wire w_Phase_work_pulse;
reg [15:0]r_sample_cnt=0;
assign o_phase_error=w_Phase_error;
reg signed [INPUT_DATA_WIDTH*2-1:0]r_IQ_mult_data;

reg r_Phase_error_valid=0;

// wire signed [INPUT_DATA_WIDTH-1:0] S_DDC_I_tadta;
// wire signed [INPUT_DATA_WIDTH-1:0] S_DDC_Q_tadta;

// //鉴相器
// assign w_Phase_error=r_IQ_mult_data[(INPUT_DATA_WIDTH*2-1)-1 -:Phase_error_WIDTH];
// always @(posedge clk) begin
//     if(w_Phase_work_pulse)begin
//         r_IQ_mult_data<=S_DDC_I_tadta*S_DDC_Q_tadta;
//         r_Phase_error_valid<=1;
//     end
//     else r_Phase_error_valid<=0;
// end

// 载波环鉴频鉴相器

assign w_Phase_work_pulse=(S_IQ_valid && r_sample_cnt==Sample_Interval-1);
always @(posedge clk) begin
    if(S_IQ_valid)begin
        if(r_sample_cnt>=Sample_Interval-1)begin
            r_sample_cnt<=0;
        end
        else r_sample_cnt<=r_sample_cnt+1;
    end
end

    Tracking_Carrier_Phase_Detector 
    #
    (
        .CORR_OUTPUT_DATA_WIDTH(INPUT_DATA_WIDTH),        // 32'd37,相干积分位宽,37=log2(120_000)+INPUT_DATA_WIDTH+LOCAL_CARRIER_NCO_OUTPUT_WIDTH
                                                                    
        .CORDIC_OUTPUT_DATA_WIDTH(Phase_error_WIDTH)   // 32'd13,cordic输出位宽,由IP核决定,注意,该值越大,输出潜伏期越大
    )
    Tracking_Carrier_Phase_Detector_Inst
    (
        .iw_Clk_p_g(clk),
        .iw_Rst_n_g(~rst),
        
        .iw_Loop_Filter_ReWork_h(iw_Loop_Filter_ReWork_h),
        
        .iw_Integration_Result_Valid_CarrLoop(w_Phase_work_pulse),    
        //不知道为什么两路数据得反过来才能出I路信号
        .iw_Integration_Result_I_P(S_DDC_I_tadta),
        .iw_Integration_Result_Q_P(S_DDC_Q_tadta),
        
        .ow_Carr_Error_Rdy_h(w_Phase_error_valid),   
        .ow_Carr_Phase_Error(w_Phase_error) 
    );

//载波环路滤波器
    costas_loop_filter_2
    #
    (
        .LOCAL_CARRIER_NCO_PHASE_WIDTH(LOCAL_CARRIER_NCO_PHASE_WIDTH),

        .CORDIC_OUTPUT_DATA_WIDTH     (Phase_error_WIDTH),
    
        .FLL_PLL_COEFFICIENT_WIDTH    (FLL_PLL_COEFFICIENT_WIDTH),
        
        .FLL_INDEPENDENT_OPERATION_TIME_MS(FLL_INDEPENDENT_OPERATION_TIME_MS)
    )
    costas_loop_filter_2_inst
    (
        .iw_Clk_p_g(clk),
        .iw_Rst_n_g(~rst),
        
        .iw_Loop_Filter_ReWork_h(iw_Loop_Filter_ReWork_h),
        
        .iw_PLL_C1(iw_PLL_C1),
        .iw_PLL_C2(iw_PLL_C2),
        .iw_PLL_C3(iw_PLL_C3),                                    

        .iw_Carr_Error_Rdy_h(w_Phase_error_valid),
        .iw_Carr_Phase_Error(w_Phase_error),
        
        .ow_Carrier_Loop_Output_Valid(ow_Carrier_Loop_Valid),
        .ow_Carrier_Loop_Output(ow_Carrier_Loop_data),
        .ow_Carrier_Doppler(ow_Carrier_Doppler)
    );

endmodule

