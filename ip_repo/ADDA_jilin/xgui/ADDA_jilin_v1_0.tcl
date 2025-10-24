# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set optional [ipgui::add_group $IPINST -name "optional" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "BYPASS_NSINC" -parent ${optional}

  #Adding Group
  set ADC_setting [ipgui::add_group $IPINST -name "ADC_setting" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "ADC_DCO_DELAY" -parent ${ADC_setting}
  ipgui::add_static_text $IPINST -name "ADC_Delay" -parent ${ADC_setting} -text {0～31: delay_value [delay = (3100 ps * delay_value/31 +100)]}

  #Adding Group
  set DAC_setting [ipgui::add_group $IPINST -name "DAC setting" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "DAC_DCI_DELAY_MODE" -parent ${DAC_setting}
  ipgui::add_static_text $IPINST -name "jieshi1" -parent ${DAC_setting} -text {0～3: 0:350ps 1:590ps 2:800ps 3:925ps}



}

proc update_PARAM_VALUE.ADC_DCO_DELAY { PARAM_VALUE.ADC_DCO_DELAY } {
	# Procedure called to update ADC_DCO_DELAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_DCO_DELAY { PARAM_VALUE.ADC_DCO_DELAY } {
	# Procedure called to validate ADC_DCO_DELAY
	return true
}

proc update_PARAM_VALUE.BYPASS_NCO { PARAM_VALUE.BYPASS_NCO } {
	# Procedure called to update BYPASS_NCO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BYPASS_NCO { PARAM_VALUE.BYPASS_NCO } {
	# Procedure called to validate BYPASS_NCO
	return true
}

proc update_PARAM_VALUE.BYPASS_NSINC { PARAM_VALUE.BYPASS_NSINC } {
	# Procedure called to update BYPASS_NSINC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BYPASS_NSINC { PARAM_VALUE.BYPASS_NSINC } {
	# Procedure called to validate BYPASS_NSINC
	return true
}

proc update_PARAM_VALUE.DAC_DCI_DELAY_MODE { PARAM_VALUE.DAC_DCI_DELAY_MODE } {
	# Procedure called to update DAC_DCI_DELAY_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DAC_DCI_DELAY_MODE { PARAM_VALUE.DAC_DCI_DELAY_MODE } {
	# Procedure called to validate DAC_DCI_DELAY_MODE
	return true
}

proc update_PARAM_VALUE.NCO_FTW { PARAM_VALUE.NCO_FTW } {
	# Procedure called to update NCO_FTW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NCO_FTW { PARAM_VALUE.NCO_FTW } {
	# Procedure called to validate NCO_FTW
	return true
}


proc update_MODELPARAM_VALUE.DAC_DCI_DELAY_MODE { MODELPARAM_VALUE.DAC_DCI_DELAY_MODE PARAM_VALUE.DAC_DCI_DELAY_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DAC_DCI_DELAY_MODE}] ${MODELPARAM_VALUE.DAC_DCI_DELAY_MODE}
}

proc update_MODELPARAM_VALUE.BYPASS_NSINC { MODELPARAM_VALUE.BYPASS_NSINC PARAM_VALUE.BYPASS_NSINC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BYPASS_NSINC}] ${MODELPARAM_VALUE.BYPASS_NSINC}
}

proc update_MODELPARAM_VALUE.ADC_DCO_DELAY { MODELPARAM_VALUE.ADC_DCO_DELAY PARAM_VALUE.ADC_DCO_DELAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_DCO_DELAY}] ${MODELPARAM_VALUE.ADC_DCO_DELAY}
}

proc update_MODELPARAM_VALUE.BYPASS_NCO { MODELPARAM_VALUE.BYPASS_NCO PARAM_VALUE.BYPASS_NCO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BYPASS_NCO}] ${MODELPARAM_VALUE.BYPASS_NCO}
}

proc update_MODELPARAM_VALUE.NCO_FTW { MODELPARAM_VALUE.NCO_FTW PARAM_VALUE.NCO_FTW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NCO_FTW}] ${MODELPARAM_VALUE.NCO_FTW}
}

