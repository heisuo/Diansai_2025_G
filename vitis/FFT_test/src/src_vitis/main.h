#ifndef MAIN_H
#define MAIN_H
//系统库
#include <stdint.h>
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include <stdbool.h>  // 提供bool类型
#include "stdlib.h"
//定时器
#include "xscutimer.h"
//串口
#include "xuartps.h"
//中断相关库
#include "xinterrupt_wrap.h"
#include "xscugic.h"
// #include <time.h>
//数学库
#include <math.h>
//fftw库
#include <fftw3.h>
#include "xparameters.h"
#include "xparameters_ps.h"
// #include "arm_math.h"
// #include "arm_const_structs.h"
#define PI 3.14159265358979323846 //PI常量
#define SAMPLE_RATE (102.4e6)  // 采样率 102.4 MHz
#define SIGNAL_FREQ (10e6)    // 信号频率 1 MHz
#define FFT_POINTS 8192*4                 // FFT点数
#define SWEEP_POINTS 10000     //扫频点数
#define BRAM_CHANEL0_BASEADDR 0x40000000 //通道0基地址
//模式
#define MODE_IDLE 0 
#define MODE_DDS 1
#define MODE_3_4 2
#define MODE_WAIT_LEARN 3
#define MODE_LEARN_start 11
#define MODE_WORK 4
//控制IP核基地址
#define PS_AXI_CTRL_BASEADDR XPAR_PS_AXI_CTRL_NEW_0_BASEADDR
//定时器
//定时器的工作时钟为cpu时钟的一半
#define TIMER_BASEADDR XPAR_SCUTIMER_BASEADDR //定时器基地址
#define TIMER_LOAD_VALUE 400000-1      //定时器装载值，设置为1ms
// #define TIMER_LOAD_VALUE 400-1 //1us

//串口
#define UART0_BASEADDR XPAR_XUARTPS_0_BASEADDR
#define UART0_BAUD 115200
#define UART1_BASEADDR XPAR_XUARTPS_1_BASEADDR
#define UART1_BAUD 115200
#define RX_BUFFER_SIZE 128
//中断相关
#define GIC_BASEADDR XPAR_SCUGIC_DIST_BASEADDR //GIC中断系统基础地址
#define TIMER_IRPT_INTR     XPAR_SCUTIMER_INTR  //定时器中断ID号
#define UART0_IRPT_INTR      XPAR_XUARTPS_0_INTR //串口0中断ID号
#define UART1_IRPT_INTR      XPAR_XUARTPS_1_INTR //串口0中断ID号
//函数声明

#endif // HELLOWORLD_H
