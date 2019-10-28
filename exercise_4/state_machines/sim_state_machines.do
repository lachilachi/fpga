vlib work

vcom moore_fsm.vhd
vcom mealy_fsm.vhd
# vcom mealy_unreg_fsm.vhd
# vcom mealy_reg_fsm.vhd
vcom state_machines_tb.vhd

vsim -novopt state_machines_tb

add wave sim:/state_machines_tb/clk
add wave sim:/state_machines_tb/reset
add wave -divider inputs
add wave sim:/state_machines_tb/i_a
add wave sim:/state_machines_tb/i_b
add wave -divider output_c
add wave sim:/state_machines_tb/o_c_moore_fsm
add wave sim:/state_machines_tb/o_c_mealy_fsm
# add wave sim:/state_machines_tb/o_c_mealy_reg
add wave -divider output_d
add wave sim:/state_machines_tb/o_d_moore_fsm
add wave sim:/state_machines_tb/o_d_mealy_fsm
# add wave sim:/state_machines_tb/o_d_mealy_reg
add wave -divider state
add wave sim:/uut_moore_fsm/state_fsm
add wave sim:/uut_mealy_fsm/state_fsm
# add wave sim:/uut_mealy_reg_fsm/state_fsm

run -all
