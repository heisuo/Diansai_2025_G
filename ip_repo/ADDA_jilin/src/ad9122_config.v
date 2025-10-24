`timescale 1ns / 1ps

module ad9122_config#(
    parameter DAC_DCI_DELAY_MODE = 2'b01,    //00~11
	parameter [0:0]BYPASS_NSINC = 1,
				[0:0]BYPASS_NCO = 1,
	parameter [31:0]NCO_FTW = 429946730		//默认100M
)(
    input[9:0]             lut_index,   //Look-up table address
	output reg[15:0]       lut_data     //reg address reg data
);

always@(*)
begin
	case(lut_index)			  
		10'd   0: lut_data <= {1'h0,7'h00,8'hA0};  //80
		10'd   1: lut_data <= {1'h0,7'h00,8'h80};  //  soft reset	
		10'd   2: lut_data <= {1'h0,7'h03,8'h00};   //  complet-binary , word mode 
		10'd   3: lut_data <= {1'h0,7'h04,8'h00};  //  disable any interrupt 
		10'd   4: lut_data <= {1'h0,7'h05,8'h00};  //  disable any interrupt
		10'd   5: lut_data <= {1'h0,7'h08,8'hA0};  //  enable DACCLK input correct
		10'd   6: lut_data <= {1'h0,7'h0A,8'h00};  //  disable PLL
		10'd   7: lut_data <= {1'h0,7'h0C,8'h00};  //  PLL bandwith select, CP-current select
		10'd   8: lut_data <= {1'h0,7'h0D,8'h00};  //  PLL control parameter
		10'd   9: lut_data <= {1'h0,7'h10,8'h00};  // Sync disable
		10'd  10: lut_data <= {1'h0,7'h11,8'h00};  // Sync disable
		//第2位00：DCI信号延迟350 pS。 01：DCI信号延迟590 pS。 10：DCI信号延迟800 pS。 11：DCI信号延迟925 pS。
		10'd  11: lut_data <= {1'h0,7'h16,{6'd0,DAC_DCI_DELAY_MODE}};  
		10'd  12: lut_data <= {1'h0,7'h1B,{1'b1,BYPASS_NSINC,BYPASS_NCO,5'b0_0100}};  //第7位控制反sic滤波器开关，A4为打开反sic滤波器
		10'd  13: lut_data <= {1'h0,7'h1C,8'h00}; // HB1 select, enable interplot *2  mode = 00
		10'd  14: lut_data <= {1'h0,7'h1D,{1'b0,6'b000000,1'b0}}; // bypass HB2
		10'd  15: lut_data <= {1'h0,7'h1E,8'h01}; // bypass HB3
		10'd  14: lut_data <= {1'h0,7'h30,NCO_FTW[0 +:8]}; // NCO value FTW LSB 
		10'd  15: lut_data <= {1'h0,7'h31,NCO_FTW[8 +:8]}; // NCO value FTW 
		10'd  14: lut_data <= {1'h0,7'h32,NCO_FTW[16 +:8]}; // NCO value FTW 
		10'd  15: lut_data <= {1'h0,7'h33,NCO_FTW[24 +:8]}; // NCO value FTW  MSB
		10'd  14: lut_data <= {1'h0,7'h36,8'h01}; //  update NCO
		10'd  15: lut_data <= {1'h0,7'h36,8'h00}; // 
		10'd  16: lut_data <= {1'h0,7'h10,8'h48}; //  setup sync data rate
		10'd  17: lut_data <= {1'h0,7'h17,8'h04}; //  FIFO write pointer phase offset following FIFO reset.
		10'd  18: lut_data <= {1'h0,7'h18,8'h02}; // FIFO soft align acknowledge			
		default:lut_data <= {8'hff,8'hff};
	endcase
end


endmodule 
