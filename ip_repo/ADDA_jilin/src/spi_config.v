
module spi_config
(
	input              rst,
	input              clk,
	input[15:0]        clk_div_cnt,
	output reg[9:0]    lut_index,
	input[15:0]        lut_reg_addr,
	input[7:0]         lut_reg_data,
	output reg         error,
	output             done,
	input				pll_check,
	output				pll_locked,
	output             spi_ce,
	output             spi_sclk,
	output              spi_dir,
	input			   spi_in,
	output			   spi_out
);

reg spi_read_req;
wire spi_read_req_ack;
reg spi_write_req;
wire spi_write_req_ack;
wire[13:0] spi_slave_reg_addr;
wire[7:0] spi_write_data;
wire[7:0] spi_read_data;
reg read_check_error ;

reg [31:0]	 spi_cnt ;
reg [7:0]	 pll_readback ;
wire err;
reg[3:0] state;

localparam S_IDLE                =  0;
localparam S_WR_SPI_CHECK        =  1;
localparam S_WR_SPI              =  2;
localparam S_RD_SPI_CHECK        =  3;
localparam S_RD_SPI              =  4;
localparam S_WR_SPI_DONE         =  5;
localparam S_WR_SPI_DONE1        =  10;
localparam S_WR_TEST             =  6;
localparam S_RD_TEST             =  7;
localparam S_PLL_STATUS_CHECK             =  8;
localparam S_PLL_SPI            =  9;

assign done = (state == S_WR_SPI_DONE);
assign spi_slave_reg_addr = (state == S_PLL_STATUS_CHECK || state == S_PLL_SPI)?13'h1F:lut_reg_addr[12:0];
assign spi_write_data  = lut_reg_data;

assign pll_locked = pll_readback[0] ;

always@(posedge clk or posedge rst)
begin
	if(rst)
	begin
		state <= S_IDLE;
		error <= 1'b0;
		lut_index <= 8'd0;
		read_check_error <= 1'b0 ;
		spi_cnt <= 0 ;
		pll_readback <= 0 ;
	end
	else 
		case(state)
			S_IDLE:
			begin
				state <= S_WR_SPI_CHECK;
				error <= 1'b0;
				lut_index <= 8'd0;
			end
			S_WR_TEST:
			begin
				if(spi_write_req_ack)
				begin
					spi_write_req <= 1'b0;
					state <= S_RD_TEST;
				end
				else
				begin
					spi_write_req <= 1'b1;
				end
			end
			S_RD_TEST:
			begin
				if(spi_read_req_ack)
				begin
					spi_read_req <= 1'b0;
					state <= S_WR_TEST;
				end
				else
				begin
					spi_read_req <= 1'b1;
				end
			end
			
			S_WR_SPI_CHECK:
			begin
				if(spi_slave_reg_addr != 13'h1fff)
				begin
					spi_write_req <= 1'b1;
					state <= S_WR_SPI;
				end
				else
				begin
					state <= S_RD_SPI_CHECK;
					lut_index <= 8'd0;
				end
			end
			S_WR_SPI:
			begin
				if(spi_write_req_ack)
				begin
					lut_index <= lut_index + 8'd1;
					spi_write_req <= 1'b0;
					state <= S_WR_SPI_CHECK;
				end
			end			
			S_RD_SPI_CHECK:
			begin
				if(spi_slave_reg_addr != 13'h1fff)
				begin
					spi_read_req <= 1'b1;
					state <= S_RD_SPI;
				end
				else
				begin
					if (pll_check == 1'b1)						
						state <= S_PLL_STATUS_CHECK;
					else
						state <= S_WR_SPI_DONE;
				end
				read_check_error <= 1'b0 ;
			end
			S_RD_SPI:
			begin
				if(spi_read_req_ack)
				begin
					if (spi_read_data != lut_reg_data)
						read_check_error <= 1'b1 ;
						
					lut_index <= lut_index + 8'd1;
					spi_read_req <= 1'b0;
					state <= S_RD_SPI_CHECK;
				end
			end
			S_PLL_STATUS_CHECK:
			begin
				if(spi_cnt >= 50_000_000)
				begin
					spi_read_req <= 1'b1;
					spi_cnt <= 0 ;
					state <= S_PLL_SPI;
				end
				else
				begin
					spi_cnt <= spi_cnt + 1'b1 ;
				end
			end
			S_PLL_SPI:
			begin
				if(spi_read_req_ack)
				begin						
					spi_read_req <= 1'b0;
					pll_readback <= spi_read_data ;
					state <= S_PLL_STATUS_CHECK;
				end
			end
			
			
			S_WR_SPI_DONE:
			begin				
				state <= S_WR_SPI_DONE1;
			end
			
			S_WR_SPI_DONE1:
			begin				
				state <= S_WR_SPI_DONE1;
			end		
				
			default:
				state <= S_IDLE;
		endcase
end

adc_spi adc_spi_m0(
	.clk             (clk                 ),
	.rst             (rst                 ),
	.spi_ce          (spi_ce              ),
	.spi_sclk        (spi_sclk            ),
	.spi_dir          (spi_dir              ),
	.spi_in          (spi_in              ),
	.spi_out         (spi_out              ),
	.cmd_read        (spi_read_req        ),
	.cmd_write       (spi_write_req       ),
	.cmd_read_ack    (spi_read_req_ack    ),
	.cmd_write_ack   (spi_write_req_ack   ),
	.read_addr       (spi_slave_reg_addr ),
	.write_addr      (spi_slave_reg_addr  ),
	.read_data       (spi_read_data       ),
	.write_data      (spi_write_data      )
);
endmodule