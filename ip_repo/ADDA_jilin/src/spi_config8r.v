`timescale 1ns / 1ps

module spi_config8r(
	input              rst,
	input              clk,
	input[15:0]        clk_div_cnt,
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


reg[6:0] spi_slave_reg_addr;
reg[7:0] spi_write_data;


reg[6:0] spi_slave_rd_reg_addr;

wire[7:0] spi_read_data;
reg read_check_error ;

reg [31:0]	 spi_cnt ;
reg [7:0]	 pll_readback ;
wire err;
reg[5:0] state;

localparam S_IDLE                =  0;
localparam S_WR_SPI_CHECK        =  1;
localparam S_WR_SPI              =  2;
localparam S_WR_SPI_CHECK1       =  3;
localparam S_WR_SPI1             =  4;
localparam S_RD_SPI_CHECK        =  5;
localparam S_RD_SPI              =  6;

localparam S_WR_SPI_CHECK2        =  7;
localparam S_WR_SPI2              =  8;
localparam S_RD_SPI_CHECK1        =  9;
localparam S_RD_SPI1              =  10;
localparam S_WR_SPI_DONE          =  11;
localparam S_WR_SPI_DONE1          =  12;



assign done = (state == S_WR_SPI_DONE);

assign pll_locked = pll_readback[0] ;

always@(posedge clk or posedge rst)
begin
	if(rst)
	begin
		state <= S_IDLE;
		error <= 1'b0;
		spi_slave_reg_addr<=0;
        spi_write_data<=0;    
		read_check_error <= 1'b0 ;
		spi_cnt <= 0 ;
		pll_readback <= 0 ;
	end
	else 
		case(state)
			S_IDLE:
			begin
				state <= S_RD_SPI_CHECK;
				error <= 1'b0;
                spi_slave_reg_addr<=0;
                spi_write_data<=0;    
			end

			S_RD_SPI_CHECK:
			begin
					spi_read_req <= 1'b1;
					state <= S_RD_SPI;
					spi_slave_rd_reg_addr<=7'h18;
			end
			S_RD_SPI:
			begin
				if(spi_read_req_ack)
				begin
					if (spi_read_data == 7'h07)begin
					   state <= S_WR_SPI_CHECK2;
					end
					else begin
					   state <= S_RD_SPI_CHECK;
					end
					spi_read_req <= 1'b0;
				end
			end			
			
			S_WR_SPI_CHECK2:
			begin
					spi_write_req <= 1'b1;
					state <= S_WR_SPI2;
					spi_slave_reg_addr<=7'h18;
			end
			S_WR_SPI2:
			begin
				if(spi_write_req_ack)
				begin
                    spi_write_data<=0;   
					spi_write_req <= 1'b0;
					state <= S_RD_SPI_CHECK1;
				end
			end	//*/			
			
			S_RD_SPI_CHECK1:
			begin
					spi_read_req <= 1'b1;
					state <= S_RD_SPI1;
					spi_slave_rd_reg_addr<=7'h19;
			end
			S_RD_SPI1:
			begin
				if(spi_read_req_ack)
				begin
					if(spi_read_data > 7'h02)begin
					   state <= S_WR_SPI_DONE;
					end
					else begin
					   state <= S_RD_SPI_CHECK1;
					end
					spi_read_req <= 1'b0;
				end
			end				
									
			S_WR_SPI_DONE:  state <= S_WR_SPI_DONE1;

			S_WR_SPI_DONE1:	state <= S_WR_SPI_DONE1;
		
			default:	state <= S_IDLE;
		endcase
end

adc_spi8 adc_spi_m0(
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
	.read_addr       (spi_slave_rd_reg_addr ),
	.write_addr      (spi_slave_reg_addr  ),
	.read_data       (spi_read_data       ),
	.write_data      (spi_write_data      )
);

endmodule