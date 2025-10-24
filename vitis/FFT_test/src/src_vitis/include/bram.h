#ifndef BRAM_H
#define BRAM_H
#include "main.h"
// 获取BRAM数据
// 实际上该函数返回的是一个地址
volatile int16_t* Get_bram_data(UINTPTR bram_baseaddr);
//设置bram采集计划
void Set_bram_plan(uint32_t bram_baseaddr,uint32_t bram_channel,uint32_t sample_length);
//bram传输测试
void bram_test();
//获取bram传输是否结束标志位
bool Get_bram_pl2ps_done();
//设置bram传输开始
void Set_bram_pl2ps_start();
//清除bram传输是否结束标志位
void Clear_bram_pl2ps_done();
//设置bram采样长度
void Set_bram_sample_length(uint32_t sample_length);
//设置bram起始采集地址
void Set_bram_sample_addr(uint32_t bram_baseaddr);
//设置bram采集通道
void Set_bram_channel(uint32_t bram_channel);
#endif