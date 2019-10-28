library IEEE;
use IEEE.STD_LOGIC_1164.all;

package render_engine_package is
   component render_engine is
      generic (G_H_RESOLUTION : integer := 640;
               G_V_RESOLUTION : integer := 480;
               
               G_BORDER_THICKNESS : integer := 2;
               G_PADDLE_TO_BORDER_SPACE : integer := 2;
               G_PADDLE_HEIGHT : integer := 91;
               G_PADDLE_WIDTH : integer := 15;
               G_BALL_DIAMETER : integer := 17;
               
               G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
               G_BALL_X_POS_SIGNAL_RANGE : integer := 604;
               G_BALL_Y_POS_SIGNAL_RANGE : integer := 461);
      
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
            
            i_page_switched : in std_logic := '0';
            i_write_done : in std_logic := '0';
            i_player_1_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
            i_player_2_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
            i_ball_x_pos : in integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
            i_ball_y_pos : in integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;
            
            o_write_req : out std_logic := '0';
            o_write_address : out std_logic_vector (22 downto 0) := (others => '0');
            o_write_data : out std_logic_vector (32*8-1 downto 0) := (others => '0');
            o_new_frame_ready : out std_logic := '0');
   end component;

   component render_engine_controller is
      generic (G_H_RESOLUTION : integer := 640;
               G_V_RESOLUTION : integer := 480);
      
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
            
            i_buffer_full : in std_logic := '0';
            i_write_done : in std_logic := '0';
            i_page_switched : in std_logic := '0';
                  
            o_sample_positions : out std_logic := '0';
            o_create_new_data : out std_logic := '0';
            o_write_req : out std_logic := '0';
            o_write_address : out std_logic_vector (22 downto 0) := (others => '0');
            o_new_frame_ready : out std_logic := '0');
   end component;

   component position_sample_register is
      generic (G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
               G_BALL_X_POS_SIGNAL_RANGE : integer := 604;
               G_BALL_Y_POS_SIGNAL_RANGE : integer := 461);
      
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
            
            i_sample_positions : in std_logic := '0';
            i_player_1_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := 0;
            i_player_2_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := 0;
            i_ball_x_pos : in integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := 0;
            i_ball_y_pos : in integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := 0;
            
            o_player_1_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := 0;
            o_player_2_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := 0;
            o_ball_x_pos : out integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := 0;
            o_ball_y_pos : out integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := 0);
   end component;
   
   component renderer is
      generic (G_H_RESOLUTION : integer := 640;
               G_V_RESOLUTION : integer := 480;
               
               G_BORDER_THICKNESS : integer := 2;
               G_PADDLE_TO_BORDER_SPACE : integer := 2;
               G_PADDLE_HEIGHT : integer := 91;
               G_PADDLE_WIDTH : integer := 15;
               G_BALL_DIAMETER : integer := 17;
               
               G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
               G_BALL_X_POS_SIGNAL_RANGE : integer := 619;
               G_BALL_Y_POS_SIGNAL_RANGE : integer := 461);
               
      port (clk : in std_logic;
            reset : in std_logic;
            
            i_render_enable : in std_logic := '0';
            i_player_1_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
            i_player_2_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
            i_ball_x_pos : in integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
            i_ball_y_pos : in integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;
            
            o_buffer_shift_enable : out std_logic := '0';
            o_rgb : out std_logic_vector (7 downto 0));
   end component;

   component render_buffer is
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
            
            i_shift_enable : in std_logic := '0';
            i_rgb : in std_logic_vector (7 downto 0) := (others => '0');
            
            o_buffer_full : out std_logic := '1';
            o_rgb_data : out std_logic_vector (32*8-1 downto 0) := (others => '0'));
   end component;

end render_engine_package;
