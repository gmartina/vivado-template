#!/bin/bash

# Paths relative to run.sh
SCRIPTS_DIR="tcl"
BASE_DIR="."
PRJ_DIR="prj"

# TCL arguments to be passed to Vivado
#TCL_ARGS="scripts_dir=${SCRIPTS_DIR} base_dir=${BASE_DIR} ${TCL_ARGS}"


################################################################################
## Parameter substitution

# Settings will substitue <PARAM> in copied files
if [ -f "project.cfg" ]; then
    echo "Sourcing project configuration file '$project.cfg'"
    source "./project.cfg"
else
    FPGA_TOP="fpga_top"
    YEAR=`date +%Y`
fi

declare -A SUBSTITUTES_MAP
SUBSTITUTES_MAP=(
    ["<PRJ_NAME>"]="${PRJ_NAME}"
    ["<VIVADO_VERSION>"]="${VIVADO_VERSION}"
    ["<VIVADO_YEAR>"]="${VIVADO_YEAR}"
    ["<TARGET_LANGUAGE>"]="${TARGET_LANGUAGE}"
    ["<DEFAULT_LIB>"]="${DEFAULT_LIB}"
    ["<TARGET_SIMULATOR>"]="${TARGET_SIMULATOR}"
    ["<SIMULATOR_LANGUAGE>"]="${SIMULATOR_LANGUAGE}"
    ["<BOARD>"]="${BOARD}"
    ["<PART>"]="${PART}"
    ["<YEAR>"]="${YEAR}"
    ["<FPGA_TOP>"]="${FPGA_TOP}"
)


if [ -f "${PRJ_CFG}" ]; then
    # Check that all values are set by the user
    for KEY in ${!SUBSTITUTES_MAP[@]} ; do
        VALUE=${SUBSTITUTES_MAP[$KEY]}

        if [ -z "${VALUE}" ]; then
            if [ "${KEY}" == "<BOARD>" ]; then
                echo "${KEY} is undefined. Continuing..."
            else
                echo "ERROR: Please define ${KEY} in project.cfg"; exit 1
            fi
        fi
    done
fi

echo $BOARD
TCL_ARGS="${PRJ_NAME} ${VIVADO_VERSION} ${BOARD} ${PART} ${FPGA_TOP} ${TARGET_LANGUAGE} ${SIMULATOR_LANGUAGE} ${DEFAULT_LIB} ${TARGET_SIMULATOR}" 

#if [ "${BOARD}"=="" ]; then
#	echo "No board selected."
#	TCL_ARGS="${PRJ_NAME} ${VIVADO_VERSION} ${PART} ${FPGA_TOP} ${TARGET_LANGUAGE} ${SIMULATOR_LANGUAGE} ${DEFAULT_LIB} ${TARGET_SIMULATOR}" 
#else
#	TCL_ARGS="${PRJ_NAME} ${VIVADO_VERSION} ${BOARD} ${PART} ${FPGA_TOP} ${TARGET_LANGUAGE} ${SIMULATOR_LANGUAGE} ${DEFAULT_LIB} ${TARGET_SIMULATOR}" 
#fi

echo "Project name: ${PRJ_NAME}"
echo "Part: ${PART}"  
echo "Vivado version: ${VIVADO_VERSION}" 
RETVAL = 0  

create_project(){
	########################################################################
	# Create build directory
	mkdir -p "$PRJ_DIR"
	if [ $? -ne 0 ]; then
		echo "Could not create project directory: $PRJ_DIR"
		echo "Exiting..."; exit 1
	fi

    TCL_ARGS="${PRJ_NAME} ${VIVADO_VERSION} ${BOARD} ${PART} ${FPGA_TOP} ${TARGET_LANGUAGE} ${SIMULATOR_LANGUAGE} ${DEFAULT_LIB} ${TARGET_SIMULATOR}" 

	# Run Vivado in build directory
	pushd "$PRJ_DIR"
	echo "Using $PRJ_DIR as the build directory"

	time ${VIVADO_SCRIPT}/vivado \
		-mode batch \
		-notrace \
		-source "../${SCRIPTS_DIR}/build.tcl" \
		-tclargs $TCL_ARGS
	RETVAL=$?

	echo "The build directory was $PRJ_DIR"
    echo "RETVAL= $RETVAL"
	popd

}

