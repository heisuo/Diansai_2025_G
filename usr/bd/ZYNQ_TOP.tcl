
################################################################
# This is a generated script based on design: ZYNQ_TOP
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source ZYNQ_TOP_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# out_sel, input_sel, jidianqi_ctrl, dac_con

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z100ffg900-2
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name ZYNQ_TOP

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:clk_wiz:6.0\
user.org:user:ila_div_trigger:1.0\
user.org:user:ps_axi_ctrl_new:1.0\
xilinx.com:ip:system_ila:1.1\
user.org:user:DDS:1.0\
user.org:user:FFT_learn:1.0\
user.org:user:adc_sub:1.0\
user.org:user:ADDA_jilin:1.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:fir_compiler:7.2\
user.org:user:jiewei:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
out_sel\
input_sel\
jidianqi_ctrl\
dac_con\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: inter
proc create_hier_cell_inter { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_inter() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir O m_axis_data_tvalid
  create_bd_pin -dir O -from 15 -to 0 o_int_data
  create_bd_pin -dir I s_axis_data_tvalid
  create_bd_pin -dir I -from 15 -to 0 s_axis_data_tdata

  # Create instance: fir_int_5, and set properties
  set fir_int_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_int_5 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {102.4} \
    CONFIG.CoefficientSource {COE_File} \
    CONFIG.Coefficient_File {/home/yian/project/FPGA/diansai/backup/p1_2025_G/fir_lpf_102.4e6_1e6_19.48e6.coe} \
    CONFIG.Coefficient_Fractional_Bits {0} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Non_Symmetric} \
    CONFIG.Coefficient_Width {16} \
    CONFIG.ColumnConfig {6} \
    CONFIG.Data_Width {16} \
    CONFIG.Decimation_Rate {1} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Interpolation} \
    CONFIG.Interpolation_Rate {5} \
    CONFIG.Number_Channels {1} \
    CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
    CONFIG.Output_Width {24} \
    CONFIG.Quantization {Integer_Coefficients} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.Rate_Change_Type {Integer} \
    CONFIG.Sample_Frequency {20.48} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_int_5


  # Create instance: jie_int_5, and set properties
  set jie_int_5 [ create_bd_cell -type ip -vlnv user.org:user:jiewei:1.0 jie_int_5 ]
  set_property -dict [list \
    CONFIG.HSB {22} \
    CONFIG.INPUT_DATA_WIDTH {24} \
  ] $jie_int_5


  # Create instance: jie_int_25_2, and set properties
  set jie_int_25_2 [ create_bd_cell -type ip -vlnv user.org:user:jiewei:1.0 jie_int_25_2 ]
  set_property -dict [list \
    CONFIG.HSB {22} \
    CONFIG.INPUT_DATA_WIDTH {24} \
  ] $jie_int_25_2


  # Create instance: fir_int_25_8, and set properties
  set fir_int_25_8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_int_25_8 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {102.4} \
    CONFIG.CoefficientSource {COE_File} \
    CONFIG.Coefficient_File {/home/yian/project/FPGA/diansai/backup/p1_2025_G/fir_dec_40.96e6_500e3_1138.4e3.coe} \
    CONFIG.Coefficient_Fractional_Bits {0} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Non_Symmetric} \
    CONFIG.Coefficient_Width {16} \
    CONFIG.ColumnConfig {3} \
    CONFIG.Data_Width {16} \
    CONFIG.Decimation_Rate {8} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Interpolation} \
    CONFIG.Interpolation_Rate {25} \
    CONFIG.Number_Channels {1} \
    CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
    CONFIG.Output_Width {24} \
    CONFIG.Quantization {Integer_Coefficients} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.Rate_Change_Type {Fixed_Fractional} \
    CONFIG.Sample_Frequency {6.5536} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_int_25_8


  # Create port connections
  connect_bd_net -net ADDA_ADC_data0  [get_bd_pins s_axis_data_tdata] \
  [get_bd_pins fir_int_25_8/s_axis_data_tdata]
  connect_bd_net -net ADDA_valid  [get_bd_pins s_axis_data_tvalid] \
  [get_bd_pins fir_int_25_8/s_axis_data_tvalid]
  connect_bd_net -net clk_wiz_0_clk_250  [get_bd_pins aclk] \
  [get_bd_pins fir_int_25_8/aclk] \
  [get_bd_pins fir_int_5/aclk]
  connect_bd_net -net fir_dec_25_2_0_m_axis_data_tdata  [get_bd_pins fir_int_5/m_axis_data_tdata] \
  [get_bd_pins jie_int_5/i_data]
  connect_bd_net -net fir_dec_25_2_0_m_axis_data_tvalid  [get_bd_pins fir_int_5/m_axis_data_tvalid] \
  [get_bd_pins m_axis_data_tvalid]
  connect_bd_net -net fir_dec_5_0_m_axis_data_tdata  [get_bd_pins fir_int_25_8/m_axis_data_tdata] \
  [get_bd_pins jie_int_25_2/i_data]
  connect_bd_net -net fir_dec_5_0_m_axis_data_tvalid  [get_bd_pins fir_int_25_8/m_axis_data_tvalid] \
  [get_bd_pins fir_int_5/s_axis_data_tvalid]
  connect_bd_net -net jie_dec_25_2_0_o_jie_data  [get_bd_pins jie_int_5/o_jie_data] \
  [get_bd_pins o_int_data]
  connect_bd_net -net jiewei_0_o_jie_data  [get_bd_pins jie_int_25_2/o_jie_data] \
  [get_bd_pins fir_int_5/s_axis_data_tdata]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dec1
