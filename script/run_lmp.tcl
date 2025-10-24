#布线

# 运行编译
set base_dir [file normalize [file dirname [file dirname [info script]]]]
set xdc_dir "$base_dir/usr/xdc"
# 在命令行获取工程名
set proj_name [lindex $argv 0]
#打开工程
open_project $base_dir/prj/$proj_name.xpr
# 在命令行获取目标约束文件名
set target_xdc [lindex $argv 1]

##设置目标约束文件
set target_xdc_dir "$xdc_dir/$target_xdc.xdc"
set_property target_constrs_file $target_xdc_dir [get_filesets constrs_1]


##布局布线
reset_run impl_1
launch_runs impl_1 -jobs 32
wait_on_run impl_1