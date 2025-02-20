##########################################################################
##
##  Project/Design : 
##  File Name      : build.tcl
##  Initial Author : xxxxxxxxxxxxx
##
##########################################################################
##
##  File Summary   : Vivado build TCL script executed from run.sh
##
##########################################################################


###########################################################
# Misc.
###########################################################

set text_yellow     "\033\[33m"
set text_red        "\033\[31m"
set text_green      "\033\[32m"
# set text_blue       "\033\[34m"
# set text_white      "\033\[37m"
# set text_underscore "\033\[4m"
set text_noattrib   "\033\[0m"


###########################################################
## Project specific arguments
###########################################################

set project_dir  "[pwd]"
#foreach i $argv {puts $i}

if { [llength $argv] == 9 } {

	set PRJ_NAME [lindex $argv 0]
	set REQ_VIVADO_VERSION [lindex $argv 1]
	set BOARD [lindex $argv 2]
	set PART [lindex $argv 3]
	set FPGA_TOP [lindex $argv 4]
	set TARGET_LANGUAGE [lindex $argv 5]
	set SIMULATOR_LANGUAGE [lindex $argv 6]
	set DEFAULT_LIB [lindex $argv 7]
	set TARGET_SIMULATOR [lindex $argv 8]
    puts [format "%s%s%s" $text_yellow "Board: $BOARD" $text_noattrib]
} else {
    puts [format "%s%s%s" $text_yellow "No Board" $text_noattrib]
	set PRJ_NAME [lindex $argv 0]
	set REQ_VIVADO_VERSION [lindex $argv 1]
	set PART [lindex $argv 2]
	set FPGA_TOP [lindex $argv 3]
	set TARGET_LANGUAGE [lindex $argv 4]
	set SIMULATOR_LANGUAGE [lindex $argv 5]
	set DEFAULT_LIB [lindex $argv 6]
	set TARGET_SIMULATOR [lindex $argv 7]
}

puts [format "%s%s%s" $text_green "PRJ_NAME:           $PRJ_NAME" $text_noattrib]
puts [format "%s%s%s" $text_green "REQ_VIVADO_VERSION: $REQ_VIVADO_VERSION" $text_noattrib]
puts [format "%s%s%s" $text_green "PART:               $PART" $text_noattrib]
puts [format "%s%s%s" $text_green "FPGA_TOP:           $FPGA_TOP" $text_noattrib]
puts [format "%s%s%s" $text_green "TARGET_LANGUAGE:    $TARGET_LANGUAGE" $text_noattrib]
puts [format "%s%s%s" $text_green "SIMULATOR_LANGUAGE: $SIMULATOR_LANGUAGE" $text_noattrib]
puts [format "%s%s%s" $text_green "DEFAULT_LIB:        $DEFAULT_LIB" $text_noattrib]
puts [format "%s%s%s" $text_green "TARGET_SIMULATOR:   $TARGET_SIMULATOR" $text_noattrib]


###########################################################
## Vivado version verification
###########################################################

set vivado_version [version -short]
if {[lsearch -exact $REQ_VIVADO_VERSION $vivado_version] < 0} {
    puts ""
	puts [format "%s%s%s" $text_red "ERROR: Please use Vivado '[lindex $REQ_VIVADO_VERSION 0]'" $text_noattrib]
	puts [format "%s%s%s" $text_red " and not '$vivado_version' to build the system!" $text_noattrib]
	exit 2
    }
if {![string equal "[lindex $REQ_VIVADO_VERSION 0]" "$vivado_version"]} {
    puts -nonewline [format "%s%s%s" $text_yellow "WARNING: You are using Vivado '$vivado_version' and not " $text_noattrib]
    puts            [format "%s%s%s" $text_yellow "the recommended '[lindex $REQ_VIVADO_VERSION 0]'!" $text_noattrib]
}
set vivado_year [lindex [split "${vivado_version}" "."] 0]


###########################################################
## Set up project & properties
###########################################################

puts [format "%s%s%s" $text_yellow "Creating project \"$PRJ_NAME\" in $project_dir with $PART" $text_noattrib]

# puts "Create filesets constraints, source, simulation"
create_project $PRJ_NAME $project_dir -part $PART -force
set cur_prj [get_projects $PRJ_NAME]

config_webtalk -user off

# set_property board_part       $board            $cur_prj
set_property target_language  $TARGET_LANGUAGE  $cur_prj
set_property default_lib      $DEFAULT_LIB      $cur_prj
set_property target_simulator $TARGET_SIMULATOR $cur_prj

if {[info exists simulator_language]} {
	set_property simulator_language $target_simulator $cur_prj
}		
	
# Set project properties
set obj [current_project]
set_property -name "part" -value $PART -objects $obj
set_property -name "default_lib" -value $DEFAULT_LIB -objects $obj

set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "target_language" -value $TARGET_LANGUAGE -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj

set_property -name "coreContainer.enable" -value "0" -objects $obj

set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj

# Add source, IP, constraints and BD files

puts [format "%s%s%s" $text_yellow "Adding constraints, source and IP files..." $text_noattrib]
source ../tcl/add_sources.tcl


puts [format "%s%s%s" $text_yellow "Adding block diagram..." $text_noattrib]
foreach bd_script [glob -nocomplain -dir ../bd/ *.tcl] {
    source $bd_script
    set basename [file rootname [file tail $bd_script]]
    make_wrapper -files [get_files ./${PRJ_NAME}.srcs/sources_1/bd/${basename}/${basename}.bd] -top  
    set wrapper_dir "./${PRJ_NAME}.srcs/sources_1/bd/${basename}/hdl/${basename}_wrapper.vhd"
    add_files -norecurse $wrapper_dir
    update_compile_order -fileset sources_1
	validate_bd_design
}

puts [format "%s%s%s" $text_green "Finished adding files..."  $text_noattrib]

update_compile_order -fileset sources_1
set_property top $FPGA_TOP [current_fileset]
update_compile_order -fileset sources_1
set_param general.maxThreads 16
##set_property STEPS.SYNTH_DESIGN.ARGS.INCREMENTAL_MODE off [get_runs synth_1]
##set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs synth_1]

puts [format "%s%s%s" $text_green "Setting strategies..."  $text_noattrib]
source ../tcl/strategy.tcl

puts [format "%s%s%s" $text_green "Adding .elf file into MicroBlaze..."  $text_noattrib]
set srcELF "../elf/software.elf"
# Add elf files
if { [file exists $srcELF] } {
    puts "ELF file found: [llength $srcELF]"
    add_files -norecurse -fileset sources_1 $srcELF
    puts "$srcELF"
    # foreach elf_file $srcELF {
    set file_obj [get_files -all -of_objects [get_fileset sources_1] $srcELF]
    set basename [file rootname [file tail $srcELF]]
    set_property -name "scoped_to_cells" -value "hier_MB/microblaze_0" -objects $file_obj
    set_property -name "scoped_to_ref" -value $basename -objects $file_obj
    set_property -name "used_in" -value "implementation" -objects $file_obj
    set_property -name "used_in_simulation" -value "0" -objects $file_obj
    # }
} else {
    puts "ELF file not found!!!"
}


puts [format "%s%s%s" $text_green "Finished Build script"  $text_noattrib]
exit 0		
	
###########
## End