## Generated SDC file "my_project.sdc"

## Copyright (C) 2023  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 22.1std.2 Build 922 07/20/2023 SC Lite Edition"

## DATE    "Sun May 25 22:16:44 2025"

##
## DEVICE  "10CL006YU256C8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {master_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk_50}]
create_generated_clock -multiply_by 12 -divide_by 5 -source [get_ports {clk_50}] -name sysclk

derive_pll_clocks
# create_generated_clock -name iock -source [get_ports {clk_50}] [get_nets {u0|altpll_component|auto_generated|wire_pll1_clk[0]}]
# create_generated_clock -name iock -source [get_ports {clk_50}] [get_pins {u0|altpll_component|auto_generated|pll1|clk[0]}]
#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************
#set_input_delay -add_delay -max -clock [get_clocks {u0|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {reset_n}]
#set_input_delay -add_delay -min -clock [get_clocks {u0|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {reset_n}]
#set_input_delay -add_delay -max -clock [get_clocks {u0|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {sw_i}]
#set_input_delay -add_delay -min -clock [get_clocks {u0|altpll_component|auto_generated|pll1|clk[0]}]  0.000 [get_ports {sw_i}]

# Constrain the TDI port
set_input_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tdi]
# Constrain the TMS port
set_input_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tms]


# set_input_delay -add_delay -max -clock [get_clocks {iock}] 0.000 [get_ports {rx}]
# set_input_delay -add_delay -min -clock [get_clocks {iock}] 0.000 [get_ports {rx}]


#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -add_delay -max -clock [get_clocks {sysclk}] 1.000 [get_ports {led_o}]
set_output_delay -add_delay -min -clock [get_clocks {sysclk}] 0.000 [get_ports {led_o}]

set_output_delay -add_delay -max -clock [get_clocks {sysclk}] 1.000 [get_ports {tx_o}]
set_output_delay -add_delay -min -clock [get_clocks {sysclk}] 0.000 [get_ports {tx_o}]

# Constrain the TDO port
set_output_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tdo]

#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -asynchronous -group [get_clocks altera_reserved_tck]



#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_ports {reset_n}]
set_false_path -from [get_ports {sw_i}]
set_false_path -from [get_ports {rx_i}]

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

