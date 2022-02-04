library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity event_trigger_tb is
end event_trigger_tb;



architecture beh of event_trigger_tb is

--Component Declaration for the Unit Under Test (UUT)
component event_trigger
    generic (G_PADDLE_EVENT_INTERVAL : integer;
            G_BALL_EVENT_INTERVAL : integer);

    port(clk : in std_logic;
        reset : in std_logic;
        
        o_paddle_event : out std_logic;
        o_ball_event : out std_logic);
   
end component;


--Signals to connect the Unit Under Test (UUT)
signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal reset : std_logic := '0';
signal reset : std_logic := '0';

--Signals used for simulation
signal stop_simulation : std_logic := '0';

begin
   --Instantiate the Unit Under Test (UUT)
   uut_graphic_buffer_controller : graphic_buffer_controller
      generic map (G_H_RESOLUTION => 16,
                   G_V_RESOLUTION => 8)
        
      port map (clk => clk,
                reset => reset,
               );


   --Clock
   process   begin
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      clk <= '0';

      --Stop the simulation
      if (stop_simulation = '1') then
         wait;
      end if;
   end process;


   --Read testvector from file
   process(clk)
   
   file vector_file : text is in "graphic_buffer_controller.vec";
   variable read_line : line;
   variable stimulus_vector : std_logic_vector (1 to 4);
   
   begin
      if (rising_edge(clk)) then
         if (not(endfile(vector_file))) then
            readline(vector_file, read_line);
            read(read_line, stimulus_vector);

            i_data_req_reg_0 <= stimulus_vector(1);
            i_data_req_reg_1 <= stimulus_vector(2);
            i_read_done <= stimulus_vector(3);
            i_new_frame_ready <= stimulus_vector(4);
         --Set signal to stop the simulation
         else
            stop_simulation <= '1';
         end if;
      end if;
   end process;

	reset <= '1', '0' after 21 ns;

end beh;
