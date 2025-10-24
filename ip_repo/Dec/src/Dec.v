//抽值模块，直接抽值
//适合噪声和谐波比较小的情况
module Dec #(
    parameter DATA_WIDTH=16,
    parameter DIV_NUM = 10
)(
    input clk,
    input rst,
    input i_valid,
    input [DATA_WIDTH-1:0]i_data,
    output reg o_Dec_valid,
    output reg [DATA_WIDTH-1:0]o_Dec_data
);
reg [$clog2(DIV_NUM)-1:0]div_cnt;
always @(posedge clk ) begin
    if(rst)begin
        div_cnt<=0;
    end
    else if(i_valid)
        div_cnt <= (div_cnt==DIV_NUM-1) ? 0 : (div_cnt+1);
end
always @(posedge clk ) begin
    o_Dec_valid<=(i_valid & div_cnt==DIV_NUM-1);
    o_Dec_data<=(i_valid & div_cnt==DIV_NUM-1) ? i_data : o_Dec_data;
end
endmodule