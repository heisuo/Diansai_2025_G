#include "bram.h"
// 获取BRAM数据
// 实际上该函数返回的是一个地址
volatile int16_t* Get_bram_data(UINTPTR bram_baseaddr) 
{
    return (volatile int16_t*)bram_baseaddr;
}
//设置bram采集计划
void Set_bram_plan(uint32_t bram_baseaddr,uint32_t bram_channel,uint32_t sample_length)
{
    Set_bram_sample_addr(bram_baseaddr);
    Set_bram_channel(bram_channel);
    Set_bram_sample_length(sample_length);
}
//bram传输测试
void bram_test()
{
    //设置bram采集计划
    Set_bram_plan(BRAM_CHANEL0_BASEADDR,0,100);
    Set_bram_pl2ps_start();
    while (!Get_bram_pl2ps_done()) {
    }
    Clear_bram_pl2ps_done();
    // 读取bram数据
    // 将基地址转换为volatile int16_t指针（16位有符号）
    volatile int16_t *data_ptr = Get_bram_data(BRAM_CHANEL0_BASEADDR);
    // volatile int16_t *data_ptr =(volatile int16_t*)bram_baseaddr;
    // 打印提示信息
    printf("从地址 0x%08X 读取的100个16位有符号数据：\n", BRAM_CHANEL0_BASEADDR);
    // 遍历100个数据
    for (int i = 0; i < 100; i++) {
        // 每10个数换一行
        if (i % 10 == 0 && i != 0) {
            printf("\n");
        }
        // 打印数据（格式化为有符号十进制）
        printf("%6d ", data_ptr[i]);
    }
    // 最后换行
    printf("\n");
    printf("PL2PS OK!! \n");
}

//获取bram传输是否结束标志位
bool Get_bram_pl2ps_done()
{
    // uint32_t reg_addr=PS_AXI_CTRL_BASEADDR + 4*2;
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*1);
    uint8_t bit=0;//第0位
    uint32_t reg_value = *reg_addr;  // 读取第寄存器
    return (reg_value & (1<<bit)) >> bit;
}
//设置bram传输开始
void Set_bram_pl2ps_start()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=0;//第0位
    //寄存器控制字，第0位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//清除bram传输是否结束标志位
void Clear_bram_pl2ps_done()
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*0);
    uint8_t bit=1;//第1位
    //寄存器控制字，第1位置高后再置低
    *reg_addr = 1<<bit;  // 写入寄存器
    *reg_addr = 0;  // 写入寄存器
}
//设置bram采样长度
void Set_bram_sample_length(uint32_t sample_length)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*2);
    //寄存器控制字
    *reg_addr = sample_length;  // 写入寄存器
}
//设置bram起始采集地址
void Set_bram_sample_addr(uint32_t bram_baseaddr)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*3);
    //寄存器控制字
    *reg_addr = bram_baseaddr;  // 写入寄存器
}
//设置bram采集通道,0~3
void Set_bram_channel(uint32_t bram_channel)
{
    // 定义指针变量并初始化为寄存器地址
    volatile uint32_t *reg_addr = (volatile uint32_t*)(PS_AXI_CTRL_BASEADDR + 4*4);
    //寄存器控制字，第1位置高后再置低
    *reg_addr = bram_channel;  // 写入寄存器
}