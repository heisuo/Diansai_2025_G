# ======================================================
# setup.tcl
# 说明:
#   本脚本用于创建 Vivado 工程，工程目录位于当前目录下的 prj 文件夹中。
#   工程源文件存放在 usr/src（支持子目录）、IP 核在 usr/ip，测试平台在 usr/tb。
#   请根据实际情况修改器件型号和顶层模块名称。
# ======================================================

# 获取脚本上一级目录作为工程根目录
# 假设脚本路径为：/home/user/project/script/main.tcl
# [info script]             → /home/user/project/script/main.tcl
# 第一次 file dirname      → /home/user/project/script
# 第二次 file dirname      → /home/user/project
# file normalize 处理后     → 绝对路径 /home/user/project
set base_dir [file normalize [file dirname [file dirname [info script]]]]
puts "$base_dir"
# 定义工程存放目录（prj 文件夹）
set prj_dir "$base_dir/prj"

# 在命令行获取工程名
set proj_name [lindex $argv 0]

# 创建工程（请将 -part 后面的器件型号改为实际目标器件）
create_project $proj_name $prj_dir -force -part [lindex $argv 1]

# --------------------------
# 添加 用户IP 文件路径
# --------------------------
set_property  ip_repo_paths  [lindex $argv 2] [current_project]
update_ip_catalog

# 定义一个递归过程，用于搜索添加符合模式的文件
# dir为当前搜索的根文件夹
# pattern为搜索的文件后缀
# fileset为要加入的文件集：有sources_1，sim_1，constrs_1等
proc add_files_recursively {dir pattern fileset} {
    # 添加当前目录下的所有匹配文件
    foreach file [glob -nocomplain -directory $dir $pattern] {
        add_files -fileset $fileset -norecurse $file
    }
    # 遍历当前目录下所有子目录，递归调用该过程
    foreach sub [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $sub]} {
            add_files_recursively $sub $pattern $fileset
        }
    }
}
# 定义一个递归过程，用于添加符合模式的文件
proc search_files_recursively {dir pattern} {
    # 添加当前目录下的所有匹配文件
    foreach file [glob -nocomplain -directory $dir $pattern] {
        $file 
    }
    # 遍历当前目录下所有子目录，递归调用该过程
    foreach sub [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $sub]} {
            add_files_recursively $sub $pattern
        }
    }
}
# --------------------------
# 添加设计源文件（来自 usr/src 文件夹及其子目录）
# --------------------------
set src_dir "$base_dir/usr/src"

# 搜索添加所有 Verilog 源文件 (*.v)
add_files_recursively $src_dir "*.v" sources_1

add_files_recursively $src_dir "*.vhd" sources_1

add_files_recursively $src_dir "*.sv" sources_1

# --------------------------
# 添加 IP 核文件（来自 usr/ip 文件夹）
# --------------------------
set ip_dir "$base_dir/usr/ip"

# 递归添加所有 IP 文件 (*.xci)
add_files_recursively $ip_dir "*.xci" sources_1

# --------------------------
# 添加测试平台文件（来自 usr/tb 文件夹，可选）
# --------------------------
set tb_dir "$base_dir/usr/tb"

#把hdl集的文件全部给仿真集
set_property SOURCE_SET sources_1 [get_filesets sim_1] 
#搜索添加仿真文件
add_files_recursively $tb_dir "*.vhd" sim_1
add_files_recursively $tb_dir "*.v" sim_1
add_files_recursively $tb_dir "*.sv" sim_1


#添加硬件约束
set xdc_dir "$base_dir/usr/xdc"
#搜索添加所有约束文件
add_files_recursively $xdc_dir "*.xdc" constrs_1
#设置目标约束文件
# set_property target_constrs_file /home/yian/project/FPGA/Script_project/usr/xdc/constrs_1/new/UART.xdc [current_fileset -constrset]
# --------------------------
# 添加 blockdesign（来自 usr/bd 文件夹）
# --------------------------
set bd_dir "$base_dir/usr/bd"
# add_files_recursively $bd_dir "*.bd" sources_1
foreach file [glob -nocomplain -directory "$base_dir/usr/bd" *.tcl] {
    source $file
}

# 获取所有IP，并将结果存储在变量中
set ips [get_ips]

# 检查IP列表是否非空
if {[llength $ips] > 0} {
    # 存在IP时执行升级
    # report_ip_status -name ip_status
    # update_module_reference $ips
    upgrade_ip $ips
}




