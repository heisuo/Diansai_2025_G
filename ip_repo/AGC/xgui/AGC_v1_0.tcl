# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "en_sample_interval" -parent ${Page_0}
  ipgui::add_param $IPINST -name "en_debug" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INT_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEC_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "shoulian_factor" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUTPUT_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WINDOW_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.DEC_WIDTH { PARAM_VALUE.DEC_WIDTH } {
	# Procedure called to update DEC_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEC_WIDTH { PARAM_VALUE.DEC_WIDTH } {
	# Procedure called to validate DEC_WIDTH
	return true
}

proc update_PARAM_VALUE.INPUT_DATA_WIDTH { PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to update INPUT_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_DATA_WIDTH { PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to validate INPUT_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.INT_WIDTH { PARAM_VALUE.INT_WIDTH } {
	# Procedure called to update INT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INT_WIDTH { PARAM_VALUE.INT_WIDTH } {
	# Procedure called to validate INT_WIDTH
	return true
}

proc update_PARAM_VALUE.OUTPUT_DATA_WIDTH { PARAM_VALUE.OUTPUT_DATA_WIDTH } {
	# Procedure called to update OUTPUT_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUTPUT_DATA_WIDTH { PARAM_VALUE.OUTPUT_DATA_WIDTH } {
	# Procedure called to validate OUTPUT_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.WINDOW_WIDTH { PARAM_VALUE.WINDOW_WIDTH } {
	# Procedure called to update WINDOW_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WINDOW_WIDTH { PARAM_VALUE.WINDOW_WIDTH } {
	# Procedure called to validate WINDOW_WIDTH
	return true
}

proc update_PARAM_VALUE.en_debug { PARAM_VALUE.en_debug } {
	# Procedure called to update en_debug when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.en_debug { PARAM_VALUE.en_debug } {
	# Procedure called to validate en_debug
	return true
}

proc update_PARAM_VALUE.en_sample_interval { PARAM_VALUE.en_sample_interval } {
	# Procedure called to update en_sample_interval when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.en_sample_interval { PARAM_VALUE.en_sample_interval } {
	# Procedure called to validate en_sample_interval
	return true
}

proc update_PARAM_VALUE.shoulian_factor { PARAM_VALUE.shoulian_factor } {
	# Procedure called to update shoulian_factor when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.shoulian_factor { PARAM_VALUE.shoulian_factor } {
	# Procedure called to validate shoulian_factor
	return true
}


proc update_MODELPARAM_VALUE.INT_WIDTH { MODELPARAM_VALUE.INT_WIDTH PARAM_VALUE.INT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INT_WIDTH}] ${MODELPARAM_VALUE.INT_WIDTH}
}

proc update_MODELPARAM_VALUE.DEC_WIDTH { MODELPARAM_VALUE.DEC_WIDTH PARAM_VALUE.DEC_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEC_WIDTH}] ${MODELPARAM_VALUE.DEC_WIDTH}
}

proc update_MODELPARAM_VALUE.shoulian_factor { MODELPARAM_VALUE.shoulian_factor PARAM_VALUE.shoulian_factor } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.shoulian_factor}] ${MODELPARAM_VALUE.shoulian_factor}
}

proc update_MODELPARAM_VALUE.WINDOW_WIDTH { MODELPARAM_VALUE.WINDOW_WIDTH PARAM_VALUE.WINDOW_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WINDOW_WIDTH}] ${MODELPARAM_VALUE.WINDOW_WIDTH}
}

proc update_MODELPARAM_VALUE.en_sample_interval { MODELPARAM_VALUE.en_sample_interval PARAM_VALUE.en_sample_interval } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.en_sample_interval}] ${MODELPARAM_VALUE.en_sample_interval}
}

proc update_MODELPARAM_VALUE.INPUT_DATA_WIDTH { MODELPARAM_VALUE.INPUT_DATA_WIDTH PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_DATA_WIDTH}] ${MODELPARAM_VALUE.INPUT_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.OUTPUT_DATA_WIDTH { MODELPARAM_VALUE.OUTPUT_DATA_WIDTH PARAM_VALUE.OUTPUT_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUTPUT_DATA_WIDTH}] ${MODELPARAM_VALUE.OUTPUT_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.en_debug { MODELPARAM_VALUE.en_debug PARAM_VALUE.en_debug } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.en_debug}] ${MODELPARAM_VALUE.en_debug}
}

