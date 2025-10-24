`timescale 1ns / 1ps

module spi_config_top(
input              clk_50m,
input              locked,
    //spi    
	output  spi_clk,    
	inout   spi_io,     
    //AD9516
	output  clk_spi_ce,	
	//AD9643
	output  adc_spi_ce,
	output  dac_spi_ce,	
	
output     [9:0]   adc_lut_index,
input     [24:0]   adc_lut_data,
output     [9:0]   dac_lut_index,
input     [15:0]   dac_lut_data,
output     [9:0]   clk_lut_index,
input     [24:0]   clk_lut_data ,
output      reg    done_flag

    );
    
    
     wire               pll_check;
     wire               done0;
     reg                done0_r;
     wire               done1;
     reg                done1_r;
     wire               done2;
     reg                done2_r;    
     wire               done3;
     reg                done3_r;             
     wire               done0_pos;
     wire               done1_pos;
     wire               done2_pos;
     wire               done3_pos;     
     reg                spi_st;
     reg    [3:0]       done_cnt; 
      
     wire                ak_spi_ce;
     wire                ak_spi_dir  ;
     wire			     ak_spi_in   ;
     wire			     ak_spi_out  ;
      wire			     ak_spi_clk  ;
          
     wire               ad_spi_ce;
     wire               ad_spi_dir  ;
     wire			    ad_spi_in   ;
     wire			    ad_spi_out  ;          
     wire			    ad_spi_clk  ;    
     
     wire               da_spi_ce;
     wire               da_spi_dir  ;
     wire			    da_spi_in   ;
     wire			    da_spi_out  ;          
     wire			    da_spi_clk  ;     
     
     wire               da1_spi_ce;
     wire               da1_spi_dir  ;
     wire			    da1_spi_in   ;
     wire			    da1_spi_out  ;          
     wire			    da1_spi_clk  ;              
  
assign  pll_check=0;

assign  spi_clk=(done_cnt==0)?ak_spi_clk:
                (done_cnt==1)?ad_spi_clk:
                (done_cnt==2)?da_spi_clk:
                (done_cnt==3)?da1_spi_clk:0;

assign  clk_spi_ce =(done_cnt==0)?  ak_spi_ce:1;
assign  adc_spi_ce=(done_cnt==1)?   ad_spi_ce:1;
assign  dac_spi_ce=(done_cnt==2)?   da_spi_ce:(done_cnt==3)?   da1_spi_ce:1;

assign spi_io = (done_cnt==0)?(~ak_spi_dir  ? ak_spi_out : 1'bz):
                (done_cnt==1)?(~ad_spi_dir ? ad_spi_out : 1'bz):
                (done_cnt==2)?(~da_spi_dir ? da_spi_out : 1'bz):
                (done_cnt==3)?(~da1_spi_dir ? da1_spi_out : 1'bz):1'bz;
                
assign ak_spi_in = spi_io;     
assign ad_spi_in = spi_io;    
assign da_spi_in = spi_io;   
assign da1_spi_in = spi_io;   

assign done0_pos= (!done0_r)&&done0; 
always@(posedge clk_50m )done0_r<=done0;

assign done1_pos= (!done1_r)&&done1; 
always@(posedge clk_50m )done1_r<=done1;

assign done2_pos= (!done2_r)&&done2; 
always@(posedge clk_50m )done2_r<=done2;

assign done3_pos= (!done3_r)&&done3; 
always@(posedge clk_50m )done3_r<=done3;

always@(posedge clk_50m )begin
    if(!locked)begin
        spi_st<=1;
        done_cnt<=0;
        done_flag<=0;
    end
    else begin
    case(done_cnt)
    0:begin
         if(done0_pos)begin
             spi_st<=1;
             done_cnt<=done_cnt+1;
         end
         else begin
             spi_st<=0;
             done_cnt<=done_cnt;      
         end
    end
     1:begin
         if(done1_pos)begin
             spi_st<=1;
             done_cnt<=done_cnt+1;
         end
         else begin
             spi_st<=0;
             done_cnt<=done_cnt;      
         end
    end   
     2:begin
         if(done2_pos)begin
             spi_st<=1;
             done_cnt<=done_cnt+1;
         end
         else begin
             spi_st<=0;
             done_cnt<=done_cnt;      
         end
    end    
     3:begin
         if(done3_pos)begin
             done_cnt<=done_cnt+1;
         end
         else begin
             spi_st<=0;
             done_cnt<=done_cnt;      
         end
    end          
    4:begin
           spi_st<=0;
           done_cnt<=done_cnt; 
           done_flag<=1;    
    end
    default:begin
        spi_st<=1;
        done_cnt<=0; 
    end
    endcase
    end
end  


spi_config u0(
	.rst                        (spi_st              ),
	.clk                        (clk_50m             ),
	.clk_div_cnt                (16'd500             ),
	.lut_index                  (clk_lut_index           ),
	.lut_reg_addr               (clk_lut_data[23:8]      ),
	.lut_reg_data               (clk_lut_data[7:0]       ),
	.pll_check                  ( pll_check          ),
	.pll_locked                 (          ),
	.error                      (                    ),
	.done                       (done0                ),	
	.spi_ce                     (ak_spi_ce              ),
	.spi_sclk                   (ak_spi_clk             ),
	.spi_dir          			(ak_spi_dir             ),
	.spi_in          			(ak_spi_in              ),
	.spi_out         			(ak_spi_out             )
);   

spi_config u1(
	.rst                        (spi_st              ),
	.clk                        (clk_50m             ),
	.clk_div_cnt                (16'd500             ),
	.lut_index                  (adc_lut_index           ),
	.lut_reg_addr               (adc_lut_data[23:8]      ),
	.lut_reg_data               (adc_lut_data[7:0]       ),
	.pll_check                  ( pll_check          ),
	.pll_locked                 (          ),
	.error                      (                    ),
	.done                       (done1                ),	
	.spi_ce                     (ad_spi_ce              ),
	.spi_sclk                   (ad_spi_clk             ),
	.spi_dir          			(ad_spi_dir             ),
	.spi_in          			(ad_spi_in              ),
	.spi_out         			(ad_spi_out             )
);     

spi_config8 u2(
	.rst                        (spi_st              ),
	.clk                        (clk_50m             ),
	.clk_div_cnt                (16'd500             ),
	.lut_index                  (dac_lut_index           ),
	.lut_reg_addr               (dac_lut_data[15:8]      ),
	.lut_reg_data               (dac_lut_data[7:0]       ),
	.pll_check                  ( pll_check          ),
	.pll_locked                 (                    ),
	.error                      (                    ),
	.done                       (done2                    ),	
	.spi_ce                     (da_spi_ce              ),
	.spi_sclk                   (da_spi_clk             ),
	.spi_dir          			(da_spi_dir             ),
	.spi_in          			(da_spi_in              ),
	.spi_out         			(da_spi_out             )
);   

spi_config8r u3(
	.rst                        (spi_st              ),
	.clk                        (clk_50m             ),
	.clk_div_cnt                (16'd500             ),
	.pll_check                  ( pll_check          ),
	.pll_locked                 (                    ),
	.error                      (                    ),
	.done                       (done3                    ),	
	.spi_ce                     (da1_spi_ce              ),
	.spi_sclk                   (da1_spi_clk             ),
	.spi_dir          			(da1_spi_dir             ),
	.spi_in          			(da1_spi_in              ),
	.spi_out         			(da1_spi_out             )
);   
endmodule
