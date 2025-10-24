
`timescale 1 ns / 1 ps

	module ps_axi_ctrl_new #
	(
		// Users to add parameters here
		parameter EN_bram=1,
		parameter EN_costas=1,
		parameter EN_gardner=1,
		parameter EN_digital_tx=1,
		parameter EN_digital_rx=1,
		parameter Common_i_num=0,
		parameter Common_o_num=0,
		parameter EN_Search_PP=1,
		parameter EN_AM_mod=1,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 8
	)
	(
		// Users to add ports here
		//bram采集
		input i_pl2ps_done_pulse,//完成一次传输的标志位
		output o_pl2ps_start_pulse,//开始脉冲
	    output [31:0]o_data_len,//采样的数据点数
    	// output o_clear_done_flag_pulse,//清除标志位
		output [31:0]o_start_addr,//bram采集开始地址
		output [31:0]o_channel_sel,//通道选择
		//costas控制
		output [31:0]o_costas_ftw_ini,//初始频率字
		output o_costas_rework_pulse,//重新工作脉冲
		output [31:0]o_costas_PLL_C1,//两个环路参数
		output [31:0]o_costas_PLL_C2,
		output [31:0]o_costas_jiange,//costas环采样间隔
		//gardner
		output [31:0]o_gardner_FTW,//设置为待采样数据符号速率的4倍
		//digital_tx
		output o_tx_start_pulse,//发射开始脉冲
		output o_tx_valid,		//数据有效脉冲，一个脉冲存一个数据到fifo
		input i_tx_end_pulse,	//发射结束脉冲
		output [31:0]o_tx_FTW,	//符号速率频率字
		output [31:0]o_tx_data_num,//输出数据总量
		output [31:0]o_tx_data,//输出数据
		//digital_rx
		output o_rx_start_pulse,
		output o_rx_rd_pulse,
		input i_rx_end_pulse,
		input i_rx_error_pulse,
		input [31:0]i_rx_num,
		input [31:0]i_rx_data,
		//DDS
		output [31:0]o_DDS_FTW,//DDS频率字
		//通用寄存器
		output [31:0]o_common_data0,
		output [31:0]o_common_data1,
		output [31:0]o_common_data2,
		output [31:0]o_common_data3,
		output [31:0]o_common_data4,
		output [31:0]o_common_data5,
		output [31:0]o_common_data6,
		output [31:0]o_common_data7,
		input [31:0]i_common_data0,
		input [31:0]i_common_data1,
		input [31:0]i_common_data2,
		input [31:0]i_common_data3,
		input [31:0]i_common_data4,
		input [31:0]i_common_data5,
		input [31:0]i_common_data6,
		input [31:0]i_common_data7,
		//Search_PP
		output o_search_start_pulse,
		input i_search_end_pulse,
		output [31:0]o_search_time,
		input [31:0]i_search_max,
		input [31:0]i_search_min,
		//AM、DSB(BPSK)
		output [31:0]o_AMmod_FTW,
		output [31:0]o_AMmod_zoom,
		//FFT_learn
		output o_start_FFT_pulse,
		input i_FFT_end_pulse,
		output [31:0]o_FFT_index,
		output [31:0]o_mode,
		input [31:0]i_FFT1_I,
		input [31:0]i_FFT1_Q,
		input [31:0]i_FFT2_I,
		input [31:0]i_FFT2_Q,
		output [31:0]o_FFT_phase_sin,
		output [31:0]o_FFT_phase_cos,
		output [31:0]o_FFT_zoom_data,
		output [31:0]o_FFT_wr_addr,
		output [31:0]o_FFT_ram_wea,
		//OUT sel
		output [31:0]o_zoom_factor,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
	ps_axi_ctrl_new_slave_lite_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) ps_axi_ctrl_new_slave_lite_v1_0_S00_AXI_inst (
		//bram
		.i_pl2ps_done_pulse(i_pl2ps_done_pulse),
		.o_pl2ps_start_pulse(o_pl2ps_start_pulse),
		.o_data_len(o_data_len),
		// .o_clear_done_flag_pulse(o_clear_done_flag_pulse),
		.o_start_addr(o_start_addr),
		.o_channel_sel(o_channel_sel),
		//costas控制
		.o_costas_ftw_ini(o_costas_ftw_ini),
		.o_costas_rework_pulse(o_costas_rework_pulse),
		.o_costas_PLL_C1(o_costas_PLL_C1),
		.o_costas_PLL_C2(o_costas_PLL_C2),
		.o_costas_jiange(o_costas_jiange),
		//gardner
		.o_gardner_FTW(o_gardner_FTW),
		//digital_tx
		.o_tx_start_pulse(o_tx_start_pulse),
		.o_tx_valid(o_tx_valid),
		.i_tx_end_pulse(i_tx_end_pulse),
		.o_tx_FTW(o_tx_FTW),
		.o_tx_data_num(o_tx_data_num),
		.o_tx_data(o_tx_data),
		//digital_rx
		.o_rx_start_pulse(o_rx_start_pulse),
		.o_rx_rd_pulse(o_rx_rd_pulse),
		.i_rx_end_pulse(i_rx_end_pulse),
		.i_rx_error_pulse(i_rx_error_pulse),
		.i_rx_num(i_rx_num),
		.i_rx_data(i_rx_data),
		//DDS
		.o_DDS_FTW(o_DDS_FTW),
		//通用寄存器
		.o_common_data0(o_common_data0),
		.o_common_data1(o_common_data1),
		.o_common_data2(o_common_data2),
		.o_common_data3(o_common_data3),
		.o_common_data4(o_common_data4),
		.o_common_data5(o_common_data5),
		.o_common_data6(o_common_data6),
		.o_common_data7(o_common_data7),
		.i_common_data0(i_common_data0),
		.i_common_data1(i_common_data1),
		.i_common_data2(i_common_data2),
		.i_common_data3(i_common_data3),
		.i_common_data4(i_common_data4),
		.i_common_data5(i_common_data5),
		.i_common_data6(i_common_data6),
		.i_common_data7(i_common_data7),
		//Search_PP
		.o_search_start_pulse(o_search_start_pulse),
		.i_search_end_pulse(i_search_end_pulse),
		.o_search_time(o_search_time),
		.i_search_max(i_search_max),
		.i_search_min(i_search_min),
		//AM、DSB(BPSK)
		.o_AMmod_FTW(o_AMmod_FTW),
		.o_AMmod_zoom(o_AMmod_zoom),
		//FFT_learn
		.o_start_FFT_pulse(o_start_FFT_pulse),
		.i_FFT_end_pulse(i_FFT_end_pulse),
		.o_FFT_index(o_FFT_index),
		.o_mode(o_mode),
		.i_FFT1_I(i_FFT1_I),
		.i_FFT1_Q(i_FFT1_Q),
		.i_FFT2_I(i_FFT2_I),
		.i_FFT2_Q(i_FFT2_Q),
		.o_FFT_phase_sin(o_FFT_phase_sin),
		.o_FFT_phase_cos(o_FFT_phase_cos),
		.o_FFT_zoom_data(o_FFT_zoom_data),
		.o_FFT_wr_addr(o_FFT_wr_addr),
		.o_FFT_ram_wea(o_FFT_ram_wea),
		//OUT sel
		.o_zoom_factor(o_zoom_factor),
		//AXI_lite
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
