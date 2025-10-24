#include "main.h"
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/_intsup.h>
#include <xil_types.h>
#include "timer.h"
#include "uart.h"
#include "DDS.h"
#include "bisai.h"
#include "FFT.h"
uint8_t Mode=MODE_IDLE;//模式参数
static XScuTimer Timer;   //定时器
static XUartPs Uart1;//uart
//延时变量
u32 delay_1s,delay_2s,delay_10ms,delay_50ms;
u32 delay_1us=0,delta_time=0;
extern u32 rx_delay_10ms;
//串口屏相关变量
extern u8 RecvBuffer[RX_BUFFER_SIZE];
extern char TxBuffer[RX_BUFFER_SIZE];
extern UartRxResult RxResult;
extern char mode[32];
extern char data[64];

void rx_proc();
void rx_int_proc();
void Mode_proc();
void IFFT_test();
void Mode_set();
int main() {
    //初始化
    init_platform();
    TimerInit(&Timer, TIMER_BASEADDR);
    UARTInit(&Uart1,UART1_BASEADDR);
    FFT_test();

    //DDS测试
    Set_Mode(MODE_3_4);
    Set_OUT_zoom(0.5);
    Set_DDS_Freq(1000);
    //FFT重建测试，在第1个点和第FFT_POINT-1个点测试
    // printf("开始学习建模\n");
    // u32 jianmo_time;
    // jianmo_time=Get_time_value();
    // FFT_learn(0.5);
    // u32 delta_t=Get_time_value()-jianmo_time;
    // printf("建模完毕,消耗时间%dms\n",delta_t);
    // Set_OUT_zoom(0.75);
    // Set_Mode(4);//开始工作
    // printf("现在开始工作\n");
    // sprintf(TxBuffer, "qq.CC0.txt.str=\"带阻滤波器\";\r\n");
    // XUartPs_Send(&Uart1, (u8 *)TxBuffer, 60);
    // sprintf(TxBuffer, "CC0.txt.str=\"带阻滤波器\";\r\n");
    // XUartPs_Send(&Uart1, (u8 *)TxBuffer, 60);
    // sprintf(TxBuffer, "CC0.txt.str=\"111\";\r\n");
    // XUartPs_Send(&Uart1, (u8 *)TxBuffer, 60);
    while (1) {
        if(Get_time_value()-delay_2s>=2000){
            // FFT_single();
            delay_2s=Get_time_value();
        }
        if(Get_time_value()-delay_50ms>=50){
            Mode_proc();
            delay_50ms=Get_time_value();
        }
        if(Get_time_value()-delay_10ms>=10){
            rx_proc();
            delay_10ms=Get_time_value();
        }
        if(Get_time_value()-rx_delay_10ms>=10){
            rx_int_proc();
            rx_delay_10ms=Get_time_value();
        }
    }
    return 0;
}  
//串口中断处理
void rx_int_proc()
{
    if(RxResult.rx_int_flag==1){
        if (parse_string((char *)RecvBuffer, mode, data) == 0)
        {
            RxResult.rx_flag=1;
        }
        else RxResult.rx_error=1;
        // printf("接收到串口屏信息:\n%s\n",RecvBuffer);
        memset(RecvBuffer,0,RxResult.rx_total_num);
        RxResult.rx_total_num=0;
        XUartPs_Recv(&Uart1, RecvBuffer, RX_BUFFER_SIZE);
        RxResult.rx_int_flag=0;
    }
}
double f_DDS=100,f_34=100;
double zoom_34,zoom_zoom_34=1,zoom_learn_start=0.25,zoom_work=1.458*4*1.95/2.15;
u32 V_index=0,F_index=0;
double FFT_delta_phase[FFT_POINTS/2];//FFT频点相位差
double FFT_A_zoom[FFT_POINTS/2];//FFT频点缩放
//模式处理
void Mode_proc()
{
    if(Mode==12){
        printf("开始绘制波特图\n");
        double FFT_zoom_db[FFT_POINTS/2];
        double FFT_zoom_db_min=0,FFT_phase_min=0;
        int db_min_index,phase_min_index;
        //幅度转化为dB，找缩放db最小值，相移最小值，都是负数
        for(int i=1;i<=1024;i++){
            FFT_zoom_db[i]=10*log10(FFT_A_zoom[i]);
            if(FFT_zoom_db_min>FFT_zoom_db[i]){
                FFT_zoom_db_min=FFT_zoom_db[i];
                db_min_index=i;
            }
            if(FFT_phase_min>FFT_delta_phase[i]){
                FFT_phase_min=FFT_delta_phase[i];
                phase_min_index=i;
            }
        }
        printf("最大衰减为%f,频率%d\n",FFT_zoom_db_min,db_min_index*200);
        printf("最大相移为%f,频率%d\n",FFT_phase_min,phase_min_index*200);
        //把负值搬到正值
        double FFT_phase_zheng[FFT_POINTS/2];//FFT频点缩放
        for(int i=1;i<=1024;i++){
             FFT_zoom_db[i] -=FFT_zoom_db_min;
             FFT_phase_zheng[i] =FFT_delta_phase[i] - FFT_phase_min;
        }
        //找到般正后的最大值
        double FFT_zoom_db_max=0,FFT_phase_max=0;
        for(int i=1;i<=1024;i++){
            if(FFT_zoom_db_max<FFT_zoom_db[i]){
                FFT_zoom_db_max=FFT_zoom_db[i];
            }
            if(FFT_phase_max<FFT_phase_zheng[i]){
                FFT_phase_max=FFT_phase_zheng[i];
            }
        }
        //归一化
        for(int i=1;i<=1024;i++){
            FFT_zoom_db[i]=FFT_zoom_db[i]/FFT_zoom_db_max;
            FFT_phase_zheng[i]=FFT_phase_zheng[i]/FFT_phase_max;
        }
        //进行8位量化，输出到串口屏
        u8 FFT_zoom_db_8bit[1024];
        u8 FFT_phase_8bit[1024];
        for(int i=1;i<=1024;i++){            
            FFT_zoom_db_8bit[1024-i]=FFT_zoom_db[i]*255;
            FFT_phase_8bit[1024-i]=FFT_phase_zheng[i]*255;
        }

        //开启透传模式
        sprintf(TxBuffer, "caddt(c0,0,1024);\r\n");
        XUartPs_Send(&Uart1, (u8 *)TxBuffer, 20);
        //delay100ms
        Delay_ms(100);
        //输出到串口屏
        XUartPs_Send(&Uart1, FFT_zoom_db_8bit, 1024);
        Delay_ms(300);
        //开启透传模式
        sprintf(TxBuffer, "caddt(c1,1,1024);\r\n");
        XUartPs_Send(&Uart1, (u8 *)TxBuffer, 30);
        //delay100ms
        Delay_ms(100);
        //输出到串口屏
        XUartPs_Send(&Uart1, FFT_phase_8bit, 1024);
        Delay_ms(100);
        // for(int i=1;i<=1024;i++){
        //     //进行8位量化，输出到串口屏
        //     printf("cadd(c0,0,%d);\r\n",FFT_phase_8bit[i]);
        // }
        Mode=MODE_WAIT_LEARN;
    }
    if(Mode==MODE_DDS){
        // printf("DDS频率字设置成功,频率为%f\n",f_DDS);
        Set_DDS_Freq(f_DDS);
    }
    if(Mode==MODE_3_4){
        zoom_34=Search_zoom_34(V_index,F_index)/100;
        Set_DDS_Freq(f_34);
        Set_OUT_zoom(zoom_34*zoom_zoom_34);
    }
    if(Mode==MODE_WAIT_LEARN){
        Set_OUT_zoom(zoom_learn_start);
    }
    if(Mode==MODE_LEARN_start){
        //将zoom_learn_start设置为0.125,经过运放后的输出幅度为0.5V
        u8 type=FFT_learn(zoom_learn_start,FFT_delta_phase,FFT_A_zoom);
        // sprintf(TxBuffer, "end.CC0.txt.str=\"%s\";\r\npage(end);\r\n","带通滤波器");
        // XUartPs_Send(&Uart1, (u8 *)TxBuffer, 60);
        if(type==0){
        //建模完毕切换到结束界面页面
            sprintf(TxBuffer, "end.CC0.txt.str=\"%s\";\r\npage(end);\r\n","未知滤波器");
            XUartPs_Send(&Uart1, (u8 *)TxBuffer, 60);
        }else if (type==1) {
            sprintf(TxBuffer, "end.CC0.txt.str=\"%s\";\r\npage(end);\r\n","带阻滤波器");
            XUartPs_Send(&Uart1, (u8 *)TxBuffer, 60);
        }else if (type==2) {
            sprintf(TxBuffer, "end.CC0.txt.str=\"%s\";\r\npage(end);\r\n","低通滤波器");
            XUartPs_Send(&Uart1, (u8 *)TxBuffer, 60);
        }else if (type==3) {
            sprintf(TxBuffer, "end.CC0.txt.str=\"%s\";\r\npage(end);\r\n","带通滤波器");
            XUartPs_Send(&Uart1, (u8 *)TxBuffer, 60);
        }else if (type==4) {
            sprintf(TxBuffer, "end.CC0.txt.str=\"%s\";\r\npage(end);\r\n","高通滤波器");
            XUartPs_Send(&Uart1, (u8 *)TxBuffer, 60);
        }
        printf("类型参数为%d\n",type);
        Delay_ms(3);//延时3毫秒
        Mode=MODE_WAIT_LEARN;
    }
    if(Mode==MODE_WORK){
        // printf("开始工作模式\n");
        //zoom_work=1.458*4*1.95/2.15
        //1.458是输入幅度与adc采样范围的比值，4是因为FFT IP核缩小了4倍(防止乘以缩放参数后数据超出范围)
        Set_OUT_zoom(zoom_work);
    }
}
//串口解析
void rx_proc()
{
    if(RxResult.rx_error==0){
        if(RxResult.rx_flag){
            char *pEnd;
            printf("解析成功:\n");
            printf("模式: %s\n", mode);
            printf("数据: %s\n", data);
            // Rx_Mode_Choose(mode);
            if(strcmp(mode, "M")==0){
                Mode=strtol(data,&pEnd,10);
                printf("解析模式为%d\n",Mode);
                if(Mode==MODE_DDS){
                    Set_Mode(1);
                }else if(Mode==MODE_3_4){
                    Set_Mode(2);
                }else if(Mode==MODE_WAIT_LEARN){
                    Set_Mode(3);
                }else if(Mode==MODE_LEARN_start){
                }else if(Mode==MODE_WORK){
                    Set_Mode(4);
                }else if(Mode==12){
                }
            }else if(strcmp(mode, "F")==0){
                // DDS_f=strtod(data, &pEnd);   
                u32 f=strtol(data,&pEnd,10);        
                printf("解析数据为频率%dHz\n",f); 
                if(Mode==MODE_DDS){
                    f_DDS=f;
                }else if(Mode==MODE_3_4){
                    f_34=f;
                    F_index=(u32)(f_34)/100-1;
                    printf("当前V下标%d,F下标%d\n",V_index,F_index);
                }else if(Mode==MODE_WAIT_LEARN){
                }else if(Mode==MODE_LEARN_start){
                }else if(Mode==MODE_WORK){
                }
            }else if (strcmp(mode, "V")==0) {
                V_index=strtol(data,&pEnd,10)-10;
                printf("电压下标%d\n",V_index);
                printf("当前V下标%d,F下标%d\n",V_index,F_index);
            }else if (strcmp(mode, "L")==0) {
                double V_Learn=strtod(data, &pEnd); 
                zoom_learn_start= V_Learn/4;
                printf("学习电压%f\n",V_Learn);
            }else if (strcmp(mode, "S")==0) {
                if(Mode==MODE_3_4){
                    zoom_zoom_34=strtod(data, &pEnd); 
                    printf("第34问输出缩放倍数%f\n",zoom_zoom_34);
                }else if(Mode==MODE_WAIT_LEARN){
                    zoom_work=strtod(data, &pEnd); 
                    printf("工作模式输出放大倍数%f\n",zoom_work);
                }
            }
            RxResult.rx_flag=0;
        }
    }
    else {
        printf("解析失败\n");
        RxResult.rx_error=0;
    }
}