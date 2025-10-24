`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Beihang
// Engineer: YangXu 
// 
// Create Date:    16:45:01 10/02/2020 
// Design Name: 
// Module Name:    Tracking_Carrier_Loop_Filter 
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
module costas_loop_filter_2
#
(
    parameter   LOCAL_CARRIER_NCO_PHASE_WIDTH       = 32'd40,               // 本地载波NCO相位控制字位宽,不由IP决定,IP相位控制字位宽固定为16位
    
    parameter   CORDIC_OUTPUT_DATA_WIDTH            = 32'd13,               // cordic输出位宽,由IP核决定,注意,该值越大,输出潜伏期越大
    
    parameter   FLL_PLL_COEFFICIENT_WIDTH           = 32,                   // 环路滤波器系数位宽,提前算好
    
    parameter   FLL_INDEPENDENT_OPERATION_TIME_MS   = 20                 // 锁相环工作之前,锁频环独立工作时间,单位ms,默认20ms
)
(
    input                                           iw_Clk_p_g,
    input                                           iw_Rst_n_g,
    
    input                                           iw_Loop_Filter_ReWork_h,
    
    input [FLL_PLL_COEFFICIENT_WIDTH-1:0]           iw_PLL_C1,    
    input [FLL_PLL_COEFFICIENT_WIDTH-1:0]           iw_PLL_C2,    
    input [FLL_PLL_COEFFICIENT_WIDTH-1:0]           iw_PLL_C3, 

    input                                           iw_Carr_Error_Rdy_h,
    input  signed  [CORDIC_OUTPUT_DATA_WIDTH-1:0]   iw_Carr_Phase_Error,
    
	output                                          ow_Carrier_Loop_Output_Valid,       
	output [LOCAL_CARRIER_NCO_PHASE_WIDTH-1:0]      ow_Carrier_Loop_Output,
    output [LOCAL_CARRIER_NCO_PHASE_WIDTH-1:0]      ow_Carrier_Doppler    
);
//*************************************************************************************************************
    function integer log2(input integer n);
        integer i;     
        for( i=0; 2**i<=n; i=i+1) 
            log2 = i + 1;
    endfunction    
//*************************************************************************************************************

    // reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_C1_Product;  
    // reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_C2_Product;
    // reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_C3_Product;

    // always @(posedge iw_Clk_p_g) begin
    //     PLL_C1_Product<=iw_Carr_Phase_Error*iw_PLL_C1;
    //     PLL_C2_Product<=iw_Carr_Phase_Error*iw_PLL_C2;
    //     PLL_C3_Product<=iw_Carr_Phase_Error*iw_PLL_C3;
    // end


    wire signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_C1_Product;  
    wire signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_C2_Product;
    Multiplier_s13xs27 Multi_PLL_C1
                                    (
                                        .CLK(iw_Clk_p_g),
                                        .A  (iw_Carr_Phase_Error),  // input  [12 : 0]  a;
                                        .B  (iw_PLL_C1[31:0]),      // input  [26 : 0]  b;
                                        .P  (PLL_C1_Product)        // output [39 : 0]  p; 潜伏期1个时钟
                                    );

    Multiplier_s13xs27 Multi_PLL_C2
                                    (
                                        .CLK(iw_Clk_p_g),
                                        .A  (iw_Carr_Phase_Error),  // input  [12 : 0]  a;
                                        .B  (iw_PLL_C2[31:0]),      // input  [26 : 0]  b;
                                        .P  (PLL_C2_Product)        // output [39 : 0]  p; 潜伏期1个时钟
                                    );



//*************************************************************************************************************

    reg [15:0] r_Carr_Error_Rdy_h_Sync;
    
    always@(posedge iw_Clk_p_g)
    begin
        r_Carr_Error_Rdy_h_Sync <= {r_Carr_Error_Rdy_h_Sync[14:0],iw_Carr_Error_Rdy_h};
    end

    reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_s0;
    reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_s0_Cpy;
    reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_s1;
    reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_s1_Cpy;
    reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] PLL_s2;   

    reg [3:0] state;

    reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] r_Carrier_Doppler;
    reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] r_PLL_C1_Product;
    reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] r_PLL_C2_Product;
    reg signed [CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH-1:0] r_PLL_C3_Product;
    
    reg [31:0] r32_Cnt;

    always@(posedge iw_Clk_p_g )
    begin
        if(!iw_Rst_n_g)
        begin
            PLL_s0            <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            PLL_s0_Cpy        <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            PLL_s1            <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};

            r_Carrier_Doppler <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            
            state             <= 4'd1;
            
            r_PLL_C1_Product  <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            r_PLL_C2_Product  <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            
            r32_Cnt            <= 32'd0;
        end
        else if(iw_Loop_Filter_ReWork_h)    // 环路滤波器重新工作
        begin
            PLL_s0            <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            PLL_s0_Cpy        <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            PLL_s1            <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            
            r_Carrier_Doppler <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            
            state             <= 4'd1;
            
            r_PLL_C1_Product  <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            r_PLL_C2_Product  <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
            
            r32_Cnt            <= 32'd0;
        end
        else if(state==4'd1)    // 重复操作一次,方便仿真查看
        begin     
            if(r_Carr_Error_Rdy_h_Sync[0])  // 乘法器延迟1个时钟
            begin
                state <= state+4'd1;
                //前20次每次计算后的积分值都清零，可以使频率以较大幅度的跨步，即FLL的过程
                //20次后保持之前的积分数值，即FLL+PLL的过程
                if(r32_Cnt!=FLL_INDEPENDENT_OPERATION_TIME_MS)
                begin
                    r32_Cnt <= r32_Cnt+32'd1;
                    
                    r_PLL_C1_Product <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
                    r_PLL_C2_Product <= {(CORDIC_OUTPUT_DATA_WIDTH+FLL_PLL_COEFFICIENT_WIDTH){1'b0}};
                end
                else
                begin
                    r32_Cnt <= r32_Cnt;
                    
                    r_PLL_C1_Product  <= PLL_C1_Product;//>>>30;
                    r_PLL_C2_Product  <= PLL_C2_Product;//>>>20;
                end
            end
        end        
        else if(state==4'd2)
        begin
            if(r_Carr_Error_Rdy_h_Sync[1])
            begin
                PLL_s0      <= PLL_s0+r_PLL_C1_Product;
                PLL_s0_Cpy  <= PLL_s0;
            end
            else if(r_Carr_Error_Rdy_h_Sync[2])
            begin
                r_Carrier_Doppler  <= PLL_s0+PLL_s0_Cpy;   // 环路结构:二阶环,双线性变换
            end 
            else if(r_Carr_Error_Rdy_h_Sync[3])
            begin          
                PLL_s1      <= r_Carrier_Doppler+r_PLL_C2_Product; 
            end
            else if(r_Carr_Error_Rdy_h_Sync[4])
            begin
                state <= 4'd1;
            end
        end
    end

//*************************************************************************************************************

    assign ow_Carrier_Loop_Output_Valid = r_Carr_Error_Rdy_h_Sync[4];
    assign ow_Carrier_Loop_Output       = PLL_s1>>>20;
    assign ow_Carrier_Doppler           = r_Carrier_Doppler[LOCAL_CARRIER_NCO_PHASE_WIDTH-1:0];

//*************************************************************************************************************
endmodule
