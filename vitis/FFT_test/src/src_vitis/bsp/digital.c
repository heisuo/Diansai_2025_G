#include "digital.h"
#include <stdint.h>
//-------------发射机相关函数---------------
//填充数据
void tx_data2fifo(uint32_t *data,uint32_t tx_data_num)
{
    for(uint32_t i=0;i<tx_data_num;i++){
        Set_tx_data(data[i]);
        Set_tx_data_valid();
    }
    Set_tx_data_num(tx_data_num);
}
//设置开始发射
void Set_tx_start()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=3;//第0位
    //寄存器控制字，第0位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//清除发射结束标志位
void Clear_tx_end_flag()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=4;//第0位
    //寄存器控制字，第0位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//设置输出数据有效
void Set_tx_data_valid()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=5;//第0位
    //寄存器控制字，第0位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//获取发射是否结束标志位
bool Get_tx_end_flag()
{
    // uint32_t reg_addr=PS_AXI_CTRL_BASEADDR + 4*2;
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*1);
    uint8_t bit=1;//第0位
    uint32_t reg_value = *reg_addr;  // 读取第寄存器
    return (reg_value & (1<<bit)) >> bit;
}
//设置发射符号速率控制字
void Set_tx_FTW(uint32_t tx_FTW)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*10);
    //寄存器控制字
    *reg_addr = tx_FTW;  // 写入寄存器
}
//设置发射数据量（以字为单位）
void Set_tx_data_num(uint32_t tx_data_num)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*11);
    //寄存器控制字
    *reg_addr = tx_data_num;  // 写入寄存器
}
//设置发射数据
void Set_tx_data(uint32_t tx_data)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*12);
    //寄存器控制字
    *reg_addr = tx_data;  // 写入寄存器
}

//-------------接收机相关函数---------------
//设置开始接收
void Set_rx_start()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=6;//第0位
    //寄存器控制字，第0位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//使能读取数据，函数使用一次数据更新一次
void Set_rx_rd_en()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=7;//第0位
    //寄存器控制字，第0位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//清除接收结束标志位
void Clear_rx_end_flag()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=8;//第0位
    //寄存器控制字，第0位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//清除接收错误标志位
void Clear_rx_error_flag()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=9;//第0位
    //寄存器控制字，第0位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//获取接收是否结束标志位
bool Get_rx_end_flag()
{
    // uint32_t reg_addr=PS_AXI_CTRL_BASEADDR + 4*2;
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*1);
    uint8_t bit=2;//第0位
    uint32_t reg_value = *reg_addr;  // 读取第寄存器
    return (reg_value & (1<<bit)) >> bit;
}
//获取接收是否错误标志位
bool Get_rx_error_flag()
{
    // uint32_t reg_addr=PS_AXI_CTRL_BASEADDR + 4*2;
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*1);
    uint8_t bit=3;//第0位
    uint32_t reg_value = *reg_addr;  // 读取第寄存器
    return (reg_value & (1<<bit)) >> bit;
}
//获取接收的数据量(以字为单位)
uint32_t Get_rx_num()
{
    // uint32_t reg_addr=PS_AXI_CTRL_BASEADDR + 4*2;
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*13);
    uint32_t reg_value = *reg_addr;  // 读取第寄存器
    return reg_value;
}
//获取接收的数据
uint32_t Get_rx_data()
{
    // uint32_t reg_addr=PS_AXI_CTRL_BASEADDR + 4*2;
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*14);
    uint32_t reg_value = *reg_addr;  // 读取第寄存器
    return reg_value;
}
