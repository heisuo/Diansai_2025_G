#include "bisai.h"
#include "DDS.h"
#include "timer.h"
#include "main.h"
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/_intsup.h>
// 查找表数据（这里使用示例值）
const double lookup_table[30][11] = {
    {4.95,5.45,5.95,6.4,6.9,7.35,7.9,8.4,8.9,9.45,9.95},//100
    {5.1,5.63,6.13,6.65,7.16,7.68,8.19,8.69,9.2,9.72,10.23},//200
    {5.38,5.92,6.46,7,7.56,8.08,8.63,9.18,9.72,10.26,10.81},//300
    {5.75,6.33,6.91,7.49,8.08,8.65,9.24,9.83,10.4,10.99,11.57},//400
    {6.21,6.83,7.46,8.09,8.72,9.33,9.97,10.59,11.22,11.86,12.49},//500
    {6.72,7.4,8.09,8.76,9.46,10.12,10.81,11.49,12.16,12.85,13.53},//600
    {7.3,8.03,8.78,9.51,10.26,10.81,11.73,12.47,13.22,13.98,14.71},//700
    {7.9,8.71,9.51,10.32,11.1,11.9,12.71,13.52,14.32,15.14,16.1},//800
    {8.58,9.43,10.29,11.17,12.03,12.89,13.76,14.65,15.51,16.44,17.28},//900
    {9.4,10.3,11.2,12.15,13.1,14,14.9,15.85,16.8,17.8,18.7},//1000
    {9.97,11,11.98,13,14,15.01,16.01,17.03,18.08,19.01,20.01},//1100
    {10.65,11.72,12.81,13.89,14.99,16.05,17.16,18.28,19.36,20.48,21.65},//1200
    {11.45,12.62,13.79,14.94,16.12,17.25,18.42,19.62,20.8,21.99,23.15},//1300
    {12.26,13.51,14.73,15.98,17.25,18.46,19.71,20.98,22.23,23.53,24.66},//1400
    {13.06,14.35,15.59,17.02,18.35,19.66,21,22.36,23.71,25.07,26.3},//1500
    {13.89,15.34,16.73,18.11,19.57,20.96,22.35,23.8,25.21,26.7,28.1},//1600
    {14.78,16.28,17.79,19.25,20.75,22.23,23.79,25.29,26.8,28.35,29.85},//1700
    {15.65,17.25,18.78,20.42,22.07,23.59,25.26,26.8,28.41,30.1,31.7},//1800
    {16.6,18.4,20.09,21.8,23.47,25.12,26.7,28.44,30.1,31.83,33.4},//1900
    {17.54,19.32,21.1,22.84,24.61,26.4,28.18,29.98,31.8,33.6,35.4},//2000
    {18.5,20.35,22.23,24.1,25.95,27.84,29.72,31.61,33.5,35.43,37.34},//2100
    {19.45,21.43,23.39,25.39,27.35,29.35,31.25,33.35,35.35,37.3,39.31},//2200
    {20.42,22.58,24.64,26.68,28.7,30.8,32.95,35.09,37.15,39.28,41.35},//2300
    {21.5,23.6,25.85,28,30.28,32.48,34.65,36.8,38.58,42.08,43.42},//2400
    {22.54,24.8,27.1,29.35,31.7,33.95,36.3,38.6,40.92,43.28,45.54},//2500
    {23.64,26,28.45,30.85,33.25,35.64,38.07,40.55,43.25,45.45,47.85},//2600
    {24.71,27.4,30,32.35,35,37.35,39.9,42.47,45,47.6,50.1},//2700
    {25.85,28.6,31.15,33.75,36.4,39,41.7,44.35,47,49.7,52.4},//2800
    {27.01,29.8,32.7,35.3,38,40.8,43.6,46.3,49.15,53.3,54.7},//2900
    {28.3,31.25,34,36.8,39.7,42.6,45.6,48.4,51.3,54.2,57.1}//3000
};
//查找3,4模式的缩放倍数
double Search_zoom_34(u32 V_index,u32 F_index)
{
    return lookup_table[F_index][V_index];
}
void Write_ram(u32 addr,double sin, double cos, double FFT_zoom)
{
    Set_wr_addr(addr);
    Set_sin(sin);
    Set_cos(cos);
    Set_FFT_zoom(FFT_zoom);
    Set_wr_addr(FFT_POINTS-addr);
    Set_sin(-sin);
    Set_cos(cos);
    Set_FFT_zoom(FFT_zoom);
}
void Delay_ms(u32 ms)
{
    u32 delay_ms=Get_time_value();
    while (Get_time_value()-delay_ms<ms) {
    };    
}
//计算幅度缩放
double Get_A_zoom(double FFT1_I,double FFT1_Q,double FFT2_I,double FFT2_Q)
{
    double FFT1_A=sqrt((FFT1_I*FFT1_I + FFT1_Q*FFT1_Q));
    double FFT2_A=sqrt((FFT2_I*FFT2_I + FFT2_Q*FFT2_Q));
    return FFT2_A/FFT1_A;
}
//计算相位偏差
double Get_delta_phase(int32_t FFT1_I,int32_t FFT1_Q,int32_t FFT2_I,int32_t FFT2_Q)
{
    double phase1=atan2(FFT1_Q, FFT1_I);
    double phase2=atan2(FFT2_Q, FFT2_I);
    double delta_phase=phase2-phase1;
    if(delta_phase>PI)
        return (delta_phase-2*PI);
    else if (delta_phase<-PI)
        return (delta_phase+2*PI);
    else return delta_phase;
}
//FFT滤波器建模
u8 FFT_learn(double OUT_zoom,double *delta_phase,double *A_zoom)
{
    Set_Mode(3);
    Set_OUT_zoom(OUT_zoom);

    double A_zoom_max=0,A_zoom_min=1;
    int Max_index=0,Min_index=0;
    double FFT_delta_phase[FFT_POINTS/2];
    double FFT_A_zoom[FFT_POINTS/2];
    //扫频到1250*200=250khz，从200Hz开始
    for(int i=1;i<=1250;i++){
        Set_DDS_Freq(200*i);
        Set_FFT_index(i);
        //开始前等待2ms让信号稳定
        if(i<10){
            Delay_ms(5);
        }else{
            Delay_ms(2);
        }
        //开始一次FFT运算
        Set_FFT_start();
        //等待FFT结束
        while (!Get_FFT_end_flag()) {
        };
        //清除FFT结束标志位
        Clear_FFT_end_flag();
        //获取FFT结果
        int32_t FFT1_I=Get_FFT1_I();
        int32_t FFT1_Q=Get_FFT1_Q();
        int32_t FFT2_I=Get_FFT2_I();
        int32_t FFT2_Q=Get_FFT2_Q();
        //计算相偏与幅度缩放
        delta_phase[i] =Get_delta_phase(FFT1_I,FFT1_Q,FFT2_I,FFT2_Q);
        A_zoom[i] =Get_A_zoom(FFT1_I,FFT1_Q,FFT2_I,FFT2_Q);
        //查找幅度缩放最大最小值
        if(A_zoom_max<A_zoom[i]){
            A_zoom_max=A_zoom[i];
            Max_index=i;
        }
        if(A_zoom_min>A_zoom[i]){
            A_zoom_min=A_zoom[i];
            Min_index=i;
        }
        FFT_delta_phase[i]=delta_phase[i];
        FFT_A_zoom[i]=A_zoom[i];
        // if(A_zoom[i]>1.4){
        //     FFT_A_zoom[i]=1.4;
        // }else{
        //     FFT_A_zoom[i]=A_zoom[i];
        // }
    }
    //以600Hz为步进扫完接下来750个点
    for(int i=1253;i<=3500;i+=3){
        Set_DDS_Freq(200*i);
        Set_FFT_index(i);
        //开始前等待2ms让信号稳定
        Delay_ms(2);
        //开始一次FFT运算
        Set_FFT_start();
        //等待FFT结束
        while (!Get_FFT_end_flag()) {
        };
        //清除FFT结束标志位
        Clear_FFT_end_flag();
        //获取FFT结果
        int32_t FFT1_I=Get_FFT1_I();
        int32_t FFT1_Q=Get_FFT1_Q();
        int32_t FFT2_I=Get_FFT2_I();
        int32_t FFT2_Q=Get_FFT2_Q();
        //计算相偏与幅度缩放
        delta_phase[i] =Get_delta_phase(FFT1_I,FFT1_Q,FFT2_I,FFT2_Q);
        A_zoom[i] =Get_A_zoom(FFT1_I,FFT1_Q,FFT2_I,FFT2_Q);
        double temp_phase =(delta_phase[i]+delta_phase[i-3])/2;
        double temp_zoom =(A_zoom[i]+A_zoom[i-3])/2;
        delta_phase[i-1]=temp_phase;
        delta_phase[i-2]=temp_phase;
        A_zoom[i-1]=temp_zoom;
        A_zoom[i-2]=temp_zoom;
    }
    //以200*13=2600Hz为步进扫完接下来500个点，最终扫完2M信号
    for(int i=3513;i<=10000;i+=13){
        Set_DDS_Freq(200*i);
        Set_FFT_index(i);
        //开始前等待2ms让信号稳定
        Delay_ms(2);
        //开始一次FFT运算
        Set_FFT_start();
        //等待FFT结束
        while (!Get_FFT_end_flag()) {
        };
        //清除FFT结束标志位
        Clear_FFT_end_flag();
        //获取FFT结果
        int32_t FFT1_I=Get_FFT1_I();
        int32_t FFT1_Q=Get_FFT1_Q();
        int32_t FFT2_I=Get_FFT2_I();
        int32_t FFT2_Q=Get_FFT2_Q();
        //计算相偏与幅度缩放
        delta_phase[i] =Get_delta_phase(FFT1_I,FFT1_Q,FFT2_I,FFT2_Q);
        A_zoom[i] =Get_A_zoom(FFT1_I,FFT1_Q,FFT2_I,FFT2_Q);
        double temp_phase =(delta_phase[i]+delta_phase[i-13])/2;
        double temp_zoom =(A_zoom[i]+A_zoom[i-13])/2;
        //中间没扫到的频点直接取相邻频点的平均值
        for(int j=1;j<=12;j++){
            delta_phase[i-j]=temp_phase;
            A_zoom[i-j]=temp_zoom;
        }
    }
    for(int i=1251;i<=SWEEP_POINTS;i++){
        //查找幅度缩放最大最小值
        if(A_zoom_max<A_zoom[i]){
            A_zoom_max=A_zoom[i];
            Max_index=i;
        }
        if(A_zoom_min>A_zoom[i]){
            A_zoom_min=A_zoom[i];
            Min_index=i;
        }
        //赋值
        FFT_delta_phase[i]=delta_phase[i];
        FFT_A_zoom[i]=A_zoom[i];
        // //超过1.4的缩放算成1.4
        // if(A_zoom[i]>1.4){
        //     FFT_A_zoom[i]=1.4;
        // }else{
        //     FFT_A_zoom[i]=A_zoom[i];
        // }
    }
    //将数据写入FPGAram中
    Set_ram_wea(1);
    for(int i=1;i<=SWEEP_POINTS;i++){
        Write_ram(i,sin(FFT_delta_phase[i]),cos(FFT_delta_phase[i]),FFT_A_zoom[i]);
    }
    Set_ram_wea(0);
    //滤波器判决
    // double A_derivative[2500];
    //幅频特性求导数,对相位边界用单边差分，内部用中心差分
    // // --- 阶段2: 计算幅度导数 ---
    // double A_derivative[FFT_POINTS/2];
    // // const double derivative_threshold = 0.001;
    // for (int i=1; i<=SWEEP_POINTS; i++) {
    //     if(i==1){
    //         A_derivative[i]=(FFT_A_zoom[i+1]-FFT_A_zoom[i])/(200);
    //     }else if (i==SWEEP_POINTS){
    //         A_derivative[i]=(FFT_A_zoom[i]-FFT_A_zoom[i-1])/(200);
    //     }else{
    //         A_derivative[i]=(FFT_A_zoom[i+1]-FFT_A_zoom[i-1])/400;
    //     }
    // }
    // // 找出最大最小导数值和索引
    // double max_derivative = 0, min_derivative=0;
    // int d_max_index=0,d_min_index=0;
    // for (int i = 1; i <= SWEEP_POINTS; i++) {
    //     if (A_derivative[i] > max_derivative) {
    //         max_derivative = A_derivative[i];
    //         d_max_index=i;
    //     }
    //     if (A_derivative[i] < min_derivative) {
    //         min_derivative = A_derivative[i];
    //         d_min_index=i;
    //     }
    // }
    // printf("检测到的最大导数%f,此时频点为%d\n", max_derivative,d_max_index*200);
    // printf("检测到的最小导数%f，此时频点为%d\n", max_derivative,d_min_index*200);
    printf("测试得到最大的缩放幅度为%f，此时频率为%d\n",A_zoom_max,Max_index*200);
    printf("测试得到最小的缩放幅度为%f，此时频率为%d\n",A_zoom_min,Min_index*200);
    // --- 阶段3: 滤波器类型判定 ---
    // double threshold_max=0,threshold_min=0;//两个门限值
    //打点法判定滤波器类型
    printf("200hz的缩放幅度为%f，1Mhz的缩放幅度为%f\n",A_zoom[1],A_zoom[SWEEP_POINTS]);
    if(A_zoom[1]>0.5 && A_zoom[SWEEP_POINTS]>0.5){
        printf("鉴定为带阻滤波器\n");
        return 1;
    }else if(A_zoom[1]>0.5 && A_zoom[SWEEP_POINTS]<0.5){
        printf("鉴定为低通滤波器\n");
        return 2;
    }else if(A_zoom[1]<0.5 && A_zoom[SWEEP_POINTS]<0.5){
        printf("鉴定为带通滤波器\n");
        return 3;
    }else if(A_zoom[1]<0.5 && A_zoom[SWEEP_POINTS]>0.5){
        printf("鉴定为高通滤波器\n");
        return 4;
    }
    return 0;
}
void FFT_single(u32 FFT_index)
{
    //单次FFT测试
    Set_FFT_index(FFT_index);
    Set_FFT_start();
    while (!Get_FFT_end_flag()) {
    };
    Clear_FFT_end_flag();
    printf("单次FFT测试成功\n");
    double delta_phase;
    delta_phase=Get_delta_phase(Get_FFT1_I(),Get_FFT1_Q(),Get_FFT2_I(),Get_FFT2_Q());
    printf("两路信号相位差为%f度\n",delta_phase/PI*180);
}
//设置IFFT缩放值，模拟幅频特性
void Set_FFT_zoom(double FFT_zoom)
{
    //对浮点数进行15位量化
    int32_t FFT_zoom_q=FFT_zoom*(32768-1);
   // 定义指针变量并初始化为寄存器地址
    volatile int32_t *reg_addr = (volatile int32_t*)(PS_AXI_CTRL_BASEADDR + 4*50);
    //寄存器控制字
    *reg_addr = FFT_zoom_q;  // 写入寄存器
}
//设置该地址的sin和cos值,输入值在0到1之间，15位缩放系数
void Set_cos(double cos)
{
    //对浮点数进行15位量化
    int32_t cos_q=cos*(32768-1);
   // 定义指针变量并初始化为寄存器地址
    volatile int32_t *reg_addr = (volatile int32_t*)(PS_AXI_CTRL_BASEADDR + 4*46);
    //寄存器控制字
    *reg_addr = cos_q;  // 写入寄存器
}
void Set_sin(double sin)
{
    //对浮点数进行15位量化
    int32_t sin_q=sin*(32768-1);
   // 定义指针变量并初始化为寄存器地址
    volatile int32_t *reg_addr = (volatile int32_t*)(PS_AXI_CTRL_BASEADDR + 4*45);
    //寄存器控制字
    *reg_addr = sin_q;  // 写入寄存器
}
//设置要写入的地址
void Set_wr_addr(u32 wr_addr)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*47);
    //寄存器控制字
    *reg_addr = wr_addr;  // 写入寄存器
}
//设置读写模式,1表示写，0表示读
void Set_ram_wea(u32 ram_wea)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*48);
    //寄存器控制字
    *reg_addr = ram_wea;  // 写入寄存器
}
//获取FFT1 I路信号
int32_t Get_FFT1_I()
{
    // 定义指针变量并初始化为寄存器地址
    volatile int32_t *reg_addr = (volatile int32_t*)(PS_AXI_CTRL_BASEADDR + 4*41);
    int32_t reg_value = *reg_addr;  // 读取第寄存器
    return reg_value;
} 
//获取FFT1 Q路信号
int32_t Get_FFT1_Q()
{
    // 定义指针变量并初始化为寄存器地址
    volatile int32_t *reg_addr = (volatile int32_t*)(PS_AXI_CTRL_BASEADDR + 4*42);
    int32_t reg_value = *reg_addr;  // 读取第寄存器
    return reg_value;
} 
//获取FFT2 I路信号
int32_t Get_FFT2_I()
{
    // 定义指针变量并初始化为寄存器地址
    volatile int32_t *reg_addr = (volatile int32_t*)(PS_AXI_CTRL_BASEADDR + 4*43);
    int32_t reg_value = *reg_addr;  // 读取第寄存器
    return reg_value;
} 
//获取FFT2 Q路信号
int32_t Get_FFT2_Q()
{
    // 定义指针变量并初始化为寄存器地址
    volatile int32_t *reg_addr = (volatile int32_t*)(PS_AXI_CTRL_BASEADDR + 4*44);
    int32_t reg_value = *reg_addr;  // 读取第寄存器
    return reg_value;
} 
//设置频率字索引
void Set_FFT_index(u32 FFT_index)
{
   // 定义指针变量并初始化为寄存器地址
    volatile int32_t *reg_addr = (volatile int32_t*)(PS_AXI_CTRL_BASEADDR + 4*39);
    //寄存器控制字
    *reg_addr = FFT_index;  // 写入寄存器
}
//清除FFT结束标志位
void Clear_FFT_end_flag()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=13;//第bit位
    //寄存器控制字，第bit位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//查看FFT结束标志位
