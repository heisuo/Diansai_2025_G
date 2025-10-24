#include "costas.h"
//设置costas重新工作
void Set_costas_rework()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=2;//第bit位
    //寄存器控制字，第bit位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//设置costas频率初始控制字
void Set_costas_FTW_ini(uint32_t FTW_ini)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*5);
    //寄存器控制字
    *reg_addr = FTW_ini;  // 写入寄存器
}
//设置costas锁向环参数1
void Set_costas_PLL_C1(uint32_t PLL_C1)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*6);
    //寄存器控制字
    *reg_addr = PLL_C1;  // 写入寄存器
}
//设置costas锁向环参数2
void Set_costas_PLL_C2(uint32_t PLL_C2)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*7);
    //寄存器控制字
    *reg_addr = PLL_C2;  // 写入寄存器
}
//设置costas环工作间隔
void Set_costas_jiange(uint32_t jiange)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*8);
    //寄存器控制字
    *reg_addr = jiange;  // 写入寄存器
}