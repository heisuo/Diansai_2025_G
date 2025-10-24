#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 导入必要的库
import vitis        # Vitis核心功能库
import os           # 操作系统接口
import argparse     # 用来传入命令行参数
import json         #json包，用来解析传入的字符串和修改launch.json的属性
import shutil       # 高级文件操作
import platform as os_platform # 系统平台信息
import sys          #系统包
# 打印分隔线和描述
print ("\n-----------------------------------------------------")
print ("建立vitis工程\n")
# 创建Vitis客户端对象（建立与Vitis服务器的连接）
client = vitis.create_client()
#命名行传入参数
parser = argparse.ArgumentParser(description='命令行参数输入')
parser.add_argument('--vitis_workspace', '-workspace', type=str, required=True, help='vitis相对工作路径')#required=True表示必须要有输入
parser.add_argument('--user_link_libraries', '-user_link_libraries', type=str, required=True, help='链接的外部库')
parser.add_argument('--inlude_dir', '-inlude_dir', type=str, required=True, help='头文件路径')
parser.add_argument('--platform_name', '-platform_name', type=str, required=True, help='硬件平台名')
parser.add_argument('--app_name', '-app_name', type=str, required=True, help='app名')
parser.add_argument('--stack_size', '-stack_size', type=str, required=True, help='栈大小')
parser.add_argument('--heap_size', '-heap_size', type=str, required=True, help='堆大小')
parser.add_argument('--xsa_dir', '-xsa_dir', type=str, required=True, help='xsa文件路径')
parser.add_argument('--template', '-template', type=str, required=True, help='使用的内置模板')

args = parser.parse_args()

# 获取当前路径（工作路径）
work_path = os.getcwd()  # 返回字符串类型

## 命令行变量
# vitis工作区
workspace = work_path + "/" + args.vitis_workspace
# xsa文件路径
xsa_dir = args.xsa_dir
# 硬件平台名字
platform_name = args.platform_name
# platform_name = "platform0"
# app平台名字
app_name = args.app_name
template = args.template #使用的内置模板
# 用户链接库
user_link_libraries = json.loads(args.user_link_libraries)# 解析JSON字符串
#栈大小
stack_size = args.stack_size
#堆大小
heap_size = args.heap_size
# 头文件路径
include_dir=json.loads(args.inlude_dir)# 解析JSON字符串
# 硬件平台是否存在
if_platform_exit = False
#打印信息
print(f"主工作区路径: {work_path}")
print(f"vitis工作区路径: {workspace}")
print(f"xsa文件路径: {xsa_dir}")
print(f"硬件平台名: {platform_name}")
print(f"裸机平台名: {app_name}")
print(user_link_libraries)
# 创建前检验
platform_path = os.path.join(workspace, platform_name)#路径拼接
if os.path.exists(platform_path):
    if_platform_exit = True 
    import glob
    # 查找目录下xsa文件
    xsa_files = glob.glob(f"{workspace}/{platform_name}/hw/*.xsa")
    # 提取文件名并比较，如果不一样就报错并退出（带扩展名）
    platform_xsa = os.path.basename(xsa_files[0])
    target_xsa = os.path.basename(xsa_dir)
    if platform_xsa!=target_xsa:
        print(f"error:硬件平台<{platform_name}>的xsa文件<{platform_xsa}>与目标xsa文件<{target_xsa}>不同")
        sys.exit(1)
    # shutil.rmtree(platform_path)
platform_path = os.path.join(workspace, app_name)
if os.path.exists(platform_path):
    # shutil.rmtree(platform_path)
    print(f"error:app<{app_name}>已存在")
    sys.exit(1)
## 创建硬件平台
client.set_workspace(workspace)
client.update_workspace(workspace)
# 创建硬件平台
if if_platform_exit==False:
    # platform = client.create_platform_component(name = platform_name,hw_design = xsa_dir)
    # platform.report()  # 生成平台报告
    # # 添加裸机域（指定CPU核和操作系统）
    # standalone_a9_0 = platform.add_domain(
    #     name = "standalone_a9_0",  # 域名称
    #     cpu = "ps7_cortexa9_0",     # 指定ARM Cortex-A9处理器
    #     os = "standalone"           # 使用裸机操作系统
    # )
    platform = client.create_platform_component(
        name = platform_name,
        hw_design = xsa_dir,
        os = "standalone",
        cpu = "ps7_cortexa9_0",
        domain_name = "standalone_ps7_cortexa9_0"
        )
    #设置两个库，这两个库用于固化启动
    domain = platform.get_domain(name="standalone_ps7_cortexa9_0")
    status = domain.set_lib(lib_name="xilffs", path="/tools/Xilinx/Vitis/2024.2/data/embeddedsw/lib/sw_services/xilffs_v5_3")
    status = domain.set_lib(lib_name="xilrsa", path="/tools/Xilinx/Vitis/2024.2/data/embeddedsw/lib/sw_services/xilrsa_v1_8")
    # 构建平台（生成可用的硬件平台文件）
    platform.build()
