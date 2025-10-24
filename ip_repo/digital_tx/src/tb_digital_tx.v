module tb_digital_tx();

// 时钟参数
localparam CLK_PERIOD = 10;  // 100MHz时钟
localparam DATA_WIDTH = 32; // 数据位宽

// 接口信号
reg clk;
reg rst;
reg i_valid;
reg [DATA_WIDTH-1:0] i_data;
reg [31:0] i_data_num;
reg i_tx_start;
initial begin
    // 复位初始化
    rst = 1;
    i_valid = 0;
    i_data = 0;
    i_data_num = 0;
    i_tx_start = 0;
    #10;
    rst = 0;
    #100;
    i_data_num = 2;
    i_data = {8'd4,8'd3,8'd2,8'd1};
    i_valid = 1;
    #10
    i_valid = 0;
    #10
    i_data = {8'd8,8'd7,8'd6,8'd5};
    i_valid = 1;
    #10
    i_valid = 0;
    #100
    i_tx_start = 1;
    #10
    i_tx_start = 0;
    #10000 $finish;
end
// 例化被测设计
digital_tx DUT (
    .clk(clk),
    .rst(rst),
    .i_valid(i_valid),
    .i_data(i_data),
    .i_data_num(i_data_num),
    .i_tx_start(i_tx_start)
);

// 生成时钟
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

endmodule