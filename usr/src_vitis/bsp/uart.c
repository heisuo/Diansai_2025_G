#include "uart.h"
#include "timer.h"
#include <stdio.h>
#include <xil_types.h>
#include <xscugic.h>
#include <xuartps.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

u8 RecvBuffer[RX_BUFFER_SIZE];	/* 数据接收缓冲区 */
char TxBuffer[RX_BUFFER_SIZE];	/* 数据接收缓冲区 */
char mode[32] = {0};
char data[64] = {0};
UartRxResult RxResult;
u32 rx_delay_10ms=0;
u8 rx_total_num;
void Handler(void *CallBackRef, u32 Event, unsigned int EventData)
{
    XUartPs *InstancePtr = (XUartPs *) CallBackRef;
	/* 全部数据已发送 */
	if (Event == XUARTPS_EVENT_SENT_DATA) {
	}
	/* 全部数据已接收 */
	if (Event == XUARTPS_EVENT_RECV_DATA) {
        XUartPs_Send(InstancePtr, RecvBuffer, EventData);
        XUartPs_Recv(InstancePtr, RecvBuffer, RX_BUFFER_SIZE);
        // memset(RecvBuffer,0,sizeof(RecvBuffer));
	}
	/*
	 * 数据已接收但非预期字节数
	 * 超时仅表示数据停止8个字符时间
	 */
	if (Event == XUARTPS_EVENT_RECV_TOUT) {
        // XUartPs_Send(InstancePtr, RecvBuffer, EventData);
        // if (parse_string((char *)RecvBuffer, mode, data) == 0)
        // {
        //     RxResult.rx_flag=1;
        // }
        // else RxResult.rx_error=1;
        RxResult.rx_total_num+=EventData;
        rx_delay_10ms=Get_time_value();
        RxResult.rx_int_flag=1;
        // XUartPs_Recv(InstancePtr, RecvBuffer+rx_total_num, RX_BUFFER_SIZE-rx_total_num);
        // memset(RecvBuffer,0,sizeof(RecvBuffer));
	}
}

u8 Rx_Mode_Choose(char *mode)
{
    if(strcmp(mode, "M")==0){
        return 1;
    }else if(strcmp(mode, "F")==0){
        return 10;
    }else if (strcmp(mode, "V")==0) {
        return 11;
    }else if (strcmp(mode, "FI")==0) {
        return 12;
    }
    return 0;
    //。。。。。
}

// 解析字符串函数
// 输入：input - 原始字符串
// 输出：mode - 存储提取的模式字符串
//       data - 存储提取的数据字符串
// 返回值：0 成功，-1 失败
int parse_string(const char* input, char* mode, char* data) 
{
    // 查找'*'字符位置
    const char* star = strchr(input, '*');
    if (star == NULL) {
        fprintf(stderr, "错误：未找到'*'\n");
        return -1;
    }
    star++;  // 跳过'*'字符

    // 查找左括号'('位置
    const char* open_paren = strchr(star, '(');
    if (open_paren == NULL) {
        fprintf(stderr, "错误：未找到'('\n");
        return -1;
    }

    // 计算模式字符串长度并复制
    size_t mode_len = open_paren - star;
    if (mode_len == 0) {
        fprintf(stderr, "错误：模式字符串为空\n");
        return -1;
    }
    strncpy(mode, star, mode_len);
    mode[mode_len] = '\0';  // 确保字符串结束

    // 查找右括号')'位置
    const char* close_paren = strchr(open_paren, ')');
    if (close_paren == NULL) {
        fprintf(stderr, "错误：未找到')'\n");
        return -1;
    }

    // 计算数据字符串长度并复制
    size_t data_len = close_paren - (open_paren + 1);
    if (data_len == 0) {
        fprintf(stderr, "警告：数据字符串为空\n");
        // 这里不返回错误，空数据可能是允许的
    }
    strncpy(data, open_paren + 1, data_len);
    data[data_len] = '\0';  // 确保字符串结束

    return 0;
}




void UARTInit(XUartPs *UartInstPtr, UINTPTR BaseAddress)
{
    int Status;
	XUartPs_Config *Config;
	u32 IntrMask;
	/*
	 * 初始化UART驱动程序使其就绪
	 * 在配置表中查找配置，然后进行初始化
	 */
	Config = XUartPs_LookupConfig(BaseAddress);
	Status = XUartPs_CfgInitialize(UartInstPtr, Config, Config->BaseAddress);
	/* 硬件自检 */
	Status = XUartPs_SelfTest(UartInstPtr);
	/*
	 * 连接UART到中断子系统以使中断发生
	 * 此函数是应用特定的
	 */
	Status = XSetupInterruptSystem(UartInstPtr, &XUartPs_InterruptHandler,
				       Config->IntrId, Config->IntrParent,
				       XINTERRUPT_DEFAULT_PRIORITY);
	if (Status != XST_SUCCESS) {
		printf("中断系统启动失败\n");
	}
	/*
	 * 为UART设置处理函数，这些函数将在数据发送和接收时从中断上下文调用
	 * 指定指向UART驱动程序实例的指针作为回调引用，以便处理程序可以访问实例数据
	 */
	XUartPs_SetHandler(UartInstPtr, (XUartPs_Handler)Handler, UartInstPtr);

	XUartPs_SetRecvTimeout(UartInstPtr, 8);
    XUartPs_SetFifoThreshold(UartInstPtr, 32);//设置fifo阈值32

	IntrMask = XUARTPS_IXR_TOUT | XUARTPS_IXR_RXOVR;
	XUartPs_SetInterruptMask(UartInstPtr, IntrMask);
	XUartPs_Recv(UartInstPtr, RecvBuffer, RX_BUFFER_SIZE);
}