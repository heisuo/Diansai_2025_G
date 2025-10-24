

module ad9643_config#(
    parameter ADC_DCO_DELAY = 5'd15              //[4:0] :delay_value   [delay = (3100 ps * delay_value/31 +100)]
)(
	input[9:0]             lut_index,   //Look-up table address
	output reg[24:0]       lut_data     //reg address reg data
);

always@(*)
begin
	case(lut_index)			  
		10'd  0: lut_data <= {16'h0005 , 8'h03};  //channel index [1]:ADC B Enable  [0]:ADC A Enable
		10'd  1: lut_data <= {16'h0008 , 8'h00};  //power modes [5]:External power-down 0=power-down 1=standby [1:0]:internal power-down mode 00=normal operation 01=full power-down 10=standby 11=reserved
		10'd  2: lut_data <= {16'h0009 , 8'h01};  //global clock [0]:duty cycle stabilizer 0=disable 1=enable 
		10'd  3: lut_data <= {16'h000B , 8'h00};  //clock divide [5:3]:input clock divider phase adjust  [2:0]:clock divide ratio (refer to datasheet) 
		10'd  4: lut_data <= {16'h000D , 8'h00};  //test mode control 
		10'd  5: lut_data <= {16'h0010 , 8'h00};  //offset adjust
		10'd  6: lut_data <= {16'h0014 , 8'h05};  //output mode [1:0]:output format 00=offset binary 01= twos complement(default) 10= gray code
		10'd  7: lut_data <= {16'h0015 , 8'h01};  //output adjust, [3:0] LVDS output drive current adjust
		10'd  8: lut_data <= {16'h0016 , 8'h00};  //clock phase control [7]:invert DCO clock
		10'd  9: lut_data <= {16'h0017 , 1'b1 ,{2'd0,ADC_DCO_DELAY}};  //DCO clock delay [7]: enable delay [4:0] :delay_value   [delay = (3100 ps * delay_value/31 +100)] 
		10'd 10: lut_data <= {16'h0018 , 8'h00};  //input span select [4:0]: full scale input voltage selection 00000=1.75Vp-p(default) 
		10'd 11: lut_data <= {16'h00FF , 8'h01};  //write transfer bit (for configurations that require a manual transfer) 
		default:lut_data <= {16'hffff,8'hff};
	endcase
end


endmodule 