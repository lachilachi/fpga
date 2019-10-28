vlib work
vmap work work

vcom graphic_buffer_controller.vhd
vcom graphic_buffer_controller_tb.vhd

vsim -novopt graphic_buffer_controller_tb

add wave -divider inputs_of_uut
add wave -in -radix hexadecimal sim:/uut_graphic_buffer_controller/*
add wave -divider outputs_of_uut
add wave -out -radix hexadecimal sim:/uut_graphic_buffer_controller/*
add wave -divider internal_signals_of_uut
add wave -internal -radix hexadecimal sim:/uut_graphic_buffer_controller/*

run -all
