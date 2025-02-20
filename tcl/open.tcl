##########################################################################
##
##  Project/Design : xxxxxxxxxxxxx
##  File Name      : open.tcl
##  Author        : xxxxxxxxxxxxx
##
##########################################################################
##
##  File Summary   : Vivado TCL script to open the project
##
##########################################################################

set PRJ_NAME [lindex $argv 0]
start_gui
open_project $PRJ_NAME.xpr
