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
	
signal stop_simulation : std_logic := '0';
    
begin

  

end beh;
