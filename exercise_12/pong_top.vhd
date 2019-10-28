library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pong_top_package.ALL;

entity pong_top is
   --generics:
   --G_PLAYER_1_UP               : \
   --G_PLAYER_1_DOWN             : |
   --G_PLAYER_2_UP               : | scancodes for the keyboard keys used to
   --G_PLAYER_2_DOWN             : | control the game
   --G_SERVE_KEY                 : |
   --G_RESET_KEY                 : /
   --
   --G_H_PIXEL_NUMBER            : horizontal pixel number (incl. non visible)
   --G_H_RESOLUTION              : horizontal resolution
   --G_H_FRONT_PORCH             : horizontal front porch length in pixels
   --G_H_BACK_PORCH              : horizontal back porch length in pixels
   --G_H_SYNC_LENGTH             : horizontal sync pulse length in pixels
   --G_H_SYNC_ACTIVE             : horizontal sync pulse polarity 
   --                              (1 = pos, 0 = neg)
   -- 
   --G_V_PIXEL_NUMBER            : vertical pixel number (incl. non visible)
   --G_V_RESOLUTION              : vertical resolution
   --G_V_FRONT_PORCH             : vertical front porch length in pixels
   --G_V_BACK_PORCH              : vertical front porch length in pixels
   --G_V_SYNC_LENGTH             : vertical sync pulse length in pixels
   --G_V_SYNC_ACTIVE             : vertical sync pulse polarity 
   --                              (1 = pos, 0 = neg)
   --
   --G_PADDLE_EVENT_INTERVAL     : clock cycles between two paddle events
   --G_BALL_EVENT_INTERVAL       : clock cycles between two ball events
   --
   --G_BORDER_THICKNESS          : thickness of the border around the playing 
   --                              field
   --G_PADDLE_TO_BORDER_SPACE    : space between paddle and border
   --G_PADDLE_HEIGHT             : height of the paddles
   --G_PADDLE_WIDTH              : width of the paddles
   --G_PADDLE_SLOPE_LENGTH       : size of the slope on the paddle corners
   --G_BALL_DIAMETER             : diameter of the ball
   --
   --G_POINTS_TO_WIN             : points needed to win the game
   --
   --G_EXTERNAL_PIXEL_CLK_SELECT : 
   --G_CLK_DIVIDER               : 
   generic (G_PLAYER_1_UP : std_logic_vector (10 downto 0) := "10000111000";     --a key
            G_PLAYER_1_DOWN : std_logic_vector (10 downto 0) := "10000110100";   --y key
            G_PLAYER_2_UP : std_logic_vector (10 downto 0) := "11010000100";     --k key
            G_PLAYER_2_DOWN : std_logic_vector (10 downto 0) := "11001110100";   --m key
            G_SERVE_KEY : std_logic_vector (10 downto 0) := "10001010010";       --space key
            G_RESET_KEY : std_logic_vector (10 downto 0) := "10011101100";       --esc key
            
            G_H_PIXEL_NUMBER : integer := 800;
            G_H_RESOLUTION : integer := 640;
            G_H_FRONT_PORCH : integer := 8;
            G_H_BACK_PORCH : integer := 48;
            G_H_SYNC_LENGTH : integer := 96;
            G_H_SYNC_ACTIVE : std_logic := '0';
             
            G_V_PIXEL_NUMBER : integer := 525;
            G_V_RESOLUTION : integer := 480;
            G_V_FRONT_PORCH : integer := 2;
            G_V_BACK_PORCH : integer := 33;
            G_V_SYNC_LENGTH : integer := 2;
            G_V_SYNC_ACTIVE : std_logic := '0';
            
            G_PADDLE_EVENT_INTERVAL : integer := 200000;
            G_BALL_EVENT_INTERVAL : integer := 40000; --20000
            
            G_BORDER_THICKNESS : integer := 2;
            G_PADDLE_TO_BORDER_SPACE : integer := 2;
            G_PADDLE_HEIGHT : integer := 91;
            G_PADDLE_WIDTH : integer := 15;
            G_PADDLE_SLOPE_LENGTH : integer := 20;  --10
            G_BALL_DIAMETER : integer := 17;
            
            G_POINTS_TO_WIN : integer := 15);
   
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_ps2_clk : in std_logic := '0';
         i_ps2_data : in std_logic := '0';
         
        -- ram interface
        io_ram_dq     : inout std_logic_vector (15 downto 0) := (others => 'Z');
        o_ram_address : out   std_logic_vector (23 downto 1) := (others => '0');
        o_ram_clk     : out   std_logic                      := '0';
        o_ram_adv_neg : out   std_logic                      := '1';
        o_ram_cre     : out   std_logic                      := '0';
        o_ram_ce_neg  : out   std_logic                      := '1';
        o_ram_oe_neg  : out   std_logic                      := '1';
        o_ram_we_neg  : out   std_logic                      := '1';
        o_ram_ub_neg  : out   std_logic                      := '1';
        o_ram_lb_neg  : out   std_logic                      := '1';
         
         o_h_sync : out std_logic := '0';
         o_v_sync : out std_logic := '0';
         o_red : out std_logic_vector(2 downto 0) := "000";
         o_green : out std_logic_vector(2 downto 0) := "000";
         o_blue : out std_logic_vector(1 downto 0) := "00";
         
         o_anodes : out std_logic_vector (3 downto 0) := "1000";
         o_cathodes : out std_logic_vector (7 downto 0) := (others => '1');
         
         o_player_1_up : out std_logic := '0';
         o_player_1_down : out std_logic := '0';
         o_player_2_up : out std_logic := '0';
         o_player_2_down : out std_logic := '0';
         o_serve : out std_logic := '0';
         o_reset_key : out std_logic := '0');
