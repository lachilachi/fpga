puts "Initialise project"

set MyProject "pong_complete.xise"

if [ catch { project open $MyProject } ] {
    puts "Project $MyProject not found."
    puts "Created new project [ project new ./$MyProject ] "
}

puts "Setting project properties..."
project set family "Spartan6"
project set device "xc6slx16"
project set package "csg324"
project set speed "-3"
project set top_level_module_type "HDL"
project set synthesis_tool "XST (VHDL/Verilog)"
project set simulator "ISim (VHDL/Verilog)"
project set "Preferred Language" "VHDL"
project set "Enable Message Filtering" "false"

puts "Adding source files..."

# input source files
set files [ list \
		    ../pong_syn.ucf\
		    ../../exercise_6/sync_pulse_generator/sync_pulse_generator.vhd\
		    ../../exercise_7/graphic_buffer/graphic_buffer.vhd\
                    ../../exercise_8/graphic_buffer_controller/graphic_buffer_controller.vhd\
		    ../../exercise_9/graphic_output/graphic_output.vhd\
		    ../../exercise_9/graphic_output/graphic_output_package.vhd\
		    ../../exercise_10/ram_controller/ram_controller.vhd\
   		    ../../exercise_11/event_trigger/event_trigger.vhd\
 		    ../../exercise_11/input_decoder/input_decoder.vhd\
		    ../../exercise_11/random_number_generator/random_number_generator.vhd\
 		    ../ball_movement.vhd\
	            ../paddle_movement.vhd\
		    ../pong_top.vhd\
                    ../reset_circuit.vhd\
		    ../bcd_digit.vhd\
		    ../pixel_clk_generator.vhd\
 	  	    ../position_sample_register.vhd\
		    ../rom_package.vhd\
		    ../game_engine_package.vhd\
		    ../points_display_package.vhd\
		    ../render_buffer.vhd\
		    ../rom.vhd\
		    ../game_engine.vhd\
	            ../points_display.vhd\
		    ../render_engine_controller.vhd\
		    ../game_states.vhd\
		    ../render_engine_package.vhd\
		    ../graphic_engine_package.vhd\
		    ../pong_top_package.vhd\
		    ../render_engine.vhd\
		    ../graphic_engine.vhd\
		    ../renderer.vhd\
	       ]


# add source files with relative path here
foreach filename $files {
    if [catch {xfile add $filename } ]  {
    puts "File $filename already in project"
    } else {
     puts "Adding file $filename to the project"
    }
}

# select toplevel source
project set top "rtl" "pong_top"
puts "Toplevel set. Closing project now."
project close
project open $MyProject
