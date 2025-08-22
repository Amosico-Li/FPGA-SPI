# @Author: litianhao
# @Env: Modelsim SE-64 2020.4
# @Test File: spi_slave.sv

# add wave color set:<grey50, grey80, white, gold, orange, red, brown, pink, green, cyan, blue, aquamarine, orchid, magenta, violet, plum>
# add wave radix set<>symbolic, binary, octal, hexadecimal, decimal, unsigned, ascii, time>
# read modelsim command refernce for more commands and options

alias pvlog "vlog -work work +acc"

# Define
radix define spi_fsm {
    3'h1 "IDLE",
    3'h2 "ALIGN",
    3'h4 "TRANS",
    -default hex
} 

# Step 1: reset 
.main clear
quit -sim


# Step 2: new lib 
vlib work
vmap work work


# Step 3: load design and set vopt 
pvlog "../../spi_master/spi_master_debug.sv"
pvlog "../spi_slave_debug.sv"
# pvlog "../spi_slave_faster.sv"
pvlog "../../cbb/edge_detector/edge_detector.sv"
pvlog "./tb.sv"


vopt work.tb -O0 -o debug


# Step 4: sim design 
vsim debug -fsmdebug


# Step 5: add wave 
# System
add wave -color green  -group System -label clk                                tb/clk
add wave -color green  -group System -label rst_n                              tb/rst_n
add wave -color green  -group System -label start                              tb/start
add wave -color green  -group System -label m_wdata                            tb/m_wdata
add wave -color green  -group System -label s_wdata                            tb/s_wdata
   
# SPI interface   
add wave -color white  -group SPI_IF -label sclk                               tb/sclk
add wave -color grey50 -group SPI_IF -label nss                                tb/nss
add wave -color plum   -group SPI_IF -label mosi                               tb/mosi
add wave -color plum   -group SPI_IF -label miso                               tb/miso
add wave -color gold   -group SPI_IF -label m_done                             tb/m_done
add wave -color gold   -group SPI_IF -label s_done                             tb/s_done
   
# Data   
add wave -color green  -group Data -label m_rdata                              tb/m_rdata
add wave -color green  -group Data -label s_rdata                              tb/s_rdata

# Master
add wave -color green  -group Master_Inner -label start_en                     tb/spi_master_inst/start_en
add wave -color pink   -group Master_Inner -label edge_1                       tb/spi_master_inst/edge_1
add wave -color pink   -group Master_Inner -label edge_2                       tb/spi_master_inst/edge_2
add wave -color gold   -group Master_Inner -label rd_edge                      tb/spi_master_inst/rd_edge
add wave -color blue   -group Master_Inner -label wr_edge                      tb/spi_master_inst/wr_edge
add wave -color brown  -group Master_Inner -label bcnt       -radix Unsigned   tb/spi_master_inst/bcnt
add wave -color gold   -group Master_Inner -label rdata_tmp                    tb/spi_master_inst/rdata_tmp
add wave -color blue   -group Master_Inner -label wdata_tmp                    tb/spi_master_inst/wdata_tmp
add wave -color green  -group Master_Inner -radix spi_fsm    -label state      tb/spi_master_inst/state

# Slave
# spi_slave.sv
add wave -color grey50 -group Slave_Inner -label nss_dly                       tb/spi_slave_inst/nss_dly
add wave -color green  -group Slave_Inner -label sclk_dly                      tb/spi_slave_inst/sclk_dly
add wave -color brown  -group Slave_Inner -label mosi_dly                      tb/spi_slave_inst/mosi_dly
add wave -color white  -group Slave_Inner -label sclk_pe                       tb/spi_slave_inst/sclk_pe
add wave -color white  -group Slave_Inner -label sclk_ne                       tb/spi_slave_inst/sclk_ne
add wave -color blue   -group Slave_Inner -label rd_edge                       tb/spi_slave_inst/rd_edge
add wave -color brown  -group Slave_Inner -label edge_1                        tb/spi_slave_inst/edge_1
add wave -color brown  -group Slave_Inner -label edge_2                        tb/spi_slave_inst/edge_2
add wave -color brown  -group Slave_Inner -label bcnt        -radix Unsigned   tb/spi_slave_inst/bcnt
add wave -color red    -group Slave_Inner -label start_en                      tb/spi_slave_inst/start_en
add wave -color red    -group Slave_Inner -label stop                          tb/spi_slave_inst/stop
add wave -color pink   -group Slave_Inner -label done                          tb/spi_slave_inst/done
add wave -color grey50 -group Slave_Inner -label nss_dly[1]                    tb/spi_slave_inst/nss_dly[1]
add wave -color green  -group Slave_Inner -label sclk_dly[1]                   tb/spi_slave_inst/sclk_dly[1]
add wave -color brown  -group Slave_Inner -label mosi_dly[1]                   tb/spi_slave_inst/mosi_dly[1] 
add wave -color white  -group Slave_Inner -label load                          tb/spi_slave_inst/load
add wave -color grey50 -group Slave_Inner -label state       -radix spi_fsm    tb/spi_slave_inst/state
add wave -color grey80 -group Slave_Inner -label rdata_tmp                     tb/spi_slave_inst/rdata_tmp
add wave -color grey80 -group Slave_Inner -label wdata_tmp                     tb/spi_slave_inst/wdata_tmp

# Step 6: show ui 
view wave 


# Step 7: run 
run 50us
wave zoom full