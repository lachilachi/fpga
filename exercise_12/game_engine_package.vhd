library IEEE;
use IEEE.STD_LOGIC_1164.all;

package game_engine_package is
   component game_engine is
      generic (G_H_RESOLUTION : integer := 640;
               G_V_RESOLUTION : integer := 480;
               
               G_PADDLE_EVENT_INTERVAL : integer := 100000;
               G_BALL_EVENT_INTERVAL : integer := 20000;
               
               G_BORDER_THICKNESS : integer := 2;
               G_PADDLE_TO_BORDER_SPACE : integer := 2;
               G_PADDLE_HEIGHT : integer := 91;
               G_PADDLE_WIDTH : integer := 15;
               G_PADDLE_SLOPE_LENGTH : integer := 10;
               G_BALL_DIAMETER : integer := 17;
               
               G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
               G_BALL_X_POS_SIGNAL_RANGE : integer := 604;
               G_BALL_Y_POS_SIGNAL_RANGE : integer := 461;
               
               G_POINTS_TO_WIN : integer := 15);
      
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
            
            i_player_1_up : in std_logic := '0';
            i_player_1_down : in std_logic := '0';
            i_player_2_up : in std_logic := '0';
            i_player_2_down : in std_logic := '0';
            i_serve_key : in std_logic := '0';
            
            o_player_1_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
            o_player_2_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
            o_ball_x_pos : out integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
            o_ball_y_pos : out integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_BALL_DIAMETER / 2;
            o_player_1_points : out integer range 0 to G_POINTS_TO_WIN := 0;
            o_player_2_points : out integer range 0 to G_POINTS_TO_WIN := 0);
   end component; 
   
   component event_trigger is
      generic (G_PADDLE_EVENT_INTERVAL : integer := 100000;
               G_BALL_EVENT_INTERVAL : integer := 20000);
      
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
            
            o_paddle_event : out std_logic := '0';
            o_ball_event : out std_logic := '0');
   end component;

   component random_number_generator is
      port (clk : in std_logic := '0';
            
            o_random_number : out std_logic_vector (5 downto 0) := (others => '1'));
   end component;

   component game_states is
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

   component paddle_movement is
      generic (G_V_RESOLUTION : integer := 480;
               
               G_BORDER_THICKNESS : integer := 2;
               G_PADDLE_HEIGHT : integer := 91;
               G_PLAYER_POS_SIGNAL_RANGE : integer := 387);
   
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
            
            i_paddle_event : in std_logic := '0';
            i_player_1_up : in std_logic := '0';
            i_player_1_down : in std_logic := '0';
            i_player_2_up : in std_logic := '0';
            i_player_2_down : in std_logic := '0';
            
            o_player_1_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
            o_player_2_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2);
   end component;
   
   component ball_movement is
      generic (G_H_RESOLUTION : integer := 640;
               G_V_RESOLUTION : integer := 480;
               
               G_BORDER_THICKNESS : integer := 2;
               G_PADDLE_TO_BORDER_SPACE : integer := 2;
               G_PADDLE_HEIGHT : integer := 91;
               G_PADDLE_WIDTH : integer := 15;
               G_PADDLE_SLOPE_LENGTH : integer := 10;
               G_BALL_DIAMETER : integer := 17;
               
               G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
               G_BALL_X_POS_SIGNAL_RANGE : integer := 619;
               G_BALL_Y_POS_SIGNAL_RANGE : integer := 461);
      
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
            
            i_ball_event : in std_logic := '0';
            i_random_number : in std_logic_vector (5 downto 0) := (others => '0');
            i_ball_free : in std_logic := '0';
            i_serving_player : in std_logic := '0';
            i_player_1_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;
            i_player_2_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;
            i_rom_data : in std_logic_vector (8 downto 0) := (others => '0');
            
            o_point_player_1 : out std_logic := '0';
            o_point_player_2 : out std_logic := '0';
            o_ball_x_pos : out integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
            o_ball_y_pos : out integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_BALL_DIAMETER / 2;
            o_rom_address : out std_logic_vector (8 downto 0) := (others => '0'));
   end component;
   
   component rom is
      port (i_rom_address : in std_logic_vector (8 downto 0) := (others => '0');
            
            o_rom_data : out std_logic_vector (8 downto 0) := (others => '0'));
   end component;
end game_engine_package;
