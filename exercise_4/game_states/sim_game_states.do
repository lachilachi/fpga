vcom game_states.vhd
vcom game_states_tb.vhd

vsim -novopt game_states_tb

add wave -divider inputs_of_uut
add wave -in sim:/uut_game_states/*
add wave -divider outputs_of_uut
add wave -out sim:/uut_game_states/*
add wave -divider internal_signals_of_uut
add wave -internal sim:/uut_game_states/*

run -all
