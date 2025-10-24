## 设置静态仿真

set base_dir [file normalize [file dirname [file dirname [info script]]]]
puts "$base_dir"
# 在命令行获取工程名
set proj_name [lindex $argv 0]
#打开工程
open_project $base_dir/prj/$proj_name.xpr
## 设置顶层文件
# 在命令行获取顶层文件名
set top_module_sim [lindex $argv 1]
#设置顶层并更新工程
set_property top $top_module_sim [get_filesets sim_1]
update_compile_order -fileset sim_1
proc validate_sim_top {sim_top} {
  # 检查仿真顶层是否设置成功
  set current_sim_top [get_property TOP [get_filesets sim_1]]
  if {$current_sim_top ne $sim_top} {
    return 0
  }
  return 1
}

# 检查仿真顶层是否设置成功，成功则导出仿真脚本
if {[validate_sim_top $top_module_sim]} {
    # 仿真模式为VCS
    set_property target_simulator VCS [current_project]
    # 设置最大仿真时间1s
    set_property -name {vcs.simulate.runtime} -value {1000ms} -objects [get_filesets sim_1]
    #编译设置,这一步主要是为了创建.daidir数据库
    set_property -name {vcs.compile.vlogan.more_options} -value {-kdb} -objects [get_filesets sim_1]
    # 添加编译参数-kdb -debug_access+all
    set_property -name {vcs.elaborate.debug_acc} -value {false} -objects [get_filesets sim_1]
    set_property -name {vcs.elaborate.vcs.more_options} -value {-kdb -timescale=1ns/100ps} -objects [get_filesets sim_1]
    # set_property -name {vcs.elaborate.vcs.more_options} -value {-kdb -debug_access+all -timescale=1ns/1ps} -objects [get_filesets sim_1]
    # 设置仿真参数
    set_property -name {vcs.simulate.vcs.more_options} -value {} -objects [get_filesets sim_1]
    # set_property -name {vcs.simulate.vcs.more_options} -value {-gui=verdi} -objects [get_filesets sim_1]
    # 加载所有信号
    set_property -name {vcs.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
    # 导出仿真脚本，-lib_map_path为预编译库的路径
    export_simulation  -lib_map_path "/tools/Xilinx/Vivado/2024.2/vcs_lib" -force -directory "$base_dir" -simulator vcs
    puts "仿真脚本导出成功"
} else {
    error "error：仿真顶层不存在，无法编译"
}

exit