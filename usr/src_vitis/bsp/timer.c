#include "timer.h"
// #include <xil_types.h>
//---------------------------------------------------------
//        定时器中断处理程序
//---------------------------------------------------------
u32 ms_10 = 0;   //计数
//获取当前计数值
u32 Get_time_value()
{
    return ms_10;
}
static void TimerIntrHandler(void *CallBackRef)
{
    XScuTimer *TimerInstancePtr = (XScuTimer *) CallBackRef;
    XScuTimer_ClearInterruptStatus(TimerInstancePtr);
    ms_10++;
    // if(ms_10%100==0)
    //     printf(" %d ms\n\r",ms_10*10);  //每秒打印输出一次
}

//---------------------------------------------------------
//          定时器中断配置
//---------------------------------------------------------
void Timer_Intr_Init(XScuGic *GicInstancePtr,
        XScuTimer *TimerInstancePtr, u16 TimerIntrId)
{
    /* 初始化中断控制器 */
	XScuGic_Config *IntcConfig;
    IntcConfig = XScuGic_LookupConfig(GIC_BASEADDR);
    XScuGic_CfgInitialize(GicInstancePtr, IntcConfig, IntcConfig->CpuBaseAddress);
    /* 设置中断异常 */
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
    		(Xil_ExceptionHandler)XScuGic_InterruptHandler, GicInstancePtr);
    Xil_ExceptionEnable();
    /* 设置定时器中断  */
    XScuGic_Connect(GicInstancePtr, TimerIntrId,
          (Xil_ExceptionHandler)TimerIntrHandler, (void *)TimerInstancePtr);

    XScuGic_Enable(GicInstancePtr, TimerIntrId); //使能中断
    XScuTimer_EnableInterrupt(TimerInstancePtr); //使能定时器中断
}

//---------------------------------------------------------
//        定时器初始化程序
//---------------------------------------------------------
void TimerInit(XScuTimer *Timer, UINTPTR BaseAddress)
{
	/* 私有定时器初始化  */
	XScuTimer_Config *TMRConfigPtr;
    TMRConfigPtr = XScuTimer_LookupConfig(BaseAddress);
    XScuTimer_CfgInitialize(Timer, TMRConfigPtr,TMRConfigPtr->BaseAddr);
    // Timer_Intr_Init(&Intc,&Timer,TIMER_IRPT_INTR); // 设置定时器中断
    XSetupInterruptSystem(Timer, &TimerIntrHandler,
				       TMRConfigPtr->IntrId, TMRConfigPtr->IntrParent,
				       XINTERRUPT_DEFAULT_PRIORITY);
    XScuTimer_EnableInterrupt(Timer);               //使能中断
    XScuTimer_EnableAutoReload(Timer);            // 设置自动装载模式
    XScuTimer_LoadTimer(Timer, TIMER_LOAD_VALUE); // 加载计数周期
    XScuTimer_Start(Timer);                       // 启动定时器
}