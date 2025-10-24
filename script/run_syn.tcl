# 运行编译

set base_dir [file normalize [file dirname [file dirname [info script]]]]
puts "$base_dir"
# 在命令行获取工程名
set proj_name [lindex $argv 0]
#打开工程
open_project $base_dir/prj/$proj_name.xpr
## 设置顶层文件
# 在命令行获取顶层文件名
set top_module_src [lindex $argv 1]
#设置顶层并更新工程
set_property top $top_module_src [get_filesets sources_1]
update_compile_order -fileset sources_1
proc validate_src_top {src_top} {
  # 检查代码顶层是否设置成功
  set current_src_top [get_property TOP [get_filesets sources_1]]
  if {$current_src_top ne $src_top} {
    return 0
  }
  return 1
}
# 检查hdl顶层是否设置成功
if {[validate_src_top $top_module_src]} {
    puts "hdl顶层设置成功"
} else {
    error "error:顶层文件不存在，无法编译"
}

##开始编译
reset_run synth_1
launch_runs synth_1 -jobs 32
wait_on_run synth_1
