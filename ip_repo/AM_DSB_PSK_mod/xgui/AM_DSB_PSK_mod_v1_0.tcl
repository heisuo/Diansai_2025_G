# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "IF_DSB_PSK" -parent ${Page_0}


}

proc update_PARAM_VALUE.IF_DSB_PSK { PARAM_VALUE.IF_DSB_PSK } {
	# Procedure called to update IF_DSB_PSK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IF_DSB_PSK { PARAM_VALUE.IF_DSB_PSK } {
	# Procedure called to validate IF_DSB_PSK
	return true
}


proc update_MODELPARAM_VALUE.IF_DSB_PSK { MODELPARAM_VALUE.IF_DSB_PSK PARAM_VALUE.IF_DSB_PSK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IF_DSB_PSK}] ${MODELPARAM_VALUE.IF_DSB_PSK}
}

