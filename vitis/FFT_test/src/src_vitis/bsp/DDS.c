#include "DDS.h"
#include <xil_types.h>

//设置DDS频率控制字
void Set_DDS_FTW(u32 DDS_FTW)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*15);
    //寄存器控制字
    *reg_addr = DDS_FTW;  // 写入寄存器
}