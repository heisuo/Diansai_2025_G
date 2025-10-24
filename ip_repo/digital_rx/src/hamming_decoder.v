//汉明码解码

    // hamming_decoder hamming_decoder_inst (
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .rden(rden),
    //     .q(q),
    //     .decode_valid(decode_valid),
    //     .hc_in(hc_in)
    // );
`timescale 1ns / 1ps
module hamming_decoder(clk, rden, q, hc_in,decode_valid,error_pulse);

   input clk;
   input rden;
   output reg [7:0] q;
   output reg decode_valid;
   output reg error_pulse;
   input [11:0] hc_in;
   wire [3:0]error;
   wire g0_error, g1_error, g2_error,g3_error;
   assign error={g3_error, g2_error, g1_error, g0_error};
   assign g0_error = hc_in[10] ^ hc_in[8] ^ hc_in[6] ^ hc_in[4] ^ hc_in[2] ^ hc_in[0];
   assign g1_error = hc_in[10] ^ hc_in[9] ^ hc_in[6] ^ hc_in[5] ^ hc_in[2] ^ hc_in[1];
   assign g2_error = hc_in[11] ^ hc_in[6] ^ hc_in[5] ^ hc_in[4] ^ hc_in[3];
   assign g3_error = hc_in[11] ^ hc_in[10] ^ hc_in[9] ^ hc_in[8] ^ hc_in[7];
   
   always @ (posedge clk)begin
       if(rden)begin
           case (error)
               4'b0000 :   q <= {hc_in[11:8], hc_in[6:4], hc_in[2]};
               4'b0001 :   q <= {hc_in[11:8], hc_in[6:4], hc_in[2]};
               4'b0010 :   q <= {hc_in[11:8], hc_in[6:4], hc_in[2]};
               4'b0011 :   q <= {hc_in[11:8], hc_in[6:4], ~hc_in[2]};
               4'b0100 :   q <= {hc_in[11:8], hc_in[6:4], hc_in[2]};
               4'b0101 :   q <= {hc_in[11:8], hc_in[6:5], ~hc_in[4], hc_in[2]};
               4'b0110 :   q <= {hc_in[11:8], hc_in[6], ~hc_in[5], hc_in[4], hc_in[2]};
               4'b0111 :   q <= {hc_in[11:8], ~hc_in[6], hc_in[5], hc_in[4], hc_in[2]};
               4'b1000 :   q <= {hc_in[11:8], hc_in[6], hc_in[5], hc_in[4], hc_in[2]};
               4'b1001 :   q <= {hc_in[11:9], ~hc_in[8], hc_in[6:4], hc_in[2]};
               4'b1010 :   q <= {hc_in[11:10], ~hc_in[9], hc_in[8], hc_in[6:4], hc_in[2]};
               4'b1011 :   q <= {hc_in[11], ~hc_in[10], hc_in[9], hc_in[8], hc_in[6:4], hc_in[2]};
               4'b1100 :   q <= {~hc_in[11], hc_in[10], hc_in[9], hc_in[8], hc_in[6:4], hc_in[2]};
               default :   q <= 0;
           endcase
       end
       decode_valid<=rden;
       error_pulse<=rden ? (error==4'b1101 | error==4'b1110 | error==4'b1111) : 0;
    //    else
    //        q <= 0;
   end

endmodule