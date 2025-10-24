//汉明码编码
// 实例化 hamming_encoder 模块
// hamming_encoder my_hamming_encoder (
//     .clk(clk),           // 时钟信号
//     .rst_n(rst_n),      // 复位信号
//     .wren(wren),        // 写使能信号
//     .data(data),        // 输入数据
//     .hc_out(hc_out)     // 校验输出
// );

module hamming_encoder(clk, rst, wren, data, hc_out,encode_valid);
   input clk, rst;
   input wren;
   input [7:0] data;
   output reg [11:0] hc_out;
   output reg encode_valid;

   wire p0, p1, p2, p3;
   
   assign p0 = data[6] ^ data[4] ^ data[3] ^ data[1] ^ data[0];
   assign p1 = data[6] ^ data[5] ^ data[3] ^ data[2] ^ data[0];
   assign p2 = data[7] ^ data[3] ^ data[2] ^ data[1];
   assign p3 = data[7] ^ data[6] ^ data[5] ^ data[4];
   
   always @ (posedge clk)begin
       if(wren)begin
            hc_out <= {data[7:4], p3, data[3:1],p2, data[0], p1, p0};
       end
       encode_valid<= wren ? 1 : 0;
    //    else	 
    //        hc_out <= 0;
   end

endmodule