proc create_hier_cell_dec1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_dec1() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir O m_axis_data_tvalid
  create_bd_pin -dir I s_axis_data_tvalid
  create_bd_pin -dir I -from 15 -to 0 s_axis_data_tdata
  create_bd_pin -dir O -from 13 -to 0 o_dec_data

  # Create instance: fir_dec_25_8_0, and set properties
  set fir_dec_25_8_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_dec_25_8_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {102.4} \
    CONFIG.CoefficientSource {COE_File} \
    CONFIG.Coefficient_File {/home/yian/project/FPGA/diansai/backup/p1_2025_G/fir_dec_40.96e6_500e3_1138.4e3.coe} \
    CONFIG.Coefficient_Fractional_Bits {0} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Non_Symmetric} \
    CONFIG.Coefficient_Width {16} \
    CONFIG.ColumnConfig {3} \
    CONFIG.Data_Width {16} \
    CONFIG.Decimation_Rate {25} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Interpolation_Rate {8} \
    CONFIG.Number_Channels {1} \
    CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
    CONFIG.Output_Width {24} \
    CONFIG.Quantization {Integer_Coefficients} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.Rate_Change_Type {Fixed_Fractional} \
    CONFIG.Sample_Frequency {20.48} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_dec_25_8_0


  # Create instance: jie_dec_25_4_0, and set properties
  set jie_dec_25_4_0 [ create_bd_cell -type ip -vlnv user.org:user:jiewei:1.0 jie_dec_25_4_0 ]
  set_property -dict [list \
    CONFIG.HSB {22} \
    CONFIG.INPUT_DATA_WIDTH {24} \
    CONFIG.OUTPUT_DATA_WIDTH {14} \
  ] $jie_dec_25_4_0


  # Create instance: jie_dec_5_0, and set properties
  set jie_dec_5_0 [ create_bd_cell -type ip -vlnv user.org:user:jiewei:1.0 jie_dec_5_0 ]
  set_property -dict [list \
    CONFIG.HSB {22} \
    CONFIG.INPUT_DATA_WIDTH {24} \
  ] $jie_dec_5_0


  # Create instance: fir_dec_5_0, and set properties
  set fir_dec_5_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_dec_5_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {102.4} \
    CONFIG.CoefficientSource {COE_File} \
    CONFIG.Coefficient_File {/home/yian/project/FPGA/diansai/backup/p1_2025_G/fir_lpf_102.4e6_1e6_19.48e6.coe} \
    CONFIG.Coefficient_Fractional_Bits {0} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Non_Symmetric} \
    CONFIG.Coefficient_Width {16} \
    CONFIG.ColumnConfig {6} \
    CONFIG.Data_Width {14} \
    CONFIG.Decimation_Rate {5} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Interpolation_Rate {1} \
    CONFIG.Number_Channels {1} \
    CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
    CONFIG.Output_Width {24} \
    CONFIG.Quantization {Integer_Coefficients} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.Rate_Change_Type {Integer} \
    CONFIG.Sample_Frequency {102.4} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_dec_5_0


  # Create port connections
  connect_bd_net -net ADDA_ADC_data0  [get_bd_pins s_axis_data_tdata] \
  [get_bd_pins fir_dec_5_0/s_axis_data_tdata]
  connect_bd_net -net ADDA_valid  [get_bd_pins s_axis_data_tvalid] \
  [get_bd_pins fir_dec_5_0/s_axis_data_tvalid]
  connect_bd_net -net clk_wiz_0_clk_250  [get_bd_pins aclk] \
  [get_bd_pins fir_dec_5_0/aclk] \
  [get_bd_pins fir_dec_25_8_0/aclk]
  connect_bd_net -net fir_dec_25_2_0_m_axis_data_tdata  [get_bd_pins fir_dec_25_8_0/m_axis_data_tdata] \
  [get_bd_pins jie_dec_25_4_0/i_data]
  connect_bd_net -net fir_dec_25_2_0_m_axis_data_tvalid  [get_bd_pins fir_dec_25_8_0/m_axis_data_tvalid] \
  [get_bd_pins m_axis_data_tvalid]
  connect_bd_net -net fir_dec_5_0_m_axis_data_tdata  [get_bd_pins fir_dec_5_0/m_axis_data_tdata] \
  [get_bd_pins jie_dec_5_0/i_data]
  connect_bd_net -net fir_dec_5_0_m_axis_data_tvalid  [get_bd_pins fir_dec_5_0/m_axis_data_tvalid] \
  [get_bd_pins fir_dec_25_8_0/s_axis_data_tvalid]
  connect_bd_net -net jie_dec_25_2_0_o_jie_data  [get_bd_pins jie_dec_25_4_0/o_jie_data] \
  [get_bd_pins o_dec_data]
  connect_bd_net -net jiewei_0_o_jie_data  [get_bd_pins jie_dec_5_0/o_jie_data] \
  [get_bd_pins fir_dec_25_8_0/s_axis_data_tdata]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dec
proc create_hier_cell_dec { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_dec() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir O m_axis_data_tvalid
  create_bd_pin -dir I s_axis_data_tvalid
  create_bd_pin -dir I -from 15 -to 0 s_axis_data_tdata
  create_bd_pin -dir O -from 13 -to 0 o_dec_data

  # Create instance: fir_dec_25_8_0, and set properties
  set fir_dec_25_8_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_dec_25_8_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {102.4} \
    CONFIG.CoefficientSource {COE_File} \
    CONFIG.Coefficient_File {/home/yian/project/FPGA/diansai/backup/p1_2025_G/fir_dec_40.96e6_500e3_1138.4e3.coe} \
    CONFIG.Coefficient_Fractional_Bits {0} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Non_Symmetric} \
    CONFIG.Coefficient_Width {16} \
    CONFIG.ColumnConfig {3} \
    CONFIG.Data_Width {16} \
    CONFIG.Decimation_Rate {25} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Interpolation_Rate {8} \
    CONFIG.Number_Channels {1} \
    CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
    CONFIG.Output_Width {24} \
    CONFIG.Quantization {Integer_Coefficients} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.Rate_Change_Type {Fixed_Fractional} \
    CONFIG.Sample_Frequency {20.48} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_dec_25_8_0


  # Create instance: jie_dec_25_2_0, and set properties
  set jie_dec_25_2_0 [ create_bd_cell -type ip -vlnv user.org:user:jiewei:1.0 jie_dec_25_2_0 ]
  set_property -dict [list \
    CONFIG.HSB {22} \
    CONFIG.INPUT_DATA_WIDTH {24} \
    CONFIG.OUTPUT_DATA_WIDTH {14} \
  ] $jie_dec_25_2_0


  # Create instance: jie_dec_5_0, and set properties
  set jie_dec_5_0 [ create_bd_cell -type ip -vlnv user.org:user:jiewei:1.0 jie_dec_5_0 ]
  set_property -dict [list \
    CONFIG.HSB {22} \
    CONFIG.INPUT_DATA_WIDTH {24} \
  ] $jie_dec_5_0


  # Create instance: fir_dec_5_0, and set properties
  set fir_dec_5_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_dec_5_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {102.4} \
    CONFIG.CoefficientSource {COE_File} \
    CONFIG.Coefficient_File {/home/yian/project/FPGA/diansai/backup/p1_2025_G/fir_lpf_102.4e6_1e6_19.48e6.coe} \
    CONFIG.Coefficient_Fractional_Bits {0} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Non_Symmetric} \
    CONFIG.Coefficient_Width {16} \
    CONFIG.ColumnConfig {6} \
    CONFIG.Data_Width {14} \
    CONFIG.Decimation_Rate {5} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Interpolation_Rate {1} \
    CONFIG.Number_Channels {1} \
    CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
    CONFIG.Output_Width {24} \
    CONFIG.Quantization {Integer_Coefficients} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.Rate_Change_Type {Integer} \
    CONFIG.Sample_Frequency {102.4} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_dec_5_0


  # Create port connections
  connect_bd_net -net ADDA_ADC_data0  [get_bd_pins s_axis_data_tdata] \
  [get_bd_pins fir_dec_5_0/s_axis_data_tdata]
  connect_bd_net -net ADDA_valid  [get_bd_pins s_axis_data_tvalid] \
  [get_bd_pins fir_dec_5_0/s_axis_data_tvalid]
  connect_bd_net -net clk_wiz_0_clk_250  [get_bd_pins aclk] \
  [get_bd_pins fir_dec_5_0/aclk] \
  [get_bd_pins fir_dec_25_8_0/aclk]
  connect_bd_net -net fir_dec_25_2_0_m_axis_data_tdata  [get_bd_pins fir_dec_25_8_0/m_axis_data_tdata] \
  [get_bd_pins jie_dec_25_2_0/i_data]
  connect_bd_net -net fir_dec_25_2_0_m_axis_data_tvalid  [get_bd_pins fir_dec_25_8_0/m_axis_data_tvalid] \
  [get_bd_pins m_axis_data_tvalid]
  connect_bd_net -net fir_dec_5_0_m_axis_data_tdata  [get_bd_pins fir_dec_5_0/m_axis_data_tdata] \
  [get_bd_pins jie_dec_5_0/i_data]
  connect_bd_net -net fir_dec_5_0_m_axis_data_tvalid  [get_bd_pins fir_dec_5_0/m_axis_data_tvalid] \
  [get_bd_pins fir_dec_25_8_0/s_axis_data_tvalid]
  connect_bd_net -net jie_dec_25_2_0_o_jie_data  [get_bd_pins jie_dec_25_2_0/o_jie_data] \
  [get_bd_pins o_dec_data]
  connect_bd_net -net jiewei_0_o_jie_data  [get_bd_pins jie_dec_5_0/o_jie_data] \
  [get_bd_pins fir_dec_25_8_0/s_axis_data_tdata]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: zynq
