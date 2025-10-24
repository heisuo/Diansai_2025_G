# 介绍
本项目为2025年电赛G题满分工程，使用异构FPGA-ZYNQ7100单主控，充分利用了PS与PL两侧的计算资源

本系统实现了对未知滤波器的类型辨识与动态建模，并能够准确复现其滤波特性。

学习建模阶段，采用DDS扫频信号作为激励，同步采集滤波器输入与输出信号；在PS端计算各频点的幅度衰减与相位偏移，完成参数辨识与量化；将量化后的参数写入PL端的RAM中，作为滤波器模型的频域表征。

滤波模拟阶段，采用流式FFT-IFFT处理架构，对输入信号进行实时频域变换；在频域中，根据已存储的相位与幅度参数，依次进行坐标旋转（相位补偿）与幅度缩放；通过IFFT将处理后的频域信号恢复为时域波形，精准复现目标滤波器的响应特性。

实现了全硬件加速的频域参数辨识与信号重建，同时支持动态更新滤波器模型，具备良好的可重构性与实时性。

# 关键技术要点

### 自动化工程管理
实现工程的快捷重构(还原各项初始配置)、编译、仿真等功能。工程文件与源码分离，方便进行工程管理与协作，readme文件有基本的使用方法，使用详情见 [Xilinx工程自动化：基于脚本的Vivado/Vitis快速配置与项目管理方案 – heisuo的分享栈](http://www.heisuo.top/archives/455)

### 特殊采样率
输入信号采样率为102.4M，对输入信号进行125/2分数倍抽样，得到1.6384M采样率的信号，进过频域滤波器处理后进行125/2分数倍插值后输出

### 频域滤波器
采用流式FFT-IFFT处理架构，在PL端部署流式FFT IP核与IFFT IP核

### PS与PL交互
通过AXI_lite总线IP核(ps_axi_ctrl_new)实现各类交互，实现ps端控制写入PL端ram，参与PL端的各类时序控制与状态控制。

### 高精度计算
PS端对关键参数进行双精度浮点计算，进行定点量化后再写入PL端参与计算

# 环境要求

需在linux环境下配置好vivado和vitis环境

vivado版本为2024.2，vitis为新版IDE

依赖make进行工程管理，脚本语言python3为vitis安装后自带

# 工程目录结构与解析

```
.
├── readme.txt
├── makefile
├── fir_dec_40.96e6_500e3_1138.4e3.coe
├── fir_lpf_102.4e6_1e6_19.48e6.coe
├── ip_repo
│   ├── ADDA_jilin
│   ├── DDS
│   ├── FFT_learn
│   ├── ila_div_trigger
│   ├── ps_axi_ctrl_new
├── prj
├── script
├── usr
│   ├── bd
│   ├── ip
│   ├── src
│   ├── src_vitis
│   ├── tb
│   └── xdc
├── vitis
└── xsa
```
+ readme.md：使用说明
+ makefile：统一管理script文件夹中的tcl脚本和python脚本，实现参数化配置
+ fir_coe文件：fir滤波器的配置文件
+ ip_repo：IP文件夹
  + ADDA_jilin：ADDA驱动
  + DDS：DDS IP
  + FFT_learn：核心IP，包含学习扫频、频域滤波等核心代码
  + ila_div_trigger：调试IP，里面包含了vio IP，配合ila高级功能可以调整ila的采样速度
  + ps_axi_ctrl_new：控制IP，实现对pl所有模块的控制和小数据量读写
+ prj：vivado工程文件夹(一开始没有，需要运行make set命令建立工程)
+ script：脚本文件夹
+ usr/bd：blockdesign工程导出文件
+ usr/ip：IP文件
+ usr/src：hdl源文件
+ usr/src_vitis：c语言源文件
+ usr/tb：仿真源文件
+ usr/xdc：引脚约束文件
+ vitis：vitis工程文件(一开始没有，需要运行make setv命令建立工程)
+ xsa：硬件平台

# 如何使用工程？
克隆工程

```shell
git clone https://github.com/heisuo/Diansai_2025_G.git
```

重建工程
```
进入工程根目录
建立vivado工程，终端输入命令：make set （原有工程会被覆盖）
打开vivado工程，终端输入命令：make gui
直接建立并打开工程：终端输入命令：make set gui
重建vitis工程，终端输入命令：make resetv
```

# 如何使用脚本？
终端输入命令：make help