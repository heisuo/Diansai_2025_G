#include "main.h"
//-------------发射机相关函数---------------
//填充数据
void tx_data2fifo(uint32_t *data,uint32_t tx_data_num);
//设置开始发射
void Set_tx_start();
//清除发射结束标志位
void Clear_tx_end_flag();
//设置输出数据有效
void Set_tx_data_valid();
//获取发射是否结束标志位
bool Get_tx_end_flag();
//设置发射符号速率控制字
void Set_tx_FTW(uint32_t tx_FTW);
//设置发射数据量（以字为单位）
void Set_tx_data_num(uint32_t tx_data_num);
//设置发射数据
void Set_tx_data(uint32_t tx_data);

//-------------接收机相关函数---------------
//设置开始接收
void Set_rx_start();
//使能读取数据，函数使用一次数据更新一次
void Set_rx_rd_en();
//清除接收结束标志位
void Clear_rx_end_flag();
//清除接收错误标志位
void Clear_rx_error_flag();
//获取接收是否结束标志位
bool Get_rx_end_flag();
//获取接收是否错误标志位
bool Get_rx_error_flag();
//获取接收的数据量(以字为单位)
uint32_t Get_rx_num();
//获取接收的数据
uint32_t Get_rx_data();