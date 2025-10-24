# 说明
本工程为电赛
# 环境要求

在linux环境下配置好vivado和vitis环境

vivado版本为2024.2

依赖make

# 工程目录结构与解析

```
.
├── readme.txt
├── makefile
├── fir_dec_40.96e6_500e3_1138.4e3.coe
├── fir_lpf_102.4e6_1e6_19.48e6.coe
├── ip_repo
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
+ prj：vivado工程文件夹
+ script：脚本文件夹
+ usr/bd：blockdesign工程导出文件
+ usr/ip：IP文件
+ usr/src：hdl源文件
+ usr/src_vitis：c语言源文件
+ usr/tb：仿真源文件
+ usr/xdc：引脚约束文件
+ vitis：vitis工程文件
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