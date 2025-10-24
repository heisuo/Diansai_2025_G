# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "En_Carrier_Out" -parent ${Page_0}
  ipgui::add_param $IPINST -name "En_debug" -parent ${Page_0}


}

proc update_PARAM_VALUE.En_Carrier_Out { PARAM_VALUE.En_Carrier_Out } {
	# Procedure called to update En_Carrier_Out when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.En_Carrier_Out { PARAM_VALUE.En_Carrier_Out } {
	# Procedure called to validate En_Carrier_Out
	return true
}

proc update_PARAM_VALUE.En_debug { PARAM_VALUE.En_debug } {
	# Procedure called to update En_debug when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.En_debug { PARAM_VALUE.En_debug } {
	# Procedure called to validate En_debug
	return true
}


proc update_MODELPARAM_VALUE.En_debug { MODELPARAM_VALUE.En_debug PARAM_VALUE.En_debug } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.En_debug}] ${MODELPARAM_VALUE.En_debug}
}

proc update_MODELPARAM_VALUE.En_Carrier_Out { MODELPARAM_VALUE.En_Carrier_Out PARAM_VALUE.En_Carrier_Out } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.En_Carrier_Out}] ${MODELPARAM_VALUE.En_Carrier_Out}
}

