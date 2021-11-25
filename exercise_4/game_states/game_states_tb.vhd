library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity game_states_tb is
end game_states_tb;

architecture beh of game_states_tb is

component game_states
   generic (G_POINTS_TO_WIN : integer := 15);
 
	port (clk : in std_logic := '0';
   		reset : in std_logic := '0';

	      i_serve_key : in std_logic := '0';
	      i_point_player_1 : in std_logic := '0';
	      i_point_player_2 : in std_logic := '0';
	
	      o_ball_free : out std_logic := '0';
	      o_serving_player : out std_logic := '0';
	      o_enable_movement : out std_logic := '0';
	      o_reset_ball_and_paddles : out std_logic := '0';
	      o_player_1_points : out integer range 0 to G_POINTS_TO_WIN := 0;
	      o_player_2_points : out integer range 0 to G_POINTS_TO_WIN := 0);      
end component;

constant C_POINTS_TO_WIN : integer := 6;

signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal i_serve_key : std_logic := '0';
signal i_point_player_1 : std_logic := '0';
signal i_point_player_2 : std_logic := '0';
signal o_ball_free : std_logic := '0';
signal o_serving_player : std_logic := '0';
signal o_enable_movement: std_logic := '0';
signal o_reset_ball_and_paddles : std_logic := '0';
signal o_player_1_points : integer range 0 to C_POINTS_TO_WIN := 0;
signal o_player_2_points : integer range 0 to C_POINTS_TO_WIN := 0;
	--Signals used for simulation
signal stop_simulation : std_logic := '0';
    
begin

   --Instantiate the Unit Under Test (UUT)
   uut_game_states : game_states 
	   port map (clk => clk, 
	             
	             reset => reset,
	             i_serve_key => i_serve_key,
	             i_point_player_1 => i_point_player_1,
	             i_point_player_2 => i_point_player_2,
	             o_ball_free => o_ball_free,
				 o_serving_player => o_serving_player,
	             o_enable_movement => o_enable_movement,
	             o_reset_ball_and_paddles => o_reset_ball_and_paddles,
	             o_player_1_points => o_player_1_points,
	             o_player_2_points => o_player_2_points);


   --Clock
   process
   begin
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
   
   file vector_file : text is in "game_states.vec";
   variable read_line : line;
   variable test_vector : std_logic_vector (1 to 3);        
   
   begin
      if (clk'event and clk = '1') then
         --Read data for inputs from file
         if (not(endfile(vector_file))) then
            readline(vector_file, read_line);
            read(read_line, test_vector);

            i_serve_key <= test_vector(1);
            i_point_player_1 <= test_vector(2);
			i_point_player_2 <= test_vector(3);
         --Set signal to stop the simulation
         else
            stop_simulation <= '1';
         end if;
      end if;
   end process;
   
 --Reset the UUT at start
--   reset <= '1', '0' after 15 ns;

end beh;
