# create library
vlib work

# compile modules
vcom variable_vs_signal_1.vhd

# setup simulation environment
vsim -novopt variable_vs_signal_1

# stimuli generation
force reset 1 0, 0 65
force clk 1 10, 0 20 -r 20 
force a_in 1111
force b_in 1111


# add to waveform
add wave -divider inputs
add wave -in sim:/variable_vs_signal_1/clk

add wave -divider internal_signals
add wave sim:/variable_vs_signal_1/*

add wave -divider variables
add wave /variable_vs_signal_1/calc/*

add wave -divider outputs
add wave -out sim:/variable_vs_signal_1/*

#undock wave
view -undock wave 

# run simulation
run 0.5us