generate_bitstream(){
    TCL_ARGS="${PRJ_NAME} ALL" 

	# Run Vivado in build directory
	pushd "$PRJ_DIR"
	echo "Using $PRJ_DIR as the build directory"

	time ${VIVADO_SCRIPT}/vivado \
		-mode batch \
		-notrace \
		-source "../${SCRIPTS_DIR}/generate_bitstream.tcl" \
		-tclargs $TCL_ARGS
	RETVAL=$?

	echo "The build directory was $PRJ_DIR"
	popd
}

generate_bitstream_only(){
    TCL_ARGS="${PRJ_NAME} BITSTREAM_ONLY" 

	# Run Vivado in build directory
	pushd "$PRJ_DIR"
	echo "Using $PRJ_DIR as the build directory"

	time ${VIVADO_SCRIPT}/vivado \
		-mode batch \
		-notrace \
		-source "../${SCRIPTS_DIR}/generate_bitstream.tcl" \
		-tclargs $TCL_ARGS
	RETVAL=$?

	echo "The build directory was $PRJ_DIR"
	popd
}

vivado_open(){
    TCL_ARGS="${PRJ_NAME}" 

	# Run Vivado in build directory
	pushd "$PRJ_DIR"
	echo "Using $PRJ_DIR as the build directory"

	time ${VIVADO_SCRIPT}/vivado \
		-mode batch \
		-notrace \
		-source "../${SCRIPTS_DIR}/open.tcl" \
		-tclargs $TCL_ARGS
	RETVAL=$?

	echo "The build directory was $PRJ_DIR"
	popd
}

update_bd(){

    root_dir=$PWD
    dir="./${PRJ_DIR}/${PRJ_NAME}.srcs/sources_1/bd"
    cd ${dir}
    
    for BD_NAME in *
    do  
        echo "$BD_NAME"
        cd ${root_dir}
        # Run Vivado in build directory
        pushd "$PRJ_DIR"
        echo "Using $PRJ_DIR as the build directory"
        TCL_ARGS="${PRJ_NAME} ${BD_NAME}" 

        time ${VIVADO_SCRIPT}/vivado \
            -mode batch \
            -notrace \
            -source "../${SCRIPTS_DIR}/update_bd.tcl" \
            -tclargs $TCL_ARGS
        RETVAL=$?

        echo "The build directory was $PRJ_DIR"
        popd
    done
    cd ${root_dir}
}

#
#generate_mcs(){
#
#}


show_menu(){
	clear
    normal=`echo "\033[m"`
    menu=`echo "\033[36m"` #Blue
    number=`echo "\033[33m"` #yellow
    bgred=`echo "\033[41m"`
    fgred=`echo "\033[31m"`
	printf "\n${menu}***************************************************${normal}\n"
	printf "${menu}**                                               **${normal}\n"
	printf "${menu}**          ${fgred}Vivado Project Manager${menu}               **${normal}\n"
    printf "${menu}**                                               **${normal}\n"
    printf "${menu}***************************************************${normal}\n"
    printf "${menu}**${number} 1)${menu} Build project ${normal}\n"
    printf "${menu}**${number} 2)${menu} Clean project /!\\ ${normal}\n"
    printf "${menu}**${number} 3)${menu} Generate outputs (Bitstream and Flash file) ${normal}\n"
    printf "${menu}**${number} 4)${menu} RUN ALL (Build Project, Bitstream and Flash file) ${normal}\n"
    printf "${menu}**${number} 5)${menu} Update block design (/bd/*.tcl) ${normal}\n"
    printf "${menu}**${number} 6)${menu} Create folder structure (for new project)${normal}\n"
    printf "${menu}**${number} 7)${menu} Open vivado project${normal}\n"
    printf "${menu}**${number} 8)${menu} Re-Run Bitstream Only${normal}\n"
    printf "${menu}***************************************************${normal}\n"
    printf "Please enter a menu option and enter or ${fgred}x to exit. ${normal}"
    read opt
}     

