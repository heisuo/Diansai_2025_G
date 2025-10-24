
module adc_spi8
(
	input           clk,
	input           rst,
	output          spi_ce,
	output          spi_sclk,
	output          spi_dir,
	input			spi_in,
	output			spi_out,
	input           cmd_read,
	input           cmd_write,
	output          cmd_read_ack,
	output          cmd_write_ack,
	input[6:0]     read_addr,
	input[6:0]     write_addr,
	output reg[7:0] read_data,
	input[7:0]      write_data
);
localparam S_IDLE         =  0;
localparam S_CE_HIGH      =  1;
localparam S_READ         =  2;
localparam S_READ_ADDR0   =  3;
localparam S_READ_DATA    =  5;
localparam S_WRITE        =  6;
localparam S_WRITE_ADDR0  =  7;
localparam S_WRITE_DATA   =  9;
localparam S_CE_LOW       = 10;
localparam S_ACK          = 11;

reg[3:0] state, next_state;
reg[19:0] delay_cnt;
reg wr_req;
wire wr_ack;
reg wr_ack_d0;
reg CS_reg;
wire DCLK;
wire MOSI;
wire MISO;
reg[7:0] send_data;
wire[7:0] data_rec;
reg io_dir;

assign spi_dir = io_dir ;
assign MISO = spi_in;
assign spi_out = MOSI;



assign spi_sclk = DCLK;
assign cmd_read_ack = (state == S_ACK);
assign cmd_write_ack = (state == S_ACK);
always@(posedge clk or posedge rst)
begin
	if(rst)
		state <= S_IDLE;
	else
		state <= next_state;
end
always@(*)
begin
	case(state)
		S_IDLE:
			if(cmd_read || cmd_write)
				next_state <= S_CE_LOW;
			else
				next_state <= S_IDLE;
		S_CE_LOW:
			if(delay_cnt == 20'd255)
				next_state <= cmd_read ? S_READ : S_WRITE;
			else
				next_state <= S_CE_LOW;
		S_READ:
			next_state <= S_READ_ADDR0;
		S_READ_ADDR0:
			if(wr_ack)
				next_state <= S_READ_DATA;
			else
				next_state <= S_READ_ADDR0;
		S_READ_DATA:
			if(wr_ack)
				next_state <= S_ACK;
			else
				next_state <= S_READ_DATA;
		S_WRITE:
			next_state <= S_WRITE_ADDR0;
		S_WRITE_ADDR0:
			if(wr_ack)
				next_state <= S_WRITE_DATA;
			else
				next_state <= S_WRITE_ADDR0;		
		S_WRITE_DATA:
			if(wr_ack)
				next_state <= S_ACK;
			else
				next_state <= S_WRITE_DATA;
		S_ACK:
			next_state <= S_CE_HIGH;
		S_CE_HIGH:
			if(delay_cnt == 20'd255)
				next_state <= S_IDLE;
			else
				next_state <= S_CE_HIGH;
		default:next_state <= S_IDLE;
	endcase
end
always@(posedge clk or posedge rst)
begin
	if(rst)
		delay_cnt <= 20'd0;
	else if(state == S_CE_HIGH || state == S_CE_LOW)
		delay_cnt <= delay_cnt + 20'd1;
	else
		delay_cnt <= 20'd0;
end
always@(posedge clk or posedge rst)
begin
	if(rst)
		wr_req <= 1'b0;
	else if(wr_ack)
		wr_req <= 1'b0;
	else if(state == S_READ_ADDR0  || state == S_READ_DATA || state == S_WRITE_ADDR0  || state == S_WRITE_DATA)
		wr_req <= 1'b1;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		io_dir <= 1'b0;
	else
		io_dir <= (state == S_READ_DATA);
end
always@(posedge clk or posedge rst)
begin
	if(rst)
		CS_reg <= 1'b0;
	else if(state == S_CE_HIGH)
		CS_reg <= 1'b1;
	else if(state == S_CE_LOW)
		CS_reg <= 1'b0;
end
always@(posedge clk or posedge rst)
begin
	if(rst)
		read_data <= 8'h00;
	else if(state == S_READ_DATA && wr_ack)
		read_data <= data_rec;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		send_data <= 8'h00;
	else if(state == S_READ_ADDR0)
		send_data <= {1'b1,read_addr[6:0]};		
	else if(state == S_WRITE_ADDR0)
		send_data <= {1'b0,write_addr[6:0]};
	else if(state == S_WRITE_DATA)
		send_data <= write_data;
end
spi_master8 spi_master_m0(
	.sys_clk(clk),
	.rst(rst),
	.nCS(spi_ce),
	.DCLK(DCLK),
	.MOSI(MOSI),
	.MISO(MISO),
	.CPOL(1'b0),
	.CPHA(1'b0),
	.nCS_ctrl(CS_reg),
	.clk_div(16'd50),
	.wr_req(wr_req),
	.wr_ack(wr_ack),
	.data_in(send_data),
	.data_out(data_rec)
);
endmodule