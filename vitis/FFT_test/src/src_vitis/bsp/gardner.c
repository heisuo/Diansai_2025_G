#include "gardner.h"

//设置gardner频率控制字
void Set_gardner_FTW(u32 gardner_FTW)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*9);
    //寄存器控制字
    *reg_addr = gardner_FTW;  // 写入寄存器
}