# 查找生成的平台文件（XPFM格式）
platform_xpfm = client.find_platform_in_repos(platform_name)

# 创建应用组件
app_component = client.create_app_component(
    name = app_name,       # 应用组件名称
    platform = platform_xpfm,      # 使用的平台
    domain = 'standalone_a9_0',   # 目标域
    template = template      # 使用内置模板
)
if template=="hello_world":
    #删除原来的hello.c
    status = app_component.remove_app_config(key ="USER_COMPILE_SOURCES",values = "helloworld.c")
    # print(status)
    app_component.remove_files(files = [f"{workspace}/{app_name}/src/helloworld.c"] )

#导入文件
app_component.import_files(from_loc = f"{work_path}/usr", files = ["src_vitis"], dest_dir_in_cmp = 'src')
# app_component.append_app_config(key ="USER_COMPILE_SOURCES", values = "/home/yian/s_empty_prj/usr/src_vitis/main.c")
#添加库搜索路径
app_component.append_app_config(key ="USER_LINK_DIRECTORIES", values = "/home/yian/Ne10/fftw-3.3.10/build/lib")
#添加其他编译选项（针对DSP库）,注意用set_app_config
app_component.set_app_config(key ="USER_COMPILE_OTHER_FLAGS", values = "-mfpu=neon-vfpv4 -mcpu=cortex-a9 -mfloat-abi=hard")
#添加其他链接选项
app_component.set_app_config(key ="USER_LINK_OTHER_FLAGS", values = "-mfpu=neon-vfpv4 -mcpu=cortex-a9 -mfloat-abi=hard")
#添加编译宏定义 
app_component.append_app_config(key ="USER_COMPILE_DEFINITIONS", values = ["DISABLEFLOAT16","ARM_MATH_NEON"])
#添加库 
app_component.append_app_config(key ="USER_LINK_LIBRARIES", values = user_link_libraries)
#添加头文件路径
app_component.append_app_config(key ="USER_INCLUDE_DIRECTORIES", values = include_dir)
#获取链接脚本对象
ld_file = app_component.get_ld_script()
#修改堆栈大小
ld_file.set_stack_size(stack_size)
ld_file.set_heap_size(heap_size)
#编译
app_component.build()

## 修改luach.json
with open(f'{workspace}/{app_name}/_ide/launch.json', 'r') as f:
    luachfile = json.load(f)
# 修改为FSBL的方式启动，这种启动方式比tcl方式更稳定
luachfile["configurations"][0]["targetSetup"]["zynqInitialization"]["isFsbl"]=True
# 写入修改后的内容
# indent=4保持缩进格式
# ensure_ascii=False保留非ASCII字符
with open(f'{workspace}/{app_name}/_ide/launch.json', 'w') as f:
    json.dump(luachfile, f, indent=4, ensure_ascii=False)

## 定义vscode配置文件
# 定义文件路径
vscode_dir = f"{workspace}/{app_name}/src/src_vitis/.vscode"
config_file = os.path.join(vscode_dir, "c_cpp_properties.json")
# 创建.vscode目录（如果不存在）
os.makedirs(vscode_dir, exist_ok=True)
# 配置文件内容
config_content = {
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "${workspaceFolder}/**",
                f"{workspace}/{platform_name}/export/platform0/sw/standalone_ps7_cortexa9_0/include"
            ],
            "intelliSenseMode": "linux-gcc-x64",
            "compilerPath": "/usr/local/bin/gcc",
            "cStandard": "c17",
            "cppStandard": "gnu++14"
        }
    ],
    "version": 4
}
# 添加makefile里配置的所有头文件路径
config_content["configurations"][0]["includePath"].extend(include_dir)
# 写入文件
with open(config_file, 'w', encoding='utf-8') as f:
    json.dump(config_content, f, indent=4, ensure_ascii=False)
print(f"vscode配置文件已生成：{config_file}")

# 创建clangd配置文件
clangd_content = """
Diagnostics:
  Suppress: unused-includes #屏蔽警告
CompileFlags:
    Add: [-Wno-unknown-warning-option, -U__linux__, -U__clang__]
    Remove: [-m*, -f*]
""".strip()

with open(f"{workspace}/{app_name}/src/src_vitis/.clangd", "w", encoding="utf-8") as f:
    f.write(clangd_content)

print("配置文件已生成：.clangd")
# 关闭客户端连接并释放Vitis服务器资源
vitis.dispose()