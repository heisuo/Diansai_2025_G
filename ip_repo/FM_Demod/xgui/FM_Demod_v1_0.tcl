# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "En_Sample_Interval" -parent ${Page_0}
  ipgui::add_param $IPINST -name "En_debug" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT_DATA_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.En_Sample_Interval { PARAM_VALUE.En_Sample_Interval } {
	# Procedure called to update En_Sample_Interval when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.En_Sample_Interval { PARAM_VALUE.En_Sample_Interval } {
	# Procedure called to validate En_Sample_Interval
	return true
}

proc update_PARAM_VALUE.En_debug { PARAM_VALUE.En_debug } {
	# Procedure called to update En_debug when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.En_debug { PARAM_VALUE.En_debug } {
	# Procedure called to validate En_debug
	return true
}

proc update_PARAM_VALUE.INPUT_DATA_WIDTH { PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to update INPUT_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_DATA_WIDTH { PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to validate INPUT_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.INPUT_DATA_WIDTH { MODELPARAM_VALUE.INPUT_DATA_WIDTH PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_DATA_WIDTH}] ${MODELPARAM_VALUE.INPUT_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.En_Sample_Interval { MODELPARAM_VALUE.En_Sample_Interval PARAM_VALUE.En_Sample_Interval } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.En_Sample_Interval}] ${MODELPARAM_VALUE.En_Sample_Interval}
}

proc update_MODELPARAM_VALUE.En_debug { MODELPARAM_VALUE.En_debug PARAM_VALUE.En_debug } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.En_debug}] ${MODELPARAM_VALUE.En_debug}
}

