# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "FFT_POINT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FFT_OUT_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IFFT_OUT_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Fiter_jie" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT_jie" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADDR_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.FFT_OUT_WIDTH { PARAM_VALUE.FFT_OUT_WIDTH } {
	# Procedure called to update FFT_OUT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FFT_OUT_WIDTH { PARAM_VALUE.FFT_OUT_WIDTH } {
	# Procedure called to validate FFT_OUT_WIDTH
	return true
}

proc update_PARAM_VALUE.FFT_POINT { PARAM_VALUE.FFT_POINT } {
	# Procedure called to update FFT_POINT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FFT_POINT { PARAM_VALUE.FFT_POINT } {
	# Procedure called to validate FFT_POINT
	return true
}

proc update_PARAM_VALUE.Fiter_jie { PARAM_VALUE.Fiter_jie } {
	# Procedure called to update Fiter_jie when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Fiter_jie { PARAM_VALUE.Fiter_jie } {
	# Procedure called to validate Fiter_jie
	return true
}

proc update_PARAM_VALUE.IFFT_OUT_WIDTH { PARAM_VALUE.IFFT_OUT_WIDTH } {
	# Procedure called to update IFFT_OUT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IFFT_OUT_WIDTH { PARAM_VALUE.IFFT_OUT_WIDTH } {
	# Procedure called to validate IFFT_OUT_WIDTH
	return true
}

proc update_PARAM_VALUE.OUT_jie { PARAM_VALUE.OUT_jie } {
	# Procedure called to update OUT_jie when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT_jie { PARAM_VALUE.OUT_jie } {
	# Procedure called to validate OUT_jie
	return true
}


proc update_MODELPARAM_VALUE.FFT_POINT { MODELPARAM_VALUE.FFT_POINT PARAM_VALUE.FFT_POINT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FFT_POINT}] ${MODELPARAM_VALUE.FFT_POINT}
}

proc update_MODELPARAM_VALUE.FFT_OUT_WIDTH { MODELPARAM_VALUE.FFT_OUT_WIDTH PARAM_VALUE.FFT_OUT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FFT_OUT_WIDTH}] ${MODELPARAM_VALUE.FFT_OUT_WIDTH}
}

proc update_MODELPARAM_VALUE.IFFT_OUT_WIDTH { MODELPARAM_VALUE.IFFT_OUT_WIDTH PARAM_VALUE.IFFT_OUT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IFFT_OUT_WIDTH}] ${MODELPARAM_VALUE.IFFT_OUT_WIDTH}
}

proc update_MODELPARAM_VALUE.Fiter_jie { MODELPARAM_VALUE.Fiter_jie PARAM_VALUE.Fiter_jie } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Fiter_jie}] ${MODELPARAM_VALUE.Fiter_jie}
}

proc update_MODELPARAM_VALUE.OUT_jie { MODELPARAM_VALUE.OUT_jie PARAM_VALUE.OUT_jie } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT_jie}] ${MODELPARAM_VALUE.OUT_jie}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

