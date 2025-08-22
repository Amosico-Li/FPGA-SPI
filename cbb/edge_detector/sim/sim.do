# @Author: litianhao
# @Env: Modelsim SE-64 2020.4
# @Test File: edge_detector.sv

# add wave color set:<grey50, grey80, white, gold, orange, red, brown, pink, green, cyan, blue, aquamarine, orchid, magenta, violet, plum>
# add wave radix set<>symbolic, binary, octal, hexadecimal, decimal, unsigned, ascii, time>
# read modelsim command refernce for more commands and options

# Step 1: reset 
.main clear
quit -sim

# Step 2: new lib 
vlib work
vmap work work

# Step 3: load design and set vopt 
vlog -work work +acc "../edge_detector.sv"
vlog -work work +acc "./tb.sv"

vopt work.tb -O0 -o debug

# Step 4: sim design 
vsim debug -fsmdebug

# Step 5: add wave 
add wave -color green -group sys -label clk  tb/clk
add wave -color green -group sys -label rst_n  tb/rst_n
add wave -color green -group sys -label s_i  tb/s_i

add wave -color grey50 -group posedge_dete -label signal_dly  tb/uut_0/signal_dly
add wave -color grey50 -group posedge_dete -label p_o_0   tb/p_o_0
add wave -color red -group negedge_dete -label signal_dly   tb/uut_1/signal_dly
add wave -color red -group negedge_dete -label p_o_1   tb/p_o_1

# Step 6: show ui 
view wave 

# Step 7: run 
run 5000ns
wave zoom full