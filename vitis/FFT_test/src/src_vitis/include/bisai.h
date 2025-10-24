#include "main.h"
//查找3,4模式的缩放倍数
double Search_zoom_34(u32 V_index,u32 F_index);
//写入IFFT滤波器参数
void Write_ram(u32 addr,double sin, double cos, double FFT_zoom);
void Delay_ms(u32 ms);
//计算幅度缩放
double Get_A_zoom(double FFT1_I,double FFT1_Q,double FFT2_I,double FFT2_Q);
u8 FFT_learn(double OUT_zoom,double *delta_phase,double *A_zoom);
void FFT_single();
//计算相位偏差
double Get_delta_phase(int32_t FFT1_I,int32_t FFT1_Q,int32_t FFT2_I,int32_t FFT2_Q);
//设置IFFT缩放值，模拟幅频特性
void Set_FFT_zoom(double FFT_zoom);
//设置该地址的sin和cos值,输入值在0到1之间，15位缩放系数
void Set_cos(double cos);
void Set_sin(double sin);
//设置要写入的地址
void Set_wr_addr(u32 wr_addr);
//设置读写模式,1表示写，0表示读
void Set_ram_wea(u32 ram_wea);
//获取FFT1 I路信号
int32_t Get_FFT1_I();
//获取FFT1 Q路信号
int32_t Get_FFT1_Q();
//获取FFT2 I路信号
int32_t Get_FFT2_I();
//获取FFT2 Q路信号
int32_t Get_FFT2_Q();
//设置频率字索引
void Set_FFT_index(u32 FFT_index);
//清除FFT结束标志位
void Clear_FFT_end_flag();
//查看FFT结束标志位
bool Get_FFT_end_flag();
//发送开始FFT脉冲
void Set_FFT_start();
//设置输出缩放,0到16都可以
void Set_OUT_zoom(double zoom);
//设置DDS频率
void Set_DDS_Freq(double FRE);
//设置模式参数
//有0,1,2,3,4五种模式
void Set_Mode(u32 mode);