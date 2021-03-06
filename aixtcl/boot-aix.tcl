

#------------------------------------------------------------------------
#
#	IBM Software
#	Licensed Material - Property of	IBM
#	(C) Copyright International Business Machines Corp. 2014
#	All Rights Reserved.
#
#	U.S. Government	Users Restricted Rights - Use, duplication or
#	disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
#------------------------------------------------------------------------
#  boot-linux-le.tcl
#
#
#------------------------------------------------------------------------
# Run with:
#   /opt/ibm/systemsim-p8/run/pegasus/power8 -f ./boot-linux.tcl
#
# needs a little endian ./vmlinux and a ./disk.img
# 

source $env(LIB_DIR)/common/openfirmware_utils.tcl
proc config_hook { conf } {
    $conf config cpus 2
    $conf config processor/number_of_threads 1
    $conf config memory_size 2048M
    # We're not running under a hypervisor so we want external interrupts
    # directed to the SRRs rather than HSRRs, so we set LPCR[LPES(0)]=1
#    $conf config processor/initial/LPCR 0x8
    # We're running a little endian kernel so we need to set the HILE bit
    # of HID0 so that we stay in little endian mode when handling interrupts
 #   $conf config processor/initial/HID0 0x0000100000000000
}

# Set the filename of the disk image and kernel here

# Increasing the number of hardware threads per processor or the number of
# CPUs in the simulated system will slow down your boot time because the
# underlying simulator is running on only a single thread on the host
# system
#set kernel unix2
#set diskimg_file aix.img
source $env(LIB_DIR)/pegasus/systemsim.tcl

source $env(RUN_DIR)/pegasus/p8-devtree.tcl


source aix_utils.tcl
source aix.tcl
#source $env(LIB_DIR)/ppc/aix_utils.tcl
#source $env(LIB_DIR)/ppc/aix.tcl
#set diskimg_file aix.img

#set diskimage_file=ubuntu.img
# bogus disk
#set diskimg_file aix.img

set diskimg_file rootaix.img
#mysim bogus disk init 0 $cdboot_file r
mysim bogus disk init 0 $diskimg_file cow


#mysim bogus disk init 0 $diskimg_file r
set sim "mysim"
set conf "myconf"
#set kernel unix2

# networking with IRQ off
#mysim bogus net init 0 d0:d0:d0:da:da:da tap0 0 0

# Load vmlinux
# Load vmlinux
#set AIX_KERNEL_FILE unix
#set AIX_KERNEL_SYMBOL_FILE unix_64.map
#set bootdiskfile aix.img

#valid entry point goes here
set entry_point 0x18

Config_For_AIX $conf
Setup_For_AIX $sim
set_aix_bootargs "-s verbose" $sim
aix_patch_hypervisor_emu_assist_intr
#aix_check_boot_files
#puts [AIXUtils::get_function_entry $AIX_KERNEL_SYMBOL_FILE]

#set cdboot_file AIX_CD1.cow

#set_aix_process_triggers $sim 10
$sim load elf /opt/ibm/systemsim-p8/images/szaix/szboot.aD5 0x0
#$sim load elf sh
#puts [AIXUtils::get_function_entry "initp"]
$sim mode fastest
#$sim go
#wait_for_aix_prompt $sim
#puts [aix_patch_hypervisor_emu_assist_intr]
#puts [aix_system_console]
