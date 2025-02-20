# CUSTOMIZABLE

# Add
source ../tcl/example.tcl

#######################################
##  Add Version control files
##  to Lib: version_control_lib
#######################################
add_files -norecurse { \
  ../src/hdl/version_control/version_control_rom.vhdl \
  }

set_property library version_control_lib [get_files  { \
  ../src/hdl/version_control/version_control_rom.vhdl \
  }]


source ../src/ip/my_ip.tcl


add_files -fileset constrs_1 -norecurse ../src/constr/constr.xdc

update_compile_order -fileset sim_1

set_property file_type {VHDL 2008} [get_files *.vhd]


