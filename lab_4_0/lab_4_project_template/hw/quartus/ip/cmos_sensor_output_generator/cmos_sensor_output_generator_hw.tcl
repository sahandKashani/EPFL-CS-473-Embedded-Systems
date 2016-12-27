package require -exact qsys 15.1


#
# module cmos_sensor_output_generator
#
set_module_property DESCRIPTION "Generates the signals a CMOS sensor would output. This component is useful for testing and simulating a system while waiting for a real CMOS sensor to be ordered and delivered for your various projects."
set_module_property NAME cmos_sensor_output_generator
set_module_property VERSION 15.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Sahand Kashani-Akhavan"
set_module_property DISPLAY_NAME "cmos sensor output generator"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property VALIDATION_CALLBACK validate


proc validate {} {
    set_module_assignment embeddedsw.CMacro.PIX_DEPTH [get_parameter_value PIX_DEPTH]
    set_module_assignment embeddedsw.CMacro.MAX_WIDTH [get_parameter_value MAX_WIDTH]
    set_module_assignment embeddedsw.CMacro.MAX_HEIGHT [get_parameter_value MAX_HEIGHT]
}


#
# file sets
#
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL cmos_sensor_output_generator
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file cmos_sensor_output_generator_constants.vhd VHDL PATH hdl/cmos_sensor_output_generator_constants.vhd
add_fileset_file cmos_sensor_output_generator.vhd VHDL PATH hdl/cmos_sensor_output_generator.vhd TOP_LEVEL_FILE

add_fileset SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL TOP_LEVEL cmos_sensor_output_generator
set_fileset_property SIM_VHDL ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VHDL ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file cmos_sensor_output_generator_constants.vhd VHDL PATH hdl/cmos_sensor_output_generator_constants.vhd
add_fileset_file cmos_sensor_output_generator.vhd VHDL PATH hdl/cmos_sensor_output_generator.vhd


#
# parameters
#
add_parameter PIX_DEPTH POSITIVE 8
set_parameter_property PIX_DEPTH DISPLAY_NAME "Pixel Depth"
set_parameter_property PIX_DEPTH TYPE POSITIVE
set_parameter_property PIX_DEPTH UNITS bits
set_parameter_property PIX_DEPTH ALLOWED_RANGES {1:32}
set_parameter_property PIX_DEPTH DESCRIPTION "Depth of each generated pixel sample"
set_parameter_property PIX_DEPTH HDL_PARAMETER true

add_parameter MAX_WIDTH POSITIVE 1920
set_parameter_property MAX_WIDTH DISPLAY_NAME "Max frame width"
set_parameter_property MAX_WIDTH TYPE POSITIVE
set_parameter_property MAX_WIDTH DESCRIPTION "Max frame width to be outputted by unit"
set_parameter_property MAX_WIDTH HDL_PARAMETER true

add_parameter MAX_HEIGHT POSITIVE 1080
set_parameter_property MAX_HEIGHT DISPLAY_NAME "Max frame height"
set_parameter_property MAX_HEIGHT TYPE POSITIVE
set_parameter_property MAX_HEIGHT DESCRIPTION "Max frame height to be outputted by unit"
set_parameter_property MAX_HEIGHT HDL_PARAMETER true


#
# display items
#


#
# connection point clock
#
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


#
# connection point reset
#
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


#
# connection point avalon_slave
#
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressUnits WORDS
set_interface_property avalon_slave associatedClock clock
set_interface_property avalon_slave associatedReset reset
set_interface_property avalon_slave bitsPerSymbol 8
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave burstcountUnits WORDS
set_interface_property avalon_slave explicitAddressSpan 0
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave maximumPendingWriteTransactions 0
set_interface_property avalon_slave readLatency 0
set_interface_property avalon_slave readWaitTime 1
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0
set_interface_property avalon_slave ENABLED true
set_interface_property avalon_slave EXPORT_OF ""
set_interface_property avalon_slave PORT_NAME_MAP ""
set_interface_property avalon_slave CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave addr address Input 3
add_interface_port avalon_slave read read Input 1
add_interface_port avalon_slave write write Input 1
add_interface_port avalon_slave rddata readdata Output 32
add_interface_port avalon_slave wrdata writedata Input 32
set_interface_assignment avalon_slave embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave embeddedsw.configuration.isPrintableDevice 0


#
# connection point cmos_sensor
#
add_interface cmos_sensor conduit end
set_interface_property cmos_sensor associatedClock ""
set_interface_property cmos_sensor associatedReset ""
set_interface_property cmos_sensor ENABLED true
set_interface_property cmos_sensor EXPORT_OF ""
set_interface_property cmos_sensor PORT_NAME_MAP ""
set_interface_property cmos_sensor CMSIS_SVD_VARIABLES ""
set_interface_property cmos_sensor SVD_ADDRESS_GROUP ""

add_interface_port cmos_sensor frame_valid frame_valid Output 1
add_interface_port cmos_sensor line_valid line_valid Output 1
add_interface_port cmos_sensor data data Output pix_depth
