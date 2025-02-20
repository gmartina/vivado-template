##########################################################################
##
##  Project/Design : xxxxxxxxxxxxx
##  File Name      : generate_doc.tcl
##  Author        : xxxxxxxxxxxxx
##
##########################################################################
##
##  File Summary   : Vivado TCL script to generate BD documentation
##
##########################################################################

# to be customized according to project content

set project_dir  "[pwd]"
#foreach i $argv {puts $i}
set PRJ_NAME [lindex $argv 0]
set BD_NAME [lindex $argv 1]
open_project ${PRJ_NAME}.xpr

# Generate doc:
open_bd_design ./${PRJ_NAME}.srcs/sources_1/bd/${BD_NAME}/${BD_NAME}.bd
write_bd_layout -force -scope all -format pdf -orientation portrait ../doc/${BD_NAME}_top.pdf
write_bd_layout -force -scope all -hierarchy hier_MB               -format pdf -orientation portrait  ../doc/hier_MB.pdf
write_bd_layout -force -scope all -hierarchy AXI_Interconnects -format pdf -orientation portrait  ../doc/AXI_Interconnects.pdf
write_bd_layout -force -scope all -hierarchy System_Interfaces     -format pdf -orientation portrait  ../doc/System_Interfaces.pdf
write_bd_layout -force -scope all -hierarchy Peripheral_Interfaces -format pdf -orientation portrait  ../doc/Peripheral_Interfaces.pdf
close_bd_design [get_bd_designs *]
close_project
exit

###########
## End