end pong_top;



architecture rtl of pong_top is

constant C_PLAYER_POS_SIGNAL_RANGE : integer := G_V_RESOLUTION - G_PADDLE_HEIGHT - G_BORDER_THICKNESS;
constant C_BALL_X_POS_SIGNAL_RANGE : integer := G_H_RESOLUTION - G_BORDER_THICKNESS - G_PADDLE_TO_BORDER_SPACE - G_PADDLE_WIDTH - G_BALL_DIAMETER;
constant C_BALL_Y_POS_SIGNAL_RANGE : integer := G_V_RESOLUTION - G_BORDER_THICKNESS - G_BALL_DIAMETER;

signal reset_sig : std_logic := '0';
signal reset_game_engine_sig : std_logic := '0';

signal player_1_up_sig : std_logic := '0';
signal player_1_down_sig : std_logic := '0';
signal player_2_up_sig : std_logic := '0';
signal player_2_down_sig : std_logic := '0';
signal serve_key_sig : std_logic := '0';
signal reset_key_sig : std_logic := '0';

signal player_1_pos_sig : integer range 0 to C_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
signal player_2_pos_sig : integer range 0 to C_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
signal ball_x_pos_sig : integer range 0 to C_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
signal ball_y_pos_sig : integer range 0 to C_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_BALL_DIAMETER / 2;

signal player_1_points_sig : integer range 0 to G_POINTS_TO_WIN := 0;
signal player_2_points_sig : integer range 0 to G_POINTS_TO_WIN := 0;

