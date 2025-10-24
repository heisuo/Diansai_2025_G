#include "main.h"
//---------------------------------------------------------
//        函数申明
//---------------------------------------------------------
void Timer_Intr_Init(XScuGic *GicInstancePtr,
        XScuTimer *TimerInstancePtr, u16 TimerIntrId);
void TimerInit(XScuTimer *Timer, UINTPTR BaseAddress);
u32 Get_time_value();