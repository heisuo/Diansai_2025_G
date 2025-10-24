#line 2 "lop-config.dts"
/dts-v1/;
/ {
        compatible = "system-device-tree-v1,lop";
        lops {
                lop_0 {
                        compatible = "system-device-tree-v1,lop,load";
                        load = "assists/baremetal_validate_comp_xlnx.py";
                };

                lop_1 {
                    compatible = "system-device-tree-v1,lop,assist-v1";
                    node = "/";
                    outdir = "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp";
                    id = "module,baremetal_validate_comp_xlnx";
                    options = "ps7_cortexa9_0 /tools/Xilinx/Vitis/2024.2/data/embeddedsw/lib/sw_services/xilffs_v5_3/src /home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/_ide/.wsdata/.repo.yaml";
                };

                lop_2 {
                    compatible = "system-device-tree-v1,lop,assist-v1";
                    node = "/";
                    outdir = "/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/platform0/zynq_fsbl/zynq_fsbl_bsp";
                    id = "module,baremetal_validate_comp_xlnx";
                    options = "ps7_cortexa9_0 /tools/Xilinx/Vitis/2024.2/data/embeddedsw/lib/sw_services/xilrsa_v1_8/src /home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/_ide/.wsdata/.repo.yaml";
                };

        };
    };
