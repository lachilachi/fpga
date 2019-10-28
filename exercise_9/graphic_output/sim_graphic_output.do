vlib work

vcom ../../exercise_6/sync_pulse_generator/sync_pulse_generator.vhd
vcom ../../exercise_7/graphic_buffer/graphic_buffer.vhd
vcom ../../exercise_8/graphic_buffer_controller/graphic_buffer_controller.vhd

vcom graphic_output_package.vhd
vcom graphic_output.vhd
vcom graphic_output_tb.vhd

vsim -novopt graphic_output_tb

add wave -divider control_inputs_of_uut
add wave -in sim:/uut_graphic_output/clk
add wave -in sim:/uut_graphic_output/reset
add wave -in sim:/uut_graphic_output/i_read_done
add wave -in sim:/uut_graphic_output/i_new_frame_ready

add wave -divider control_outputs_of_uut
add wave -out sim:/uut_graphic_output/o_read_req
add wave -out -radix hexadecimal sim:/uut_graphic_output/o_read_address
add wave -out sim:/uut_graphic_output/o_page_switched

add wave -divider data_inputs_of_uut
add wave -in  -radix hexadecimal sim:/uut_graphic_output/i_read_data

add wave -divider data_outputs_of_uut
add wave -out sim:/uut_graphic_output/o_red
add wave -out sim:/uut_graphic_output/o_green
add wave -out sim:/uut_graphic_output/o_blue


add wave -divider internal_signals_of_uut

#add wave -out sim:/uut_graphic_output/*



add wave -internal  -radix hexadecimal sim:/uut_graphic_output/*




#run -all
run 20 us
