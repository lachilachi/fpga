vlib work

vcom sync_pulse_generator.vhd
vcom sync_pulse_generator_small_tb.vhd

vsim -novopt sync_pulse_generator_small_tb

log /* -r

add wave -divider inputs_of_uut
add wave -in sim:/uut_sync_pulse_generator/*
add wave -divider internal_signals_of_uut
add wave -internal sim:/uut_sync_pulse_generator/*

add wave -divider difference_signal
add wave sim:/sync_pulse_generator_small_tb/difference

add wave -divider o_h_sync
add wave -out sim:/uut_sync_pulse_generator/o_h_sync
add wave sim:/sync_pulse_generator_small_tb/o_h_sync_correct

add wave -divider o_v_sync
add wave -out sim:/uut_sync_pulse_generator/o_v_sync
add wave sim:/sync_pulse_generator_small_tb/o_v_sync_correct

add wave -divider o_in_active_region
add wave -out sim:/uut_sync_pulse_generator/o_in_active_region
add wave sim:/sync_pulse_generator_small_tb/o_in_active_region_correct

run -all
