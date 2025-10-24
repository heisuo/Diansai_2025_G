module AGC#(
    parameter INT_WIDTH=10,//整数放大位宽，该值决定AGC最大的放大倍数
    parameter DEC_WIDTH=8,//小数放大位宽，该值决定AGC的输出精度,也决定AGC最大的缩小倍数
    //收敛因子，该值决定了积分截位位宽的大小，值越小收敛越快，但越不稳定
    //该值的意义是AGC的最大步进倍数，比如shoulian_factor=4,则表示AGC1次迭代'最大'的倍数是1/2的4次方倍
    //shoulian_factor=jifen_LSB_WIDTH+DEC_WIDTH-10,
    parameter shoulian_factor=6,
    parameter WINDOW_WIDTH = 8,//滑动平均窗口位宽
    parameter en_sample_interval = 0,//使能采样间隔
    parameter en_debug=0,//是能dubug端口
    parameter INPUT_DATA_WIDTH = 16, //输入数据位宽
    parameter OUTPUT_DATA_WIDTH = 16
)(
    input clk,
    input rst,
    //debug
    output [9:0]debug_w_range,
    output [10:0]debug_error_data,
    input [7:0]i_sample_interval,//采样间隔
    input [9:0]i_ref_data,   //基准信号,取10位，主要是和1000很接近
    input [INPUT_DATA_WIDTH-1:0]i_AGC_data,
    input i_AGC_valid,
    output [OUTPUT_DATA_WIDTH-1:0]o_AGC_data,
    output o_AGC_valid
);
localparam jifen_LSB_WIDTH=shoulian_factor+10-DEC_WIDTH;//积分截位位宽
localparam jifen_all_width=jifen_LSB_WIDTH+DEC_WIDTH+INT_WIDTH;//积分的总位宽
localparam jifen_jie_width=DEC_WIDTH+INT_WIDTH;//积分输出的位宽
//输入与积分相乘后的位宽, = 小数放大位宽加+数据位宽
//比如要稳定的幅度在1倍左右，其实就相当于左移DEC_WIDTH位并截位，此时数值不变
localparam mult_width=DEC_WIDTH+INPUT_DATA_WIDTH;
wire signed [INPUT_DATA_WIDTH-1:0]i_AGC_data;

//相乘并输出
reg signed[INT_WIDTH+mult_width-1:0]r_temp_mult_data;//存储相乘的中间结果，主要是为了防止溢出导致AGC不稳定
reg signed[mult_width-1:0]r_mult_data=0;//最终输出的数据
reg r_mult_valid0,r_mult_valid1;
assign o_AGC_data=r_mult_data[(mult_width-1) -:OUTPUT_DATA_WIDTH];
assign o_AGC_valid=r_mult_valid1;
//半波整流
reg [mult_width-1-1:0]r_zhengliu_data=0;//整流后变成无符号数，少了一位
reg r_zhengliu_valid;
//求幅
wire [mult_width-1:0] w_range ;
wire w_range_valid ;
//与基准信号相减，求误差信号
reg signed [10:0]r_error_data=0;//11位,-1024~1023
reg r_error_valid;
//积分
reg signed [jifen_all_width:0]r_jifen_data=0;//比无符号的积分数据多1位
reg r_jifen_valid;
reg [jifen_all_width-1:0]r_jifen_abs_data=0;//取绝对值的无符号积分数
wire [jifen_jie_width-1:0] w_jifen_jie_data;
assign w_jifen_jie_data=r_jifen_abs_data[jifen_all_width-1 -:jifen_jie_width];
//debug
assign debug_w_range=w_range[(mult_width-1-1) -:10];
assign debug_error_data=r_error_data;
//相乘并输出
always @(posedge clk ) 
begin
    if(i_AGC_valid)begin
        r_temp_mult_data<=i_AGC_data*$signed({1'b0,w_jifen_jie_data});
    end
    if(r_mult_valid0)begin
        if(r_temp_mult_data>=2**(mult_width-1))
            r_mult_data<=2**(mult_width-1)-1;
        else if(r_temp_mult_data<-2**(mult_width-1))
            r_mult_data<= -2**(mult_width-1);
        else r_mult_data<= r_temp_mult_data[mult_width-1:0];
    end
    r_mult_valid0<=i_AGC_valid;
    r_mult_valid1<=r_mult_valid0;
end
//半波整流
always @(posedge clk ) 
begin
    if(r_mult_valid1)begin
        r_zhengliu_data<=(r_mult_data>=0) ? r_mult_data : (r_mult_data==-2**(mult_width-1)) ?  (2**(mult_width-1)-1) : -r_mult_data;
    end
    r_zhengliu_valid<=r_mult_valid1;
end
//求幅
//滑窗均值
Sliding_average_filter#(
   .WINDOW_WIDTH   (WINDOW_WIDTH             ),
   .en_sample_interval(en_sample_interval             ),
   .DATA_WIDTH     (mult_width             )
)
 u_Sliding_average_filter(
    .clk                                (clk                       ),
    .rst                                (rst),
    .i_data                             ({1'b0,r_zhengliu_data}    ),//该滤波器必须输入有符号数
    .i_valid                            (r_zhengliu_valid          ),
    .i_sample_interval                  (i_sample_interval         ),
    .o_data                             (w_range                    ),
    .o_valid                            (w_range_valid                   )
);
//与基准信号相减，求误差信号
always @(posedge clk ) 
begin
    if(w_range_valid)begin
        r_error_data<=i_ref_data-w_range[(mult_width-1-1) -:10];
    end
    r_error_valid<=w_range_valid;
end
//积分
always @(posedge clk ) 
begin
    if(rst)begin
        r_jifen_data<=0;
        r_jifen_abs_data<=0;
    end
    else begin
        if(r_error_valid)begin
            r_jifen_data<=$signed({1'b0,r_jifen_abs_data})+r_error_data;
        end
        r_jifen_valid<=r_error_valid;
        if(r_jifen_valid)begin
            r_jifen_abs_data<=(r_jifen_data>=0) ? r_jifen_data:-r_jifen_data;//这里不会有最小溢出的情况，所以直接取反
        end
    end
end
endmodule