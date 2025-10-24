`timescale 1ns / 1ps
module ADDA_jilin#(
    parameter DAC_DCI_DELAY_MODE = 1,    //00～11: 00:350ps 1:590ps 2:800ps 3:925ps
              BYPASS_NSINC = 1,
              BYPASS_NCO = 1,
              ADC_DCO_DELAY = 15,         //0～31: delay_value [delay = (3100 ps * delay_value/31 +100)]
    parameter [31:0]NCO_FTW = 429946730		//默认100M
)(
    input clk_spi_50M,
    input locked,
    output  o_sys_clk,                //250M时钟
    output      power_en,
    //spi
	output  fmc_spi_sclk,    //spi时钟引脚，AD964-9122-9516共用
	inout   fmc_spi_sdio,         //spi数据引脚，AD964-9122-9516共用
	output  fmc_clk_cs,	
	output  fmc_adc_cs, 
	output  fmc_dac_cs,

    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 adc_dco CLK_P" *)
    input adc_dco_p,    //adc 数据时钟
    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 adc_dco CLK_N" *)
    input adc_dco_n,
    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 adc_in V_P" *)
	input[13:0] adc_data_p, //adc  ad9643数据引脚
    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 adc_in V_N" *)
	input[13:0] adc_data_n,
	
	// output      dac_frame_p,//dac  AD9122 frame
	// output      dac_frame_n,
    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 dac_dci CLK_P" *)
	output      dac_dci_p,  //dac  AD9122 数据时钟
    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 dac_dci CLK_N" *)
	output      dac_dci_n,
    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 dac_out V_P" *)
	output[15:0]dac_data_p, //dac  AD9122 数据
    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 dac_out V_N" *)
	output[15:0]dac_data_n,

    input [31:0]i_dac_data,        // DAC数据输入(15:0通道1，31:16通道2)

    output [31:0]o_adc_data      // ADC数据输出(13:0通道1，29:16通道2)
    );


////////////////////////////////////////////////////////////////////////////////////       
    wire     [9:0]    adc_lut_index;
    wire     [24:0]   adc_lut_data;
    wire     [9:0]    dac_lut_index;
    wire     [15:0]   dac_lut_data;    
    wire     [9:0]    clk_lut_index;
    wire     [24:0]   clk_lut_data ;
    wire              done_flag;

    wire[13:0]                     receive_adc_data;// adc数据（转单端后）
    wire[13:0]                       adc_data_A_get;
    wire[13:0]                       adc_data_B_get;
    (* IOB = "true" *)reg [13:0]                       r_adc_data_A_get;
    (* IOB = "true" *)reg [13:0]                       r_adc_data_B_get;
    wire[15:0] Ich_data;  //DAC通道1数据
    wire[15:0] Qch_data;  //DAC通道2数据
    (* IOB = "true" *)reg [15:0]                       r_Ich_data;
    (* IOB = "true" *)reg [15:0]                       r_Qch_data;
    assign power_en =1;
    assign o_adc_data={2'd0,r_adc_data_B_get,2'd0,r_adc_data_A_get};
    assign Ich_data=i_dac_data[0 +:16];
    assign Qch_data=i_dac_data[16 +:16];

//////////////////////////////////////////////////////////////////////////////////// 
wire                            adc_clk_ibuf;
wire                            adc_clk_250M;
IBUFDS #(                     //原语
	.DIFF_TERM("TRUE"),       // Differential Termination
	.IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
	.IOSTANDARD("LVDS_25")     // Specify the input I/O standard
)IBUFDS_adc_clk (
	.O   (adc_clk_ibuf),  // Buffer output
	.I   (adc_dco_p),  // Diff_p buffer input (connect directly to top-level port)
	.IB  (adc_dco_n) // Diff_n buffer input (connect directly to top-level port)
);
BUFG CLK_B0(.I(adc_clk_ibuf),.O(adc_clk_250M));
assign o_sys_clk=adc_clk_250M;
//////////////////////////////////////////////////////////////////////////////////// 
always @(posedge adc_clk_250M) begin
    r_adc_data_A_get<=adc_data_A_get;
    r_adc_data_B_get<=adc_data_B_get;
    r_Ich_data<=Ich_data;
    r_Qch_data<=Qch_data;
end
//////////////////////////////   ADC AD9643数据差分转单端  ////////////////////////////

genvar i;
generate
	for (i = 0; i < 14; i = i + 1) 
	begin:IBUFDS_DATAS_1
		IBUFDS #(
		.DIFF_TERM("TRUE"),       // Differential Termination
		.IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
		.IOSTANDARD("LVDS_25")     // Specify the input I/O standard
		) IBUFDS_adc_data (
		.O(receive_adc_data[i]),  // Buffer output
		.I(adc_data_p[i]),  // Diff_p buffer input (connect directly to top-level port)
		.IB(adc_data_n[i]) // Diff_n buffer input (connect directly to top-level port)
		);

        IDDR #(
           .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                           //    or "SAME_EDGE_PIPELINED" 
           .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
           .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
           .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
		) ad1 (
           .Q1(adc_data_A_get[i]), // 1-bit output for positive edge of clock 
           .Q2(adc_data_B_get[i]), // 1-bit output for negative edge of clock
           .C(adc_clk_250M),   // 1-bit clock input
           .CE(1'b1), // 1-bit clock enable input
           .D(receive_adc_data[i]),   // 1-bit DDR data input
           .R(1'b0),   // 1-bit reset
           .S(1'b0)    // 1-bit set
        );
	end
endgenerate

//DAC驱动
//时钟差分
OBUFDS #(
    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
    .SLEW("FAST")           // Specify the output slew rate
) OBUFDS_adc_clk_inst (
    .O(dac_dci_p),     // Diff_p output (connect directly to top-level port)
    .OB(dac_dci_n),   // Diff_n output (connect directly to top-level port)
    .I(adc_clk_250M)      // Buffer input
);

//数据差分
wire [15:0]data_out_to_pins_predelay;
  genvar pin_count;
generate for (pin_count = 0; pin_count < 16; pin_count = pin_count + 1) begin: pins

    OBUFDS
      #(.IOSTANDARD ("LVDS_25"))
     obufds_inst
       (.O          (dac_data_p  [pin_count]),
        .OB         (dac_data_n  [pin_count]),
        .I          (data_out_to_pins_predelay[pin_count]));

    ODDR
     #(.DDR_CLK_EDGE   ("SAME_EDGE"), //"OPPOSITE_EDGE" "SAME_EDGE"
       .INIT           (1'b0),
       .SRTYPE         ("ASYNC"))
     oddr_inst
      (.D1             (r_Ich_data[pin_count]),
       .D2             (r_Qch_data[pin_count]),
       .C              (adc_clk_250M),
       .CE             (1'b1),
       .Q              (data_out_to_pins_predelay[pin_count]),
    //    .R              (!done_flag_r),
        .R              (0),
       .S              (1'b0));
  end
endgenerate

//////////////////////////////SPI相关//////////////////////////// 
////////////////////////////////////////////////////////////////////////////////////  
ad9643_config #(
    .ADC_DCO_DELAY(ADC_DCO_DELAY)
)u2(
	.lut_index                  (adc_lut_index           ),
	.lut_data                   (adc_lut_data            )
);
////////////////////////////////////////////////////////////////////////////////////  
ad9122_config #(
    .DAC_DCI_DELAY_MODE(DAC_DCI_DELAY_MODE),
    .BYPASS_NSINC(BYPASS_NSINC),
    .BYPASS_NCO(BYPASS_NCO),
    .NCO_FTW(NCO_FTW)
)u3(
	.lut_index                  (dac_lut_index           ),
	.lut_data                   (dac_lut_data            )
);
////////////////////////////////////////////////////////////////////////////////////  
ad9516_config u4(
	.lut_index                  (clk_lut_index           ),
	.lut_data                   (clk_lut_data            )
);
////////////////////////////////////////////////////////////////////////////////////         
spi_config_top u5(
    .clk_50m        (clk_spi_50M       ),
    .locked         (locked       ),
    .spi_clk        (fmc_spi_sclk       ),    
    .spi_io         (fmc_spi_sdio        ),     
    .clk_spi_ce     (fmc_clk_cs    ),	
    .adc_spi_ce     (fmc_adc_cs    ),	
    .dac_spi_ce     (fmc_dac_cs    ),	
    .adc_lut_index (adc_lut_index),
    .adc_lut_data  (adc_lut_data ),
    .dac_lut_index (dac_lut_index),
    .dac_lut_data  (dac_lut_data ),
    .clk_lut_index  (clk_lut_index ),
    .clk_lut_data   (clk_lut_data  ),
    .done_flag(done_flag) 
    );

                   
endmodule
