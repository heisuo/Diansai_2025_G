# 2025-09-04T06:54:45.726917
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.create_platform_component(name = "platform0",hw_design = "$COMPONENT_LOCATION/../../xsa/ZYNQ_TOP_wrapper2.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",generate_dtb = True)

platform = client.get_component(name="platform0")
domain = platform.get_domain(name="standalone_ps7_cortexa9_0")

domain = platform.get_domain(name="standalone_ps7_cortexa9_0")

status = domain.set_lib(lib_name="xilffs", path="/tools/Xilinx/Vitis/2024.2/data/embeddedsw/lib/sw_services/xilffs_v5_3")

status = domain.set_lib(lib_name="xilrsa", path="/tools/Xilinx/Vitis/2024.2/data/embeddedsw/lib/sw_services/xilrsa_v1_8")

status = platform.build()

comp = client.create_app_component(name="FFT_test",platform = "$COMPONENT_LOCATION/../platform0/export/platform0/platform0.xpfm",domain = "standalone_a9_0",template = "empty_application")

comp = client.get_component(name="FFT_test")
status = comp.import_files(from_loc="$COMPONENT_LOCATION/../../usr", files=["src_vitis"], dest_dir_in_cmp = "src")

component = client.get_component(name="FFT_test")

lscript = component.get_ld_script(path="/home/yian/project/FPGA/diansai/backup/p1_2025_G_fx/vitis/FFT_test/src/lscript.ld")

lscript.set_stack_size("0x800000")

lscript.set_heap_size("0x800000")

comp.build()

vitis.dispose()

