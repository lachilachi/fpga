vlib work
vmap work work

vcom graphic_buffer.vhd
vcom graphic_buffer_tb.vhd

vsim -novopt graphic_buffer_tb

add wave -divider inputs_of_uut
add wave -radix unsigned -in sim:/uut_graphic_buffer/*
add wave -divider outputs_of_uut
add wave -radix unsigned -out sim:/uut_graphic_buffer/*
add wave -divider internal_signals_of_uut
add wave -radix unsigned -internal sim:/uut_graphic_buffer/*

run -all
