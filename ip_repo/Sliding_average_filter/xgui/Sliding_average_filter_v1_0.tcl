# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "en_sample_interval" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WINDOW_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.WINDOW_WIDTH { PARAM_VALUE.WINDOW_WIDTH } {
	# Procedure called to update WINDOW_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WINDOW_WIDTH { PARAM_VALUE.WINDOW_WIDTH } {
	# Procedure called to validate WINDOW_WIDTH
	return true
}

proc update_PARAM_VALUE.en_sample_interval { PARAM_VALUE.en_sample_interval } {
	# Procedure called to update en_sample_interval when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.en_sample_interval { PARAM_VALUE.en_sample_interval } {
	# Procedure called to validate en_sample_interval
	return true
}


proc update_MODELPARAM_VALUE.WINDOW_WIDTH { MODELPARAM_VALUE.WINDOW_WIDTH PARAM_VALUE.WINDOW_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WINDOW_WIDTH}] ${MODELPARAM_VALUE.WINDOW_WIDTH}
}

proc update_MODELPARAM_VALUE.en_sample_interval { MODELPARAM_VALUE.en_sample_interval PARAM_VALUE.en_sample_interval } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.en_sample_interval}] ${MODELPARAM_VALUE.en_sample_interval}
}

proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