begin
   input_decoder_inst : input_decoder
      generic map (G_PLAYER_1_UP,
                   G_PLAYER_1_DOWN,
                   G_PLAYER_2_UP,
                   G_PLAYER_2_DOWN,
                   G_SERVE_KEY,
                   G_RESET_KEY)
                   
      port map (clk => clk,
                reset => reset_sig,
                
                i_ps2_clk => i_ps2_clk,
                i_ps2_data => i_ps2_data,
                
                o_player_1_up => player_1_up_sig,
                o_player_1_down => player_1_down_sig,
                o_player_2_up => player_2_up_sig,
                o_player_2_down => player_2_down_sig,
                o_serve_key => serve_key_sig,
                o_reset_key => reset_key_sig);
                
   game_engine_inst : game_engine
      generic map (G_H_RESOLUTION,
                   G_V_RESOLUTION,
                   
                   G_PADDLE_EVENT_INTERVAL,
                   G_BALL_EVENT_INTERVAL,
                   
                   G_BORDER_THICKNESS,
                   G_PADDLE_TO_BORDER_SPACE,
                   G_PADDLE_HEIGHT,
                   G_PADDLE_WIDTH,
                   G_PADDLE_SLOPE_LENGTH,
                   G_BALL_DIAMETER,
                   
                   C_PLAYER_POS_SIGNAL_RANGE,
                   C_BALL_X_POS_SIGNAL_RANGE,
                   C_BALL_Y_POS_SIGNAL_RANGE)
                   
      port map (clk => clk,
                reset => reset_game_engine_sig,
                
                i_player_1_up => player_1_up_sig,
                i_player_1_down  => player_1_down_sig,
                i_player_2_up => player_2_up_sig,
                i_player_2_down => player_2_down_sig,
                i_serve_key => serve_key_sig,
                
                o_player_1_pos => player_1_pos_sig,
                o_player_2_pos => player_2_pos_sig,
                o_ball_x_pos => ball_x_pos_sig,
                o_ball_y_pos => ball_y_pos_sig,
                o_player_1_points => player_1_points_sig,
                o_player_2_points => player_2_points_sig);
                
   points_display_inst : points_display
      generic map (G_POINTS_TO_WIN)
      
      port map (clk => clk,
                reset => reset,
               
               i_player_1_points => player_1_points_sig,
               i_player_2_points => player_2_points_sig,
               
               o_anodes => o_anodes,
               o_cathodes => o_cathodes);
                
   graphic_engine_inst : graphic_engine
      generic map (G_H_PIXEL_NUMBER,
                   G_H_RESOLUTION,
                   G_H_FRONT_PORCH,
                   G_H_BACK_PORCH,
                   G_H_SYNC_LENGTH,
                   G_H_SYNC_ACTIVE,
                   
                   G_V_PIXEL_NUMBER,
                   G_V_RESOLUTION,
                   G_V_FRONT_PORCH,
                   G_V_BACK_PORCH,
                   G_V_SYNC_LENGTH,
                   G_V_SYNC_ACTIVE,
                   
                   G_BORDER_THICKNESS,
                   G_PADDLE_TO_BORDER_SPACE,
                   G_PADDLE_HEIGHT,
                   G_PADDLE_WIDTH,
                   G_BALL_DIAMETER,
                   
                   C_PLAYER_POS_SIGNAL_RANGE,
                   C_BALL_X_POS_SIGNAL_RANGE,
                   C_BALL_Y_POS_SIGNAL_RANGE)
                   
      port map (clk => clk,
                reset => reset_sig,
                
                i_player_1_pos => player_1_pos_sig,
                i_player_2_pos => player_2_pos_sig,
                i_ball_x_pos => ball_x_pos_sig,
                i_ball_y_pos => ball_y_pos_sig,              
                
       io_ram_dq       => io_ram_dq,
      o_ram_address   => o_ram_address,
      o_ram_clk       => o_ram_clk,
      o_ram_adv_neg   => o_ram_adv_neg,
      o_ram_cre       => o_ram_cre,
      o_ram_ce_neg    => o_ram_ce_neg,
      o_ram_oe_neg    => o_ram_oe_neg,
      o_ram_we_neg    => o_ram_we_neg,
      o_ram_ub_neg    => o_ram_ub_neg,
      o_ram_lb_neg    => o_ram_lb_neg,
 
                o_h_sync => o_h_sync,
                o_v_sync => o_v_sync,
                o_red => o_red,
                o_green => o_green,
                o_blue => o_blue);
   
   reset_circuit_inst : reset_circuit
      port map (clk => clk,
                
                i_reset => reset,
                
                o_reset => reset_sig);
   
   reset_game_engine_sig <= reset_sig or reset_key_sig;
   
   o_player_1_up <= player_1_up_sig;
   o_player_1_down <= player_1_down_sig;
   o_player_2_up <= player_2_up_sig;
   o_player_2_down <= player_2_down_sig;
   o_serve <= serve_key_sig;
   o_reset_key <= reset_key_sig;
end rtl;

