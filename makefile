BASE_DIR := $(shell pwd)
############### vivado相关变量 ###############
#vivado工程名字
proj_name := zynq_base
#器件
# xc7s6ftgb196-1
# xc7z020clg400-2
# xc7z100ffg900-2
device := xc7z100ffg900-2
#顶层模块
TOP_SRC := uart_tx_AXI_BUF_top
TOP_SIM := IFFT_loop_tb
#目标约束文件
target_xdc := UART
#用户IP路径
usr_ip_repo_paths := $(BASE_DIR)/ip_repo
# 定义关键路径变量
TCL_DIR := $(BASE_DIR)/script
vivado := vivado -nolog -nojournal
############### vitis相关变量 ###############
#vitis工作区名字
vitis_spacename := vitis
# 硬件平台名字,不能是platform，会报错..
platform_name := platform0
#app工程名字
app_name := FFT_test
#xsa文件路径
xsa_name := ZYNQ_TOP_wrapper2
xsa_dir := $(BASE_DIR)/xsa/$(xsa_name).xsa
#栈大小,默认是0x2000,8kB,0x100000表示1MB
stack_size := 0x800000
#堆大小
heap_size := 0x800000
#使用的内置模板
#  empty_application
#  hello_world
template := empty_application
#vitis源码路径
src_vitis_dir := $(BASE_DIR)/$(vitis_spacename)/$(app_name)/src
#用户链接库
user_link_libraries := '["fftw3f","m"]'
#inlude_dir，使用JSON格式字符串，最外面要单引号，里面双引号，不然会报错
# "/home/yian/Ne10/fftw-3.3.10/build/include"
inlude_dir := '[\
				"$(src_vitis_dir)/src_vitis",\
				"$(src_vitis_dir)/src_vitis/bsp",\
				"$(src_vitis_dir)/src_vitis/include",\
				"/home/yian/Ne10/fftw-3.3.10/build/include"\
				]'
# 备份vitis代码
.PHONY: resetv
resetv: cpv cleanv setv guiv
	@echo "重建vitis工程"

# 备份vitis代码
.PHONY: cleanv
cleanv:
	@echo "删除vitis工程代码"
	rm -rf $(BASE_DIR)/$(vitis_spacename)

# 备份vitis代码
.PHONY: cpv
cpv:
	@echo "备份vitis工程代码"
	rm -rf $(BASE_DIR)/usr/src_vitis
	cp -rf $(src_vitis_dir)/src_vitis $(BASE_DIR)/usr

# 打开vitis工程
.PHONY: guiv
guiv:
	@echo "打开vitis工程"
	rm -rf /home/yian/.Xilinx/Vitis/2024.2 #清除原来的工作区缓存
	vitis -w $(BASE_DIR)/$(vitis_spacename)

# 创建vitis工程
.PHONY: setv
setv:
	@echo "建立vitis工程"
	vitis -s tcl/set_vitis.py \
	-workspace $(vitis_spacename) \
	-user_link_libraries $(user_link_libraries) \
	-inlude_dir $(inlude_dir) \
	-platform_name $(platform_name) \
	-app_name $(app_name) \
	-stack_size $(stack_size) \
	-heap_size $(heap_size) \
	-xsa_dir $(xsa_dir) \
	-template $(template)

# 创建vivado工程
.PHONY: set
set:
	# rm -rf $(BASE_DIR)/prj
	@echo "建立vivado工程"
	$(vivado) -mode batch \
	-source $(TCL_DIR)/setup.tcl \
	-tclargs $(proj_name) $(device) $(usr_ip_repo_paths)
#woleigedou
# 打开波形,-dbdir选项表示导入文件列表
.PHONY: wave
wave:
	cd $(BASE_DIR)/vcs && \
	verdi -ssf *.fsdb -dbdir ./*.daidir

# 开始仿真,
.PHONY: sim
sim:
	@echo "开启动态仿真..."
	cd $(BASE_DIR)/vcs && \
	./$(TOP_SIM).sh	#进入vcs文件夹执行脚本 

# 动态仿真,这类仿真可以实时调试波形，如果要保存波形则选择静态仿真
# 注释simulate.do第2、3行
.PHONY: setsim
setsim:
	# rm -rf $(BASE_DIR)/vcs
	@echo "动态仿真设置..."
	$(vivado) -mode batch -source $(TCL_DIR)/setsim.tcl -tclargs $(proj_name) $(TOP_SIM)
	sed -i '2,3 s/^/#/' vcs/simulate.do

#静态仿真，该种方法需要在tb中写一段命令产生波形文件，gen_filelist是sim的依赖项，即先生成filelist.f文件
.PHONY: setsimg
setsimg: 
	# rm -rf $(BASE_DIR)/vcs
	@echo "静态仿真设置..."
	$(vivado) -mode batch -source $(TCL_DIR)/setsimg.tcl -tclargs $(proj_name) $(TOP_SIM)

###下面为运行相关
##全部运行
#重新建立一个tcl脚本可以避免重新打开工程的时间损耗
.PHONY: run
run: 
	@echo "开始编译和布线..."
	$(vivado) -mode batch -source $(TCL_DIR)/run_all.tcl -tclargs $(proj_name) $(TOP_SRC) $(target_xdc)

##编译运行
.PHONY: syn
syn: 
	@echo "开始编译..."
	$(vivado) -mode batch -source $(TCL_DIR)/run_syn.tcl -tclargs $(proj_name) $(TOP_SRC)
	@echo "编译结束..."

##布线 可以 
.PHONY: lmp
lmp: 
	@echo "开始布局布线..."
	$(vivado) -mode batch -source $(TCL_DIR)/run_lmp.tcl -tclargs $(proj_name) $(target_xdc)
	@echo "布局布线结束..."

.PHONY: gui
gui: 
	@echo "打开GUI..."
	$(vivado) $(BASE_DIR)/prj/*.xpr -mode gui


# 辅助命令：清理生成文件（可选）
.PHONY: clean
clean:
	@echo "Cleaning temporary files..."
	rm -rf *.log *.jou *.str

#清理工程文件
.PHONY: cleanp
cleanp:
	@echo "Cleaning project files..."
	# rm -rf $(BASE_DIR)/prj $(BASE_DIR)/vcs
	rm -rf $(BASE_DIR)/prj

# 帮助信息
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  set     : 创建vivado工程"
	@echo "  gui    : 打开vivado gui"
	@echo "  setsim  : 动态仿真设置"
	@echo "  setsimg : 静态仿真设置"
	@echo "  sim     : 运行仿真"
	@echo "  wave    : 打开波形"
	@echo "  setv    : 创建vitis工程"
	@echo "  guiv    : 打开vitis gui"
	@echo "  cpv     : 备份vitis工程代码"
	@echo "  run     : 全流程运行(syn->lmp 无仿真)"
	@echo "  syn     : 编译工程"
	@echo "  lmp     : 布局布线"
	@echo "  clean   : 清理临时文件"
	@echo "  cleanp  : 清理工程文件"
	@echo "  help    : 显示帮助信息"
