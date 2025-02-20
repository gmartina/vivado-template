##########################################################################
##
##  Project/Design : xxxxxxxxxxxxx
##  File Name      : generate_bitstream.tcl
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



if { ${OPTION} == "ALL" } {
    source ../tcl/strategy.tcl
    set_param general.maxThreads 4
    reset_run synth_1
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
 
# Set the generics
#set_property generic "DATE_CODE=32'h$datecode HASH_CODE=32'h$git_hash" [current_fileset]


###########################################################
# Run to write_bitstream
###########################################################

if { ${OPTION} == "ALL" } {
    launch_runs synth_1 -jobs 4
    wait_on_run synth_1
}

# findFiles can find files in subdirs and add it into a list
proc findFiles { basedir pattern } {

    # Fix the directory name, this ensures the directory name is in the
    # native format for the platform and contains a final directory seperator
    set basedir [string trimright [file join [file normalize $basedir] { }]]
    set fileList {}
    array set myArray {}
    
    # Look in the current directory for matching files, -type {f r}
    # means ony readable normal files are looked at, -nocomplain stops
    # an error being thrown if the returned list is empty

    foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
        lappend fileList $fileName
    }
    
    # Now look for any sub direcories in the current directory
    foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
        # Recusively call the routine on the sub directory and append any
        # new files to the results
        # put $dirName
        set subDirList [findFiles $dirName $pattern]
        if { [llength $subDirList] > 0 } {
            foreach subDirFile $subDirList {
                lappend fileList $subDirFile
            }
        }
    }
    return $fileList
}

if { ${OPTION} == "ALL" } {
    puts "Launching Implementation"
    launch_runs impl_1 -to_step write_bitstream -jobs 16
    wait_on_run impl_1
    puts "Implementation done!" 
} else {
    get_property STATUS [get_runs impl_1]
    puts "Launching write_bitstream"
    # update_compile_order -fileset sources_1
    # reset_run impl_1 -prev_step 
    reset_run impl_1 -from_step write_bitstream
    launch_runs impl_1 -to_step write_bitstream -jobs 16
    wait_on_run impl_1
    # get_property STATUS [get_runs impl_1]
}

set wns [get_property STATS.WNS [get_runs impl_1]]
set whs [get_property STATS.WHS [get_runs impl_1]]
if { $wns >= 0 && $whs >= 0 } {
    puts "##################################"
    puts "Timing met! WNS: $wns WHS: $whs"
    puts "##################################"
} else {
    puts "##################################"
    puts "Timing NOT met! WNS: $wns WHS: $whs"
    puts "##################################"
    # interrupt script execution and return an error code to the calling bash script
    exit 1
}

get_property STATUS [get_runs impl_1]

set project_path [get_property parent.project_path [current_project]]
set project_file [file rootname $project_path]
set output_name "${PRJ_NAME}_${git_hash_simple}_${datecode}"
puts "Output name generated: ${output_name}"

## HW description file generation:
#write_hw_platform -force ${output_name}.hdf

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
write_cfgmem -format mcs -interface SPIx4 -size 64  -loadbit "up 0x0 $bitstream" -file ../../../bin/xxxx.mcs -force
write_cfgmem -format mcs -interface SPIx4 -size 64  -loadbit "up 0x0 $bitstream" -file ../../../bin_others/${output_name}.mcs -force
write_cfgmem -format bin -interface SPIx4 -size 64  -loadbit "up 0x0 $bitstream" -file ../../../bin/xxxx.bin -force
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