proc create_hier_cell_zynq { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_zynq() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir O -from 0 -to 0 -type rst reset
  create_bd_pin -dir O -from 0 -to 0 -type rst aresetn

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [list \
    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {600.000000} \
    CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
    CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {600} \
    CONFIG.PCW_CLK0_FREQ {10000000} \
    CONFIG.PCW_CLK1_FREQ {10000000} \
    CONFIG.PCW_CLK2_FREQ {10000000} \
    CONFIG.PCW_CLK3_FREQ {10000000} \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
    CONFIG.PCW_EN_CLK0_PORT {0} \
    CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} \
    CONFIG.PCW_EN_EMIO_UART0 {0} \
    CONFIG.PCW_EN_EMIO_UART1 {1} \
    CONFIG.PCW_EN_MODEM_UART0 {0} \
    CONFIG.PCW_EN_QSPI {0} \
    CONFIG.PCW_EN_RST0_PORT {1} \
    CONFIG.PCW_EN_SDIO0 {1} \
    CONFIG.PCW_EN_UART0 {1} \
    CONFIG.PCW_EN_UART1 {1} \
    CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_14_PULLUP {enabled} \
    CONFIG.PCW_MIO_14_SLEW {slow} \
    CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_15_PULLUP {enabled} \
    CONFIG.PCW_MIO_15_SLEW {slow} \
    CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_40_PULLUP {enabled} \
    CONFIG.PCW_MIO_40_SLEW {slow} \
    CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_41_PULLUP {enabled} \
    CONFIG.PCW_MIO_41_SLEW {slow} \
    CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_42_PULLUP {enabled} \
    CONFIG.PCW_MIO_42_SLEW {slow} \
    CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_43_PULLUP {enabled} \
    CONFIG.PCW_MIO_43_SLEW {slow} \
    CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_44_PULLUP {enabled} \
    CONFIG.PCW_MIO_44_SLEW {slow} \
    CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_45_PULLUP {enabled} \
    CONFIG.PCW_MIO_45_SLEW {slow} \
    CONFIG.PCW_MIO_TREE_PERIPHERALS {unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#UART 0#UART\
0#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#SD\
0#SD 0#SD 0#SD 0#SD 0#SD 0#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned} \
    CONFIG.PCW_MIO_TREE_SIGNALS {unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#rx#tx#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#clk#cmd#data[0]#data[1]#data[2]#data[3]#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned}\
\
    CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
    CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_CD_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
    CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
    CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
    CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_UART1_IO {EMIO} \
    CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
    CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
  ] $processing_system7_0


  # Create instance: rst_ADDA_jilin_0_100M, and set properties
  set rst_ADDA_jilin_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ADDA_jilin_0_100M ]

  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property CONFIG.NUM_SI {1} $axi_smc


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_pins DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_pins FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins axi_smc/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_UART_1 [get_bd_intf_pins UART_1] [get_bd_intf_pins processing_system7_0/UART_1]

  # Create port connections
  connect_bd_net -net clk_wiz_0_clk_250  [get_bd_pins aclk] \
  [get_bd_pins rst_ADDA_jilin_0_100M/slowest_sync_clk] \
  [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] \
  [get_bd_pins axi_smc/aclk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N  [get_bd_pins processing_system7_0/FCLK_RESET0_N] \
  [get_bd_pins rst_ADDA_jilin_0_100M/ext_reset_in]
  connect_bd_net -net rst_ADDA_jilin_0_100M_peripheral_aresetn  [get_bd_pins rst_ADDA_jilin_0_100M/peripheral_aresetn] \
  [get_bd_pins aresetn] \
  [get_bd_pins axi_smc/aresetn]
  connect_bd_net -net rst_ADDA_jilin_0_100M_peripheral_reset  [get_bd_pins rst_ADDA_jilin_0_100M/peripheral_reset] \
  [get_bd_pins reset]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: ADDA
proc create_hier_cell_ADDA { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_ADDA() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 adc_in

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:diff_clock_rtl:1.0 dac_dci

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 dac_out

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 adc_dco


  # Create pins
  create_bd_pin -dir O valid
  create_bd_pin -dir I clk_spi_50M
  create_bd_pin -dir I locked
  create_bd_pin -dir O -type clk o_sys_clk
  create_bd_pin -dir O fmc_spi_sclk
  create_bd_pin -dir IO fmc_spi_sdio
  create_bd_pin -dir O fmc_clk_cs
  create_bd_pin -dir O fmc_adc_cs
  create_bd_pin -dir O fmc_dac_cs
  create_bd_pin -dir I -from 15 -to 0 i_dac_data1
  create_bd_pin -dir I -from 15 -to 0 i_dac_data2
  create_bd_pin -dir O power_en
  create_bd_pin -dir O -from 15 -to 0 ADC_data0
  create_bd_pin -dir O -from 15 -to 0 ADC_data1

  # Create instance: dac_con_0, and set properties
  set block_name dac_con
  set block_cell_name dac_con_0
  if { [catch {set dac_con_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dac_con_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: adc_sub_0, and set properties
  set adc_sub_0 [ create_bd_cell -type ip -vlnv user.org:user:adc_sub:1.0 adc_sub_0 ]

  # Create instance: ADDA_jilin_0, and set properties
  set ADDA_jilin_0 [ create_bd_cell -type ip -vlnv user.org:user:ADDA_jilin:1.0 ADDA_jilin_0 ]
  set_property CONFIG.ADC_DCO_DELAY {15} $ADDA_jilin_0


  # Create interface connections
  connect_bd_intf_net -intf_net ADDA_jilin_0_dac_dci [get_bd_intf_pins dac_dci] [get_bd_intf_pins ADDA_jilin_0/dac_dci]
  connect_bd_intf_net -intf_net ADDA_jilin_0_dac_out [get_bd_intf_pins dac_out] [get_bd_intf_pins ADDA_jilin_0/dac_out]
  connect_bd_intf_net -intf_net adc_dco_1 [get_bd_intf_pins adc_dco] [get_bd_intf_pins ADDA_jilin_0/adc_dco]
  connect_bd_intf_net -intf_net adc_in_1 [get_bd_intf_pins adc_in] [get_bd_intf_pins ADDA_jilin_0/adc_in]

  # Create port connections
  connect_bd_net -net ADDA_jilin_0_fmc_adc_cs  [get_bd_pins ADDA_jilin_0/fmc_adc_cs] \
  [get_bd_pins fmc_adc_cs]
  connect_bd_net -net ADDA_jilin_0_fmc_clk_cs  [get_bd_pins ADDA_jilin_0/fmc_clk_cs] \
  [get_bd_pins fmc_clk_cs]
  connect_bd_net -net ADDA_jilin_0_fmc_dac_cs  [get_bd_pins ADDA_jilin_0/fmc_dac_cs] \
  [get_bd_pins fmc_dac_cs]
  connect_bd_net -net ADDA_jilin_0_fmc_spi_sclk  [get_bd_pins ADDA_jilin_0/fmc_spi_sclk] \
  [get_bd_pins fmc_spi_sclk]
  connect_bd_net -net ADDA_jilin_0_o_adc_data  [get_bd_pins ADDA_jilin_0/o_adc_data] \
  [get_bd_pins adc_sub_0/ADC_data]
  connect_bd_net -net ADDA_jilin_0_o_sys_clk  [get_bd_pins ADDA_jilin_0/o_sys_clk] \
  [get_bd_pins o_sys_clk]
  connect_bd_net -net ADDA_jilin_0_power_en  [get_bd_pins ADDA_jilin_0/power_en] \
  [get_bd_pins power_en]
  connect_bd_net -net Net  [get_bd_pins fmc_spi_sdio] \
  [get_bd_pins ADDA_jilin_0/fmc_spi_sdio]
  connect_bd_net -net adc_sub_0_ADC_data0  [get_bd_pins adc_sub_0/ADC_data0] \
  [get_bd_pins ADC_data0]
  connect_bd_net -net adc_sub_0_ADC_data1  [get_bd_pins adc_sub_0/ADC_data1] \
  [get_bd_pins ADC_data1]
  connect_bd_net -net adc_sub_0_valid  [get_bd_pins adc_sub_0/valid] \
  [get_bd_pins valid]
  connect_bd_net -net clk_spi_50M_1  [get_bd_pins clk_spi_50M] \
  [get_bd_pins ADDA_jilin_0/clk_spi_50M]
  connect_bd_net -net dac_con_0_o_dac_data  [get_bd_pins dac_con_0/o_dac_data] \
  [get_bd_pins ADDA_jilin_0/i_dac_data]
  connect_bd_net -net i_dac_data1_1  [get_bd_pins i_dac_data1] \
  [get_bd_pins dac_con_0/i_dac_data1]
  connect_bd_net -net i_dac_data2_1  [get_bd_pins i_dac_data2] \
  [get_bd_pins dac_con_0/i_dac_data2]
  connect_bd_net -net locked_1  [get_bd_pins locked] \
  [get_bd_pins ADDA_jilin_0/locked]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  set adc_dco [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 adc_dco ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $adc_dco

  set adc_in [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 adc_in ]

  set dac_dci [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_clock_rtl:1.0 dac_dci ]

  set dac_out [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 dac_out ]

  set UART_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_1 ]


  # Create ports
  set fmc_adc_cs [ create_bd_port -dir O fmc_adc_cs ]
  set fmc_clk_cs [ create_bd_port -dir O fmc_clk_cs ]
  set fmc_dac_cs [ create_bd_port -dir O fmc_dac_cs ]
  set fmc_spi_sclk [ create_bd_port -dir O fmc_spi_sclk ]
  set fmc_spi_sdio [ create_bd_port -dir IO fmc_spi_sdio ]
  set input_clk_50M [ create_bd_port -dir I -type clk -freq_hz 50000000 input_clk_50M ]
  set o_jidianqi [ create_bd_port -dir O o_jidianqi ]
  set power_en [ create_bd_port -dir O power_en ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLKIN1_JITTER_PS {200.0} \
    CONFIG.CLKOUT1_JITTER {192.113} \
    CONFIG.CLKOUT1_PHASE_ERROR {164.985} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50} \
    CONFIG.CLKOUT2_JITTER {131.873} \
    CONFIG.CLKOUT2_PHASE_ERROR {97.786} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT2_USED {false} \
    CONFIG.CLKOUT3_JITTER {114.829} \
    CONFIG.CLKOUT3_PHASE_ERROR {98.575} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT3_USED {false} \
    CONFIG.CLK_OUT1_PORT {clk_50} \
    CONFIG.CLK_OUT2_PORT {clk_out2} \
    CONFIG.CLK_OUT3_PORT {clk_out3} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {20.000} \
    CONFIG.MMCM_CLKIN1_PERIOD {20.000} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {20.000} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT2_DIVIDE {1} \
    CONFIG.MMCM_DIVCLK_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {1} \
    CONFIG.PRIM_IN_FREQ {50} \
    CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {false} \
  ] $clk_wiz_0


  # Create instance: ADDA
  create_hier_cell_ADDA [current_bd_instance .] ADDA

  # Create instance: zynq
  create_hier_cell_zynq [current_bd_instance .] zynq

  # Create instance: ila_div_trigger_0, and set properties
  set ila_div_trigger_0 [ create_bd_cell -type ip -vlnv user.org:user:ila_div_trigger:1.0 ila_div_trigger_0 ]

  # Create instance: ps_axi_ctrl_new_0, and set properties
  set ps_axi_ctrl_new_0 [ create_bd_cell -type ip -vlnv user.org:user:ps_axi_ctrl_new:1.0 ps_axi_ctrl_new_0 ]
  set_property -dict [list \
    CONFIG.EN_AM_mod {false} \
    CONFIG.EN_Search_PP {false} \
    CONFIG.EN_bram {false} \
    CONFIG.EN_costas {false} \
    CONFIG.EN_digital_rx {false} \
    CONFIG.EN_digital_tx {false} \
    CONFIG.EN_gardner {false} \
  ] $ps_axi_ctrl_new_0


  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [list \
    CONFIG.C_DATA_DEPTH {4096} \
    CONFIG.C_EN_STRG_QUAL {1} \
    CONFIG.C_MON_TYPE {NATIVE} \
    CONFIG.C_NUM_OF_PROBES {44} \
    CONFIG.C_PROBE0_TYPE {0} \
    CONFIG.C_PROBE10_TYPE {0} \
    CONFIG.C_PROBE11_TYPE {0} \
    CONFIG.C_PROBE12_TYPE {0} \
    CONFIG.C_PROBE13_TYPE {0} \
    CONFIG.C_PROBE14_TYPE {0} \
    CONFIG.C_PROBE15_TYPE {0} \
    CONFIG.C_PROBE16_TYPE {0} \
    CONFIG.C_PROBE17_TYPE {0} \
    CONFIG.C_PROBE18_TYPE {0} \
    CONFIG.C_PROBE19_TYPE {0} \
    CONFIG.C_PROBE1_TYPE {0} \
    CONFIG.C_PROBE20_TYPE {0} \
    CONFIG.C_PROBE21_TYPE {0} \
    CONFIG.C_PROBE22_TYPE {0} \
    CONFIG.C_PROBE23_TYPE {0} \
    CONFIG.C_PROBE24_TYPE {0} \
    CONFIG.C_PROBE25_TYPE {0} \
    CONFIG.C_PROBE26_TYPE {0} \
    CONFIG.C_PROBE27_TYPE {0} \
    CONFIG.C_PROBE28_TYPE {0} \
    CONFIG.C_PROBE29_TYPE {0} \
    CONFIG.C_PROBE2_TYPE {0} \
    CONFIG.C_PROBE30_TYPE {0} \
    CONFIG.C_PROBE31_TYPE {0} \
    CONFIG.C_PROBE32_TYPE {0} \
    CONFIG.C_PROBE33_TYPE {0} \
    CONFIG.C_PROBE34_TYPE {0} \
    CONFIG.C_PROBE35_TYPE {0} \
    CONFIG.C_PROBE36_TYPE {0} \
    CONFIG.C_PROBE37_TYPE {0} \
    CONFIG.C_PROBE38_TYPE {0} \
    CONFIG.C_PROBE39_TYPE {0} \
    CONFIG.C_PROBE3_TYPE {0} \
    CONFIG.C_PROBE40_TYPE {0} \
    CONFIG.C_PROBE41_TYPE {0} \
    CONFIG.C_PROBE42_TYPE {0} \
    CONFIG.C_PROBE43_TYPE {0} \
    CONFIG.C_PROBE4_TYPE {0} \
    CONFIG.C_PROBE5_TYPE {0} \
    CONFIG.C_PROBE6_TYPE {0} \
    CONFIG.C_PROBE7_TYPE {0} \
    CONFIG.C_PROBE8_TYPE {0} \
    CONFIG.C_PROBE9_TYPE {0} \
  ] $system_ila_0


  # Create instance: DDS_0, and set properties
  set DDS_0 [ create_bd_cell -type ip -vlnv user.org:user:DDS:1.0 DDS_0 ]

  # Create instance: FFT_learn_0, and set properties
  set FFT_learn_0 [ create_bd_cell -type ip -vlnv user.org:user:FFT_learn:1.0 FFT_learn_0 ]
  set_property -dict [list \
    CONFIG.FFT_OUT_WIDTH {30} \
    CONFIG.FFT_POINT {32768} \
    CONFIG.Fiter_jie {0} \
    CONFIG.IFFT_OUT_WIDTH {32} \
  ] $FFT_learn_0


  # Create instance: out_sel_0, and set properties
  set block_name out_sel
  set block_cell_name out_sel_0
  if { [catch {set out_sel_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $out_sel_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: dec
  create_hier_cell_dec [current_bd_instance .] dec

  # Create instance: dec1
  create_hier_cell_dec1 [current_bd_instance .] dec1

  # Create instance: inter
  create_hier_cell_inter [current_bd_instance .] inter

  # Create instance: input_sel_0, and set properties
  set block_name input_sel
  set block_cell_name input_sel_0
  if { [catch {set input_sel_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $input_sel_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: jidianqi_ctrl_0, and set properties
  set block_name jidianqi_ctrl
  set block_cell_name jidianqi_ctrl_0
  if { [catch {set jidianqi_ctrl_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $jidianqi_ctrl_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net ADDA_jilin_0_dac_dci [get_bd_intf_pins ADDA/dac_dci] [get_bd_intf_ports dac_dci]
  connect_bd_intf_net -intf_net ADDA_jilin_0_dac_out [get_bd_intf_pins ADDA/dac_out] [get_bd_intf_ports dac_out]
  connect_bd_intf_net -intf_net adc_dco_1 [get_bd_intf_ports adc_dco] [get_bd_intf_pins ADDA/adc_dco]
  connect_bd_intf_net -intf_net adc_in_1 [get_bd_intf_pins ADDA/adc_in] [get_bd_intf_ports adc_in]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins zynq/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins zynq/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_UART_1 [get_bd_intf_pins zynq/UART_1] [get_bd_intf_ports UART_1]
  connect_bd_intf_net -intf_net zynq_M01_AXI [get_bd_intf_pins zynq/M00_AXI] [get_bd_intf_pins ps_axi_ctrl_new_0/S00_AXI]

  # Create port connections
  connect_bd_net -net ADDA_ADC_data0  [get_bd_pins ADDA/ADC_data0] \
  [get_bd_pins input_sel_0/i_adc_1] \
  [get_bd_pins system_ila_0/probe37]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ADDA_ADC_data0]
  connect_bd_net -net ADDA_jilin_0_fmc_adc_cs  [get_bd_pins ADDA/fmc_adc_cs] \
  [get_bd_ports fmc_adc_cs]
  connect_bd_net -net ADDA_jilin_0_fmc_clk_cs  [get_bd_pins ADDA/fmc_clk_cs] \
  [get_bd_ports fmc_clk_cs]
  connect_bd_net -net ADDA_jilin_0_fmc_dac_cs  [get_bd_pins ADDA/fmc_dac_cs] \
  [get_bd_ports fmc_dac_cs]
  connect_bd_net -net ADDA_jilin_0_fmc_spi_sclk  [get_bd_pins ADDA/fmc_spi_sclk] \
  [get_bd_ports fmc_spi_sclk]
  connect_bd_net -net ADDA_power_en  [get_bd_pins ADDA/power_en] \
  [get_bd_ports power_en]
  connect_bd_net -net ADDA_valid  [get_bd_pins ADDA/valid] \
  [get_bd_pins dec/s_axis_data_tvalid] \
  [get_bd_pins dec1/s_axis_data_tvalid]
  connect_bd_net -net DDS_0_o_DDS_cos  [get_bd_pins DDS_0/o_DDS_cos] \
  [get_bd_pins out_sel_0/i_DDS]
  connect_bd_net -net DDS_0_o_DDS_sin  [get_bd_pins DDS_0/o_DDS_sin] \
  [get_bd_pins ADDA/i_dac_data2]
  connect_bd_net -net FFT_Filter_I_data  [get_bd_pins FFT_learn_0/FFT_Filter_I_data] \
  [get_bd_pins system_ila_0/probe21]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets FFT_Filter_I_data]
  connect_bd_net -net FFT_Filter_Q_data  [get_bd_pins FFT_learn_0/FFT_Filter_Q_data] \
  [get_bd_pins system_ila_0/probe22]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets FFT_Filter_Q_data]
  connect_bd_net -net FFT_learn_0_o_FFT1_I  [get_bd_pins FFT_learn_0/o_FFT1_I] \
  [get_bd_pins ps_axi_ctrl_new_0/i_FFT1_I] \
  [get_bd_pins system_ila_0/probe1]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets FFT_learn_0_o_FFT1_I]
  connect_bd_net -net FFT_learn_0_o_FFT1_Q  [get_bd_pins FFT_learn_0/o_FFT1_Q] \
  [get_bd_pins ps_axi_ctrl_new_0/i_FFT1_Q] \
  [get_bd_pins system_ila_0/probe2]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets FFT_learn_0_o_FFT1_Q]
  connect_bd_net -net FFT_learn_0_o_FFT2_I  [get_bd_pins FFT_learn_0/o_FFT2_I] \
  [get_bd_pins ps_axi_ctrl_new_0/i_FFT2_I] \
  [get_bd_pins system_ila_0/probe3]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets FFT_learn_0_o_FFT2_I]
  connect_bd_net -net FFT_learn_0_o_FFT2_Q  [get_bd_pins FFT_learn_0/o_FFT2_Q] \
  [get_bd_pins ps_axi_ctrl_new_0/i_FFT2_Q] \
  [get_bd_pins system_ila_0/probe4]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets FFT_learn_0_o_FFT2_Q]
  connect_bd_net -net FFT_learn_0_o_FFT_end_pulse  [get_bd_pins FFT_learn_0/o_FFT_end_pulse] \
  [get_bd_pins ps_axi_ctrl_new_0/i_FFT_end_pulse] \
  [get_bd_pins system_ila_0/probe5]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets FFT_learn_0_o_FFT_end_pulse]
  connect_bd_net -net FFT_zoom  [get_bd_pins FFT_learn_0/FFT_zoom] \
  [get_bd_pins system_ila_0/probe23]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets FFT_zoom]
  connect_bd_net -net IFFT_m_data_R  [get_bd_pins FFT_learn_0/IFFT_m_data_R] \
  [get_bd_pins system_ila_0/probe24]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets IFFT_m_data_R]
  connect_bd_net -net Net  [get_bd_ports fmc_spi_sdio] \
  [get_bd_pins ADDA/fmc_spi_sdio]
  connect_bd_net -net clk_in1_1  [get_bd_ports input_clk_50M] \
  [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net clk_wiz_0_clk_50  [get_bd_pins clk_wiz_0/clk_50] \
  [get_bd_pins ADDA/clk_spi_50M]
  connect_bd_net -net clk_wiz_0_clk_250  [get_bd_pins ADDA/o_sys_clk] \
  [get_bd_pins zynq/aclk] \
  [get_bd_pins ila_div_trigger_0/clk] \
  [get_bd_pins system_ila_0/clk] \
  [get_bd_pins DDS_0/clk] \
  [get_bd_pins ps_axi_ctrl_new_0/s00_axi_aclk] \
  [get_bd_pins dec/aclk] \
  [get_bd_pins dec1/aclk] \
  [get_bd_pins inter/aclk] \
  [get_bd_pins out_sel_0/clk] \
  [get_bd_pins input_sel_0/clk] \
  [get_bd_pins jidianqi_ctrl_0/clk] \
  [get_bd_pins FFT_learn_0/clk]
  connect_bd_net -net clk_wiz_0_locked  [get_bd_pins clk_wiz_0/locked] \
  [get_bd_pins ADDA/locked]
  connect_bd_net -net debug_FFT_flow_I  [get_bd_pins FFT_learn_0/debug_FFT_flow_I] \
  [get_bd_pins system_ila_0/probe42]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets debug_FFT_flow_I]
  connect_bd_net -net debug_FFT_flow_Q  [get_bd_pins FFT_learn_0/debug_FFT_flow_Q] \
  [get_bd_pins system_ila_0/probe43]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets debug_FFT_flow_Q]
  connect_bd_net -net dec1_m_axis_data_tvalid  [get_bd_pins dec1/m_axis_data_tvalid] \
  [get_bd_pins system_ila_0/probe16] \
  [get_bd_pins FFT_learn_0/i_valid2]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets dec1_m_axis_data_tvalid]
  connect_bd_net -net dec1_o_jie_data  [get_bd_pins dec1/o_dec_data] \
  [get_bd_pins FFT_learn_0/i_data2]
  connect_bd_net -net fir_dec_25_2_0_m_axis_data_tvalid  [get_bd_pins dec/m_axis_data_tvalid] \
  [get_bd_pins system_ila_0/probe17] \
  [get_bd_pins FFT_learn_0/i_valid1]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets fir_dec_25_2_0_m_axis_data_tvalid]
  connect_bd_net -net input_sel_0_o_adc_1  [get_bd_pins input_sel_0/o_adc_1] \
  [get_bd_pins dec/s_axis_data_tdata] \
  [get_bd_pins system_ila_0/probe40]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets input_sel_0_o_adc_1]
  connect_bd_net -net input_sel_0_o_adc_2  [get_bd_pins input_sel_0/o_adc_2] \
  [get_bd_pins dec1/s_axis_data_tdata] \
  [get_bd_pins system_ila_0/probe41]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets input_sel_0_o_adc_2]
  connect_bd_net -net inter_o_jie_data  [get_bd_pins inter/o_int_data] \
  [get_bd_pins out_sel_0/i_IFFT_data] \
  [get_bd_pins system_ila_0/probe18]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets inter_o_jie_data]
  connect_bd_net -net jidianqi_ctrl_0_o_jidianqi  [get_bd_pins jidianqi_ctrl_0/o_jidianqi] \
  [get_bd_ports o_jidianqi]
  connect_bd_net -net jie_dec_25_2_0_o_jie_data  [get_bd_pins dec/o_dec_data] \
  [get_bd_pins FFT_learn_0/i_data1]
  connect_bd_net -net out_sel_0_o_dac_data  [get_bd_pins out_sel_0/o_dac_data] \
  [get_bd_pins ADDA/i_dac_data1] \
  [get_bd_pins system_ila_0/probe36]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets out_sel_0_o_dac_data]
  connect_bd_net -net phase_cos  [get_bd_pins FFT_learn_0/phase_cos] \
  [get_bd_pins system_ila_0/probe25]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets phase_cos]
  connect_bd_net -net phase_sin  [get_bd_pins FFT_learn_0/phase_sin] \
  [get_bd_pins system_ila_0/probe26]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets phase_sin]
  connect_bd_net -net ps_axi_ctrl_new_0_o_DDS_FTW  [get_bd_pins ps_axi_ctrl_new_0/o_DDS_FTW] \
  [get_bd_pins DDS_0/i_DDS_FTW] \
  [get_bd_pins system_ila_0/probe6]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_DDS_FTW]
  connect_bd_net -net ps_axi_ctrl_new_0_o_FFT_index  [get_bd_pins ps_axi_ctrl_new_0/o_FFT_index] \
  [get_bd_pins system_ila_0/probe7] \
  [get_bd_pins FFT_learn_0/i_FFT_index]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_FFT_index]
  connect_bd_net -net ps_axi_ctrl_new_0_o_FFT_phase_cos  [get_bd_pins ps_axi_ctrl_new_0/o_FFT_phase_cos] \
  [get_bd_pins system_ila_0/probe8] \
  [get_bd_pins FFT_learn_0/i_FFT_phase_cos]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_FFT_phase_cos]
  connect_bd_net -net ps_axi_ctrl_new_0_o_FFT_phase_sin  [get_bd_pins ps_axi_ctrl_new_0/o_FFT_phase_sin] \
  [get_bd_pins system_ila_0/probe9] \
  [get_bd_pins FFT_learn_0/i_FFT_phase_sin]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_FFT_phase_sin]
  connect_bd_net -net ps_axi_ctrl_new_0_o_FFT_ram_wea  [get_bd_pins ps_axi_ctrl_new_0/o_FFT_ram_wea] \
  [get_bd_pins system_ila_0/probe10] \
  [get_bd_pins FFT_learn_0/i_FFT_ram_wea]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_FFT_ram_wea]
  connect_bd_net -net ps_axi_ctrl_new_0_o_FFT_wr_addr  [get_bd_pins ps_axi_ctrl_new_0/o_FFT_wr_addr] \
  [get_bd_pins system_ila_0/probe11] \
  [get_bd_pins FFT_learn_0/i_FFT_wr_addr]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_FFT_wr_addr]
  connect_bd_net -net ps_axi_ctrl_new_0_o_FFT_zoom_data  [get_bd_pins ps_axi_ctrl_new_0/o_FFT_zoom_data] \
  [get_bd_pins system_ila_0/probe12] \
  [get_bd_pins FFT_learn_0/i_FFT_zoom_data]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_FFT_zoom_data]
  connect_bd_net -net ps_axi_ctrl_new_0_o_mode  [get_bd_pins ps_axi_ctrl_new_0/o_mode] \
  [get_bd_pins system_ila_0/probe13] \
  [get_bd_pins out_sel_0/i_mode] \
  [get_bd_pins input_sel_0/i_mode] \
  [get_bd_pins jidianqi_ctrl_0/i_mode] \
  [get_bd_pins FFT_learn_0/i_mode]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_mode]
  connect_bd_net -net ps_axi_ctrl_new_0_o_start_FFT_pulse  [get_bd_pins ps_axi_ctrl_new_0/o_start_FFT_pulse] \
  [get_bd_pins system_ila_0/probe14] \
  [get_bd_pins FFT_learn_0/i_start_FFT_pulse]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_start_FFT_pulse]
  connect_bd_net -net ps_axi_ctrl_new_0_o_zoom_factor  [get_bd_pins ps_axi_ctrl_new_0/o_zoom_factor] \
  [get_bd_pins system_ila_0/probe15] \
  [get_bd_pins out_sel_0/i_out_zoom]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets ps_axi_ctrl_new_0_o_zoom_factor]
  connect_bd_net -net r_dac_data  [get_bd_pins out_sel_0/r_dac_data] \
  [get_bd_pins system_ila_0/probe39]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets r_dac_data]
  connect_bd_net -net rotate_I  [get_bd_pins FFT_learn_0/rotate_I] \
  [get_bd_pins system_ila_0/probe27]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets rotate_I]
  connect_bd_net -net rotate_Q  [get_bd_pins FFT_learn_0/rotate_Q] \
  [get_bd_pins system_ila_0/probe28]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets rotate_Q]
  connect_bd_net -net rst_ADDA_jilin_0_100M_peripheral_aresetn  [get_bd_pins zynq/aresetn] \
  [get_bd_pins ps_axi_ctrl_new_0/s00_axi_aresetn]
  connect_bd_net -net rst_ADDA_jilin_0_100M_peripheral_reset  [get_bd_pins zynq/reset] \
  [get_bd_pins DDS_0/rst] \
  [get_bd_pins FFT_learn_0/rst]
  connect_bd_net -net s_axis_data_tdata_1  [get_bd_pins ADDA/ADC_data1] \
  [get_bd_pins input_sel_0/i_adc_2] \
  [get_bd_pins system_ila_0/probe38]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets s_axis_data_tdata_1]
  connect_bd_net -net s_axis_data_tdata_2  [get_bd_pins FFT_learn_0/o_data] \
  [get_bd_pins inter/s_axis_data_tdata] \
  [get_bd_pins system_ila_0/probe19]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets s_axis_data_tdata_2]
  connect_bd_net -net s_axis_data_tvalid_1  [get_bd_pins FFT_learn_0/o_valid] \
  [get_bd_pins inter/s_axis_data_tvalid] \
  [get_bd_pins system_ila_0/probe20]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets s_axis_data_tvalid_1]
  connect_bd_net -net trigger  [get_bd_pins ila_div_trigger_0/trigger] \
  [get_bd_pins system_ila_0/probe0]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets trigger]
  connect_bd_net -net w_FFT_Filter_last  [get_bd_pins FFT_learn_0/w_FFT_Filter_last] \
  [get_bd_pins system_ila_0/probe29]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets w_FFT_Filter_last]
  connect_bd_net -net w_FFT_Filter_valid  [get_bd_pins FFT_learn_0/w_FFT_Filter_valid] \
  [get_bd_pins system_ila_0/probe30]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets w_FFT_Filter_valid]
  connect_bd_net -net w_IFFT_m_valid  [get_bd_pins FFT_learn_0/w_IFFT_m_valid] \
  [get_bd_pins system_ila_0/probe33]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets w_IFFT_m_valid]
  connect_bd_net -net w_flow_FFT_last  [get_bd_pins FFT_learn_0/w_flow_FFT_last] \
  [get_bd_pins system_ila_0/probe31]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets w_flow_FFT_last]
  connect_bd_net -net w_flow_FFT_valid  [get_bd_pins FFT_learn_0/w_flow_FFT_valid] \
  [get_bd_pins system_ila_0/probe32]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets w_flow_FFT_valid]
  connect_bd_net -net zoom_I  [get_bd_pins FFT_learn_0/zoom_I] \
  [get_bd_pins system_ila_0/probe34]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets zoom_I]
  connect_bd_net -net zoom_Q  [get_bd_pins FFT_learn_0/zoom_Q] \
  [get_bd_pins system_ila_0/probe35]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets zoom_Q]

  # Create address segments
  assign_bd_address -offset 0x43C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq/processing_system7_0/Data] [get_bd_addr_segs ps_axi_ctrl_new_0/S00_AXI/S00_AXI_reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


