vlib work

vcom reg.vhd
vcom reg_tb.vhd

vsim -novopt reg_tb

add wave sim:/reg_tb/clk
add wave sim:/reg_tb/reset
add wave -divider inputs
add wave sim:/reg_tb/i_d
add wave -divider output
add wave sim:/reg_tb/o_q

run -all
