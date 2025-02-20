# README #

### What is this repository for? ###

* xxxxxxxxxxxxxxxxxxxxxx
* Vivado version: 2022.1
* xxxxxxxxxxxxxxxxxxxxx

### How do I get set up? ###

* Ensure the required Vivado version is installed in your computer.
* Set the enviroment variable 'VIVADO_2022' pointing to the target vivado installation path. In Windows, search for "Edit enviroment variables for your account" and open the dialog to add or modify an enviroment variable. This is an example of VIVADO_2022 pointing to a Vivado 2022.1 installation:
```
VIVADO_2022=C:\Xilinx\Vivado\2022.1\bin
```
* Execute run.sh (if you are using Windows, you may need git bash terminal for example).
Move to the project path and type: ./run.sh
* In the menu, press 1 to build the Vivado proyect.
* In the menu, press 4 to build the project and generate bitstream, hdf and mcs files.

### How do I update the software (elf file)? ###

* Replace the elf file in the "elf" folder.
* The name of the elf file must be the same name of the Block design (check *bd/*). For example:
```
  ./bd/system_xxxx.tcl
  ./elf/system_xxxx.elf
```

*system_xxxx* will be the name of the block design which contains the Microblaze. The names must match. If there is more than one, you must provide an elf file for each block design.

### Script menu guidelines ###

* 1) Build project: Creates the vivado project in *prj* folder according to the config file and adds all the sources.
* 2) Clean project /!\: Deletes *prj* folder.
* 3) Generate Outputs: Runs synthesis, implementation and bitstream.
* 4) Run All: Runs Build project, synthesis, implementation and bitstream.
* 5) Update block design and IPs: Saves the block designs of the project (in *prj*) to a tcl file in *bd* folder. Saves the IPs into tcl scripts.
* 6) Create folder structure (for new project): Creates the folder structure *src*, *bd* and *ip*.
* 7) Open Vivado: Opens Vivado software.
* 8) Re-run Bitstream only: Resets bitstream step and re-runs it.
* 9) Generate documentation: saves Block designs into pdf files.


### Version control ###
* 1) Set the firmware version in *project.cfg*
* 2) Commit files.
* 3) Run *update_version.sh*, *version_control_rom.vhdl* file will be updated.
* 4) Run Vivado implementation.



