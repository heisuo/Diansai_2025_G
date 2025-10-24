# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "EN_costas" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EN_digital_tx" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Common_i_num" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EN_Search_PP" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EN_AM_mod" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Common_o_num" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EN_digital_rx" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EN_gardner" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EN_bram" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.Common_i_num { PARAM_VALUE.Common_i_num } {
	# Procedure called to update Common_i_num when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Common_i_num { PARAM_VALUE.Common_i_num } {
	# Procedure called to validate Common_i_num
	return true
}

proc update_PARAM_VALUE.Common_o_num { PARAM_VALUE.Common_o_num } {
	# Procedure called to update Common_o_num when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Common_o_num { PARAM_VALUE.Common_o_num } {
	# Procedure called to validate Common_o_num
	return true
}

proc update_PARAM_VALUE.EN_AM_mod { PARAM_VALUE.EN_AM_mod } {
	# Procedure called to update EN_AM_mod when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EN_AM_mod { PARAM_VALUE.EN_AM_mod } {
	# Procedure called to validate EN_AM_mod
	return true
}

proc update_PARAM_VALUE.EN_Search_PP { PARAM_VALUE.EN_Search_PP } {
	# Procedure called to update EN_Search_PP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EN_Search_PP { PARAM_VALUE.EN_Search_PP } {
	# Procedure called to validate EN_Search_PP
	return true
}

proc update_PARAM_VALUE.EN_bram { PARAM_VALUE.EN_bram } {
	# Procedure called to update EN_bram when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EN_bram { PARAM_VALUE.EN_bram } {
	# Procedure called to validate EN_bram
	return true
}

proc update_PARAM_VALUE.EN_costas { PARAM_VALUE.EN_costas } {
	# Procedure called to update EN_costas when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EN_costas { PARAM_VALUE.EN_costas } {
	# Procedure called to validate EN_costas
	return true
}

proc update_PARAM_VALUE.EN_digital_rx { PARAM_VALUE.EN_digital_rx } {
	# Procedure called to update EN_digital_rx when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EN_digital_rx { PARAM_VALUE.EN_digital_rx } {
	# Procedure called to validate EN_digital_rx
	return true
}

proc update_PARAM_VALUE.EN_digital_tx { PARAM_VALUE.EN_digital_tx } {
	# Procedure called to update EN_digital_tx when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EN_digital_tx { PARAM_VALUE.EN_digital_tx } {
	# Procedure called to validate EN_digital_tx
	return true
}

proc update_PARAM_VALUE.EN_gardner { PARAM_VALUE.EN_gardner } {
	# Procedure called to update EN_gardner when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EN_gardner { PARAM_VALUE.EN_gardner } {
	# Procedure called to validate EN_gardner
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to update C_S00_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to validate C_S00_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to update C_S00_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to validate C_S00_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.EN_bram { MODELPARAM_VALUE.EN_bram PARAM_VALUE.EN_bram } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EN_bram}] ${MODELPARAM_VALUE.EN_bram}
}

proc update_MODELPARAM_VALUE.EN_costas { MODELPARAM_VALUE.EN_costas PARAM_VALUE.EN_costas } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EN_costas}] ${MODELPARAM_VALUE.EN_costas}
}

proc update_MODELPARAM_VALUE.EN_gardner { MODELPARAM_VALUE.EN_gardner PARAM_VALUE.EN_gardner } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EN_gardner}] ${MODELPARAM_VALUE.EN_gardner}
}

proc update_MODELPARAM_VALUE.EN_digital_tx { MODELPARAM_VALUE.EN_digital_tx PARAM_VALUE.EN_digital_tx } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EN_digital_tx}] ${MODELPARAM_VALUE.EN_digital_tx}
}

proc update_MODELPARAM_VALUE.EN_digital_rx { MODELPARAM_VALUE.EN_digital_rx PARAM_VALUE.EN_digital_rx } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EN_digital_rx}] ${MODELPARAM_VALUE.EN_digital_rx}
}

proc update_MODELPARAM_VALUE.Common_i_num { MODELPARAM_VALUE.Common_i_num PARAM_VALUE.Common_i_num } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Common_i_num}] ${MODELPARAM_VALUE.Common_i_num}
}

proc update_MODELPARAM_VALUE.Common_o_num { MODELPARAM_VALUE.Common_o_num PARAM_VALUE.Common_o_num } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Common_o_num}] ${MODELPARAM_VALUE.Common_o_num}
}

proc update_MODELPARAM_VALUE.EN_Search_PP { MODELPARAM_VALUE.EN_Search_PP PARAM_VALUE.EN_Search_PP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EN_Search_PP}] ${MODELPARAM_VALUE.EN_Search_PP}
}

proc update_MODELPARAM_VALUE.EN_AM_mod { MODELPARAM_VALUE.EN_AM_mod PARAM_VALUE.EN_AM_mod } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EN_AM_mod}] ${MODELPARAM_VALUE.EN_AM_mod}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