option_picked(){
    msgcolor=`echo "\033[01;31m"` # bold red
    normal=`echo "\033[00;00m"` # normal white
    message=${@:-"${normal}Error: No message passed"}
    printf "${msgcolor}${message}${normal}\n"
}

if [ $# == 0 ]; then
    echo "0 arguments."

    clear
    show_menu
    while [ $opt != '' ]
        do
        if [ $opt = '' ]; then
        exit;
        else
        case $opt in
            1) clear;
                option_picked "Build project";
                create_project;
                option_picked "Press enter to continue\n";
                read press
                show_menu;
            ;;
            2) clear;
                option_picked "Clean project /!\\";
                option_picked "Any changes to Block design will be lost. Press 'y' to continue...\n";
                read press
                if [ $press = 'y' ]; then
                    rm -r prj
                    show_menu;
                else
                    show_menu;
                fi

            ;;
            3) clear;
                option_picked "Generate outputs (Bitstream and Flash file)";
                mkdir bin
                generate_bitstream;
                option_picked "Press enter to continue\n";
                read press
                show_menu;
            ;;
            4) clear;
                option_picked "RUN ALL (Build, Bitstream and Flash file)";
                mkdir bin
                create_project;
                generate_bitstream;
                option_picked "Press enter to continue\n";
                read press
                show_menu;
            ;;
            5) clear;
                option_picked "Update block design";
                update_bd; 
                option_picked "Press enter to continue\n";
                read press
                show_menu;
            ;;
            6) clear;
                option_picked "Create folder structure (Only when starting a new project)";
                mkdir bd
                mkdir ip
                mkdir src
                mkdir elf
                mkdir ./src/top
                show_menu;
            ;;
            7) clear;
                option_picked "Open Vivado project";
                vivado_open;
                option_picked "Press enter to continue\n";
                read press
                show_menu;
            ;;
            8) clear;
                option_picked "Re-Run Bitstream Only";
                mkdir bin
                generate_bitstream_only;
                option_picked "Press enter to continue\n";
                read press
                show_menu;
            ;;
            x)exit;
            ;;
            \n)exit;
            ;;
            *)clear;
                option_picked "Pick an option from the menu";
                show_menu;
            ;;
        esac
        fi
    done

elif [ $# == 1 ]; then
    echo "1 argument detected. Mode command."

    if [ $1 == "--build" ]; then
        echo "Build project";
        create_project;
        echo "Finished:";
        if [ $? == '0' ]; then
            exit 0
        else
            exit 1
        fi
    elif [ $1 == "--clean" ]; then
        rm -r prj
    elif [ $1 == "--generate" ]; then
        echo "Generate outputs (Bitstream and Flash file)";
        mkdir bin
        generate_bitstream;
        exit RETVAL
    elif [ $1 == "--all" ]; then
        echo "RUN ALL (Build, Bitstream and Flash file)";
        mkdir bin
        create_project;
        generate_bitstream;
        exit RETVAL
    elif [ $1 == "--rerun-bitstream" ]; then
        option_picked "Re-Run Bitstream Only";
        mkdir bin
        generate_bitstream_only;
        exit RETVAL
    elif [ $1 == "--open" ]; then
        echo "Opening Vivado project";
        vivado_open;
    else
        echo "Error! Invalid argument."
        echo "List of commands:"
        echo "--build"
        echo "--clean"
        echo "--generate"
        echo "--all"
        echo "--rerun-bitstream"
        echo "--open"
        exit;
    fi

else
    echo "Error! Too many arguments."
    exit;
fi

exit;