bool Get_FFT_end_flag()
{
    // uint32_t reg_addr=PS_AXI_CTRL_BASEADDR + 4*2;
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*1);
    uint8_t bit=5;//第0位
    uint32_t reg_value = *reg_addr;  // 读取第寄存器
    return (reg_value & (1<<bit)) >> bit;
}
//发送开始FFT脉冲
void Set_FFT_start()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=12;//第bit位
    //寄存器控制字，第bit位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//设置输出缩放,0到16都可以
void Set_OUT_zoom(double zoom)
{
    //对浮点数进行15位量化
    int32_t zoom_q=zoom*(32768-1);
   // 定义指针变量并初始化为寄存器地址
    volatile int32_t *reg_addr = (volatile int32_t*)(PS_AXI_CTRL_BASEADDR + 4*49);
    //寄存器控制字
    *reg_addr = zoom_q;  // 写入寄存器
}
//设置DDS频率
void Set_DDS_Freq(double FRE)
{
    double FTW=(double)(4294967296)*(FRE)/SAMPLE_RATE;
    Set_DDS_FTW((u32) FTW);
}
//设置模式参数
//有0,1,2,3,4五种模式
void Set_Mode(u32 mode)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*40);
    //寄存器控制字
    *reg_addr = mode;  // 写入寄存器
}

