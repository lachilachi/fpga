set source_path "."
set mem_source_path "./cellram_sim"

vlib work
vmap work work

set vopts "-l log.txt -novopt -t 1ps"

# memory model
vlog +define+sg701 +incdir+$mem_source_path $mem_source_path/cellram.v
vcom -work work -check_synthesis $source_path/ram_controller.vhd
vcom -work work $source_path/ram_controller_tb.vhd

set cmd "vsim $vopts -GMEM_BITS=16 ram_controller_tb"
eval $cmd

add wave -r dut/*
run 152730 ns
