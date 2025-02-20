##########################################################################
##
##  Project/Design : xxxxxxxxxxxxx
##  File Name      : generate_files.tcl
##  Author        : xxxxxxxxxxxxx
##
##########################################################################
##
##  File Summary   : Vivado TCL script to generate bitstreams
##
##########################################################################

set project_dir  "[pwd]"
#foreach i $argv {puts $i}
set PRJ_NAME [lindex $argv 0]
set OPTION  [lindex $argv 1]
puts OPTION=${OPTION}
open_project ${PRJ_NAME}.xpr

set status [get_property STATUS [get_runs impl_1]]
puts "PROJECT STATUS: $status"

if { $status == "write_bitstream Complete!" } {
    puts "######################################"
    puts "Generating release output products..."
    puts "######################################"
} else {
    puts "##################################"
    puts "write_bitstream not complete, output products can not be generated. Rerun bitstream generation."
    puts "##################################"
    exit
}

###########################################################
# Current date, time, and seconds since epoch
###########################################################
# 0 = 4-digit year
# 1 = 2-digit year
# 2 = 2-digit month
# 3 = 2-digit day
# 4 = 2-digit hour
# 5 = 2-digit minute
# 6 = 2-digit second
# 7 = Epoch (seconds since 1970-01-01_00:00:00)
# Array index                                            0  1  2  3  4  5  6  7
set datetime_arr [clock format [clock seconds] -format {%Y %y %m %d %H %M %S %s}]
 
# Get the datecode in the yy-mm-dd-HH format
set datecode [lindex $datetime_arr 0][lindex $datetime_arr 2][lindex $datetime_arr 3][lindex $datetime_arr 4][lindex $datetime_arr 5]
# Show this in the log
puts DATECODE=$datecode
 
# Get the git hashtag for this project
set curr_dir [pwd]
set proj_dir [get_property DIRECTORY [current_project]]
cd $proj_dir
set git_hash [exec git log -1 --pretty='%h']
set git_hash_simple [exec git log -1 --pretty=%h]
# Show this in the log
puts HASHCODE=$git_hash

get_property STATUS [get_runs impl_1]

set project_path [get_property parent.project_path [current_project]]
set project_file [file rootname $project_path]
set output_name "${PRJ_NAME}_${git_hash_simple}_${datecode}"
puts "Output name generated: ${output_name}"


puts "Finding bitstream..."
cd ./${PRJ_NAME}.runs/impl_1/
set bitstream [glob -nocomplain *.bit]
set mmi [glob -nocomplain *.mmi]
puts "Finding debug_probes..."
set debug_probes [glob -nocomplain *top.ltx]
puts "Found: "
puts $bitstream
puts $mmi
puts $debug_probes

## Flash memory file generation:
write_cfgmem -format mcs -interface SPIx4 -size 64  -loadbit "up 0x0 $bitstream" -file ../../../bin/xxxxxx.mcs -force
write_cfgmem -format mcs -interface SPIx4 -size 64  -loadbit "up 0x0 $bitstream" -file ../../../bin_others/${output_name}.mcs -force
write_cfgmem -format bin -interface SPIx4 -size 64  -loadbit "up 0x0 $bitstream" -file ../../../bin/xxxxxx.bin -force
write_cfgmem -format bin -interface SPIx4 -size 64  -loadbit "up 0x0 $bitstream" -file ../../../bin_others/${output_name}.bin -force

## Write HWdef
write_hw_platform -fixed -include_bit -force -file ../../../bin/xxxxxx.xsa
write_hw_platform -fixed -include_bit -force -file ../../../bin_others/${output_name}.xsa

puts "Copying files to bin"
if {[file exists $bitstream]} {
    file copy -force $bitstream ../../../bin/xxxxxx.bit
    file copy -force $bitstream ../../../bin_others/${output_name}.bit
}
if {[file exists $mmi]} {
    file copy -force $mmi ../../../bin/xxxxxx.mmi
    file copy -force $mmi ../../../bin_others/${output_name}.mmi
}
if {[file exists $debug_probes]} {
    file copy -force $debug_probes ../../../bin/xxxxxx.ltx
    file copy -force $debug_probes ../../../bin_others/${output_name}.ltx
}

cd ../../

###########
## End