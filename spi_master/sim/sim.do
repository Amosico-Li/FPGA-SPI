# @Author: litianhao
# @Env: Modelsim SE-64 2020.4
# @Test File: spi_master.sv

# add wave color set:<grey50, grey80, white, gold, orange, red, brown, pink, green, cyan, blue, aquamarine, orchid, magenta, violet, plum>
# add wave radix set<>symbolic, binary, octal, hexadecimal, decimal, unsigned, ascii, time>
# read modelsim command refernce for more commands and options

# Coverage Test
# A - Statement coverage
# B - Branch coverage
# C - Condition coverage
# D - Expression coverage
# E - Toggle coverage
# F - FSM coverage
# G - SystemVerilog class coverage

# Define
radix define spi_fsm {
    3'h1 "IDLE",
    3'h2 "ALIGN",
    3'h4 "TRANS",
    -default hex
} 

alias pvlog "vlog -work work +acc"

# Step 1: reset 
.main clear
quit -sim


# Step 2: new lib 
vlib work
vmap work work


# Step 3: load design and set vopt 
pvlog "../spi_master_debug.sv" +cover=bcesxf
pvlog "../../cbb/edge_detector/edge_detector.sv"
pvlog "./tb.sv"
vopt work.tb -O0 -o debug


# Step 4: sim design 
vsim debug -fsmdebug -coverage


# Step 5: add wave 
# Driving Signals
add wave -color green -group Driving_Source -label clk               tb/clk
add wave -color green -group Driving_Source -label rst_n             tb/rst_n
add wave -color brown -group Driving_Source -label start             tb/start
add wave -color gold  -group Driving_Source -label miso              tb/miso
add wave -color blue  -group Driving_Source -label wdata             tb/wdata

# Output Signals
add wave -color grey50 -group Output_Signals -label nss              tb/nss
add wave -color white  -group Output_Signals -label sclk             tb/sclk
add wave -color gold   -group Output_Signals -label rdata            tb/rdata
add wave -color blue   -group Output_Signals -label mosi             tb/mosi
add wave -color grey50 -group Output_Signals -label done             tb/done

# Inner Signals
add wave -color green  -group Inner -label start_en                  tb/spi_master_inst/start_en
add wave -color grey50 -group Inner -label stop                      tb/spi_master_inst/stop
add wave -color pink   -group Inner -label edge_1                    tb/spi_master_inst/edge_1
add wave -color pink   -group Inner -label edge_2                    tb/spi_master_inst/edge_2
add wave -color gold   -group Inner -label rd_edge                   tb/spi_master_inst/rd_edge
add wave -color blue   -group Inner -label wr_edge                   tb/spi_master_inst/wr_edge
add wave -color brown  -group Inner -label bcnt      -radix Unsigned tb/spi_master_inst/bcnt
add wave -color gold   -group Inner -label rdata_tmp                 tb/spi_master_inst/rdata_tmp
add wave -color blue   -group Inner -label wdata_tmp                 tb/spi_master_inst/wdata_tmp
add wave -color green  -group Inner -radix spi_fsm   -label state    tb/spi_master_inst/state


# Step 6: show ui 
view wave 


# Step 7: run 
run 100us
wave zoom full

coverage report -details -file coverage_report.txt