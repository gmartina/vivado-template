##########################################################################
##
##  Project/Design : xxxxxxxxxxxxx
##  File Name      : update_bd.tcl
##  Author        : xxxxxxxxxxxxx
##
##########################################################################
##
##  File Summary   : Vivado TCL script 
##                   to update saved BD script from the project                      
##
##########################################################################

set project_dir  "[pwd]"
#foreach i $argv {puts $i}
set PRJ_NAME [lindex $argv 0]
set BD_NAME [lindex $argv 1]
puts "PRJ_NAME= $PRJ_NAME"
puts "BD_NAME= $BD_NAME"
set_msg_config -id {[IP_Flow 19-3664]} -new_severity INFO
open_project ${PRJ_NAME}.xpr
puts "[pwd]"
open_bd_design ./${PRJ_NAME}.srcs/sources_1/bd/${BD_NAME}/${BD_NAME}.bd
validate_bd_design
write_bd_tcl -force ../bd/${BD_NAME}.tcl
close_bd_design [get_bd_designs *]
close_project

###########
## End