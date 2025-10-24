#include "main.h"
#include <stdbool.h>
#include <stdint.h>
// 定义解析结果结构体
typedef struct {
    u8 mode;   // 存储模式
    int32_t data_i;   // 存储数据
    float data_f;     //存储浮点数据
    bool rx_flag;   // 是否成功解析到数据
    bool rx_error;  //解析失败
    bool rx_int_flag;//是否接收到数据
    u8 rx_total_num;
} UartRxResult;

void UARTInit(XUartPs *UartInstPtr, UINTPTR BaseAddress);
int parse_string(const char* input, char* mode, char* data) ;
u8 Rx_Mode_Choose(char *mode);
bool str_to_fixed32(const char* str, int32_t* result) ;