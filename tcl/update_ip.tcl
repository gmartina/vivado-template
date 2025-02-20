##########################################################################
##
##  Project/Design : xxxxxxxxxxxxx
##  File Name      : update_ip.tcl
##  Author        : xxxxxxxxxxxxx
##
##########################################################################
##
##  File Summary   : Vivado TCL script 
##                   to update ip tcl files                      
##
##########################################################################

## Args
set project_dir  "[pwd]"
#foreach i $argv {puts $i}
set PRJ_NAME [lindex $argv 0]
set BD_NAME [lindex $argv 1]

set_msg_config -id {[IP_Flow 19-3664]} -new_severity INFO
open_project ${PRJ_NAME}.xpr
puts "[pwd]"

################################################################################
# CUSTOMIZABLE
################################################################################

#Generic:
write_ip_tcl -force [get_ips zzzzzzzzzz] ../src/ip/zzzzzzzzzzz.tcl
################################################################################

close_project