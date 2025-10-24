# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/include/diskio.h"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/include/ff.h"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/include/ffconf.h"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/include/sleep.h"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/include/xilffs.h"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/include/xilffs_config.h"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/include/xilrsa.h"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/include/xiltimer.h"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/include/xtimer_config.h"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/lib/libxilffs.a"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/lib/libxilrsa.a"
  "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp/lib/libxiltimer.a"
  )
endif()
