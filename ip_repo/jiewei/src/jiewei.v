//截位模块，实现快速截位
module jiewei #(
    parameter INPUT_DATA_WIDTH=16,
    parameter OUTPUT_DATA_WIDTH=16,
    parameter HSB = 15
)(
    input [INPUT_DATA_WIDTH-1:0]i_data,
    output [OUTPUT_DATA_WIDTH-1:0]o_jie_data
);
assign o_jie_data=i_data[HSB -:OUTPUT_DATA_WIDTH];
endmodule