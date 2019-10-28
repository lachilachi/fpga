library IEEE;
use IEEE.STD_LOGIC_1164.all;

package pong_top_package is
  component pong_top is
    generic (G_PLAYER_1_UP   : std_logic_vector (10 downto 0) := "10000111000";  --a key
             G_PLAYER_1_DOWN : std_logic_vector (10 downto 0) := "10000110100";  --y key
             G_PLAYER_2_UP   : std_logic_vector (10 downto 0) := "11010000100";  --k key
             G_PLAYER_2_DOWN : std_logic_vector (10 downto 0) := "11001110100";  --m key
             G_SERVE_KEY     : std_logic_vector (10 downto 0) := "10001010010";  --space key
             G_RESET_KEY     : std_logic_vector (10 downto 0) := "10011101100";  --esc key

             G_H_PIXEL_NUMBER : integer   := 800;
             G_H_RESOLUTION   : integer   := 640;
             G_H_FRONT_PORCH  : integer   := 8;
             G_H_BACK_PORCH   : integer   := 48;
             G_H_SYNC_LENGTH  : integer   := 96;
             G_H_SYNC_ACTIVE  : std_logic := '0';

             G_V_PIXEL_NUMBER : integer   := 525;
             G_V_RESOLUTION   : integer   := 480;
             G_V_FRONT_PORCH  : integer   := 2;
             G_V_BACK_PORCH   : integer   := 33;
             G_V_SYNC_LENGTH  : integer   := 2;
             G_V_SYNC_ACTIVE  : std_logic := '0';

             G_PADDLE_EVENT_INTERVAL : integer := 100000;
             G_BALL_EVENT_INTERVAL   : integer := 20000;  --20000

             G_BORDER_THICKNESS       : integer := 2;
             G_PADDLE_TO_BORDER_SPACE : integer := 2;
             G_PADDLE_HEIGHT          : integer := 91;
             G_PADDLE_WIDTH           : integer := 15;
             G_PADDLE_SLOPE_LENGTH    : integer := 20;  --10
             G_BALL_DIAMETER          : integer := 17;

             G_POINTS_TO_WIN : integer := 15);

    port (clk   : in std_logic := '0';
          reset : in std_logic := '0';

          i_ps2_clk   : in std_logic := '0';
          i_ps2_data  : in std_logic := '0';

        -- ram interface
        io_ram_dq     : inout std_logic_vector (15 downto 0) := (others => 'Z');
        o_ram_address : out   std_logic_vector (22 downto 0) := (others => '0');
        o_ram_clk     : out   std_logic                      := '0';
        o_ram_adv_neg : out   std_logic                      := '1';
        o_ram_cre     : out   std_logic                      := '0';
        o_ram_ce_neg  : out   std_logic                      := '1';
        o_ram_oe_neg  : out   std_logic                      := '1';
        o_ram_we_neg  : out   std_logic                      := '1';
        o_ram_ub_neg  : out   std_logic                      := '1';
        o_ram_lb_neg  : out   std_logic                      := '1';
		  
          o_h_sync : out std_logic                    := '0';
          o_v_sync : out std_logic                    := '0';
          o_red    : out std_logic_vector(2 downto 0) := "000";
          o_green  : out std_logic_vector(2 downto 0) := "000";
          o_blue   : out std_logic_vector(1 downto 0) := "00";

          o_anodes   : out std_logic_vector (3 downto 0) := "1000";
          o_cathodes : out std_logic_vector (7 downto 0) := (others => '1');

          o_player_1_up   : out std_logic := '0';
          o_player_1_down : out std_logic := '0';
          o_player_2_up   : out std_logic := '0';
          o_player_2_down : out std_logic := '0';
          o_serve         : out std_logic := '0';
          o_reset_key     : out std_logic := '0');
  end component;

  component reset_circuit is
    port (clk : in std_logic := '0';

          i_reset : in std_logic := '0';

          o_reset : out std_logic := '0');
  end component;

  component input_decoder is
    generic (G_PLAYER_1_UP   : std_logic_vector (10 downto 0) := "10000111000";   --a key
             G_PLAYER_1_DOWN : std_logic_vector (10 downto 0) := "10000110100";   --y key
             G_PLAYER_2_UP   : std_logic_vector (10 downto 0) := "11010000100";   --k key
             G_PLAYER_2_DOWN : std_logic_vector (10 downto 0) := "11001110100";   --m key
             G_SERVE_KEY     : std_logic_vector (10 downto 0) := "10001010010";   --space key
             G_RESET_KEY     : std_logic_vector (10 downto 0) := "10011101100");  --esc key

    port (clk   : in std_logic := '0';
          reset : in std_logic := '0';

          i_ps2_clk  : in std_logic := '0';
          i_ps2_data : in std_logic := '0';

          o_player_1_up   : out std_logic := '0';
          o_player_1_down : out std_logic := '0';
          o_player_2_up   : out std_logic := '0';
          o_player_2_down : out std_logic := '0';
          o_serve_key     : out std_logic := '0';
          o_reset_key     : out std_logic := '0');
  end component;

  component game_engine is
    generic (G_H_RESOLUTION : integer := 640;
             G_V_RESOLUTION : integer := 480;

             G_PADDLE_EVENT_INTERVAL : integer := 100000;
             G_BALL_EVENT_INTERVAL   : integer := 20000;

             G_BORDER_THICKNESS       : integer := 2;
             G_PADDLE_TO_BORDER_SPACE : integer := 2;
             G_PADDLE_HEIGHT          : integer := 91;
             G_PADDLE_WIDTH           : integer := 15;
             G_PADDLE_SLOPE_LENGTH    : integer := 10;
             G_BALL_DIAMETER          : integer := 17;

             G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
             G_BALL_X_POS_SIGNAL_RANGE : integer := 619;
             G_BALL_Y_POS_SIGNAL_RANGE : integer := 461;

             G_POINTS_TO_WIN : integer := 15);

    port (clk   : in std_logic := '0';
          reset : in std_logic := '0';

          i_player_1_up   : in std_logic := '0';
          i_player_1_down : in std_logic := '0';
          i_player_2_up   : in std_logic := '0';
          i_player_2_down : in std_logic := '0';
          i_serve_key     : in std_logic := '0';

          o_player_1_pos    : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
          o_player_2_pos    : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
          o_ball_x_pos      : out integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
          o_ball_y_pos      : out integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;
          o_player_1_points : out integer range 0 to G_POINTS_TO_WIN           := 0;
          o_player_2_points : out integer range 0 to G_POINTS_TO_WIN           := 0);
  end component;

  component points_display is
    generic (G_POINTS_TO_WIN : integer := 15);
    
    port (clk   : in std_logic := '0';
          reset : in std_logic := '0';

          i_player_1_points : in integer range 0 to G_POINTS_TO_WIN := 0;
          i_player_2_points : in integer range 0 to G_POINTS_TO_WIN := 0;

          o_anodes   : out std_logic_vector (3 downto 0) := "1000";
          o_cathodes : out std_logic_vector (7 downto 0) := (others => '1'));
  end component;

  component graphic_engine is
    generic (G_H_PIXEL_NUMBER : integer   := 800;
             G_H_RESOLUTION   : integer   := 640;
             G_H_FRONT_PORCH  : integer   := 8;
             G_H_BACK_PORCH   : integer   := 48;
             G_H_SYNC_LENGTH  : integer   := 96;
             G_H_SYNC_ACTIVE  : std_logic := '0';

             G_V_PIXEL_NUMBER : integer   := 525;
             G_V_RESOLUTION   : integer   := 480;
             G_V_FRONT_PORCH  : integer   := 2;
             G_V_BACK_PORCH   : integer   := 33;  --old value according to digilent manual: 29
             G_V_SYNC_LENGTH  : integer   := 2;
             G_V_SYNC_ACTIVE  : std_logic := '0';

             G_BORDER_THICKNESS       : integer := 2;
             G_PADDLE_TO_BORDER_SPACE : integer := 2;
             G_PADDLE_HEIGHT          : integer := 91;
             G_PADDLE_WIDTH           : integer := 15;
             G_BALL_DIAMETER          : integer := 17;

             G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
             G_BALL_X_POS_SIGNAL_RANGE : integer := 619;
             G_BALL_Y_POS_SIGNAL_RANGE : integer := 461);

    port (clk   : in std_logic := '0';
          reset : in std_logic := '0';

          i_player_1_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
          i_player_2_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
          i_ball_x_pos   : in integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
          i_ball_y_pos   : in integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;

        -- ram interface
        io_ram_dq     : inout std_logic_vector (15 downto 0) := (others => 'Z');
        o_ram_address : out   std_logic_vector (22 downto 0) := (others => '0');
        o_ram_clk     : out   std_logic                      := '0';
        o_ram_adv_neg : out   std_logic                      := '1';
        o_ram_cre     : out   std_logic                      := '0';
        o_ram_ce_neg  : out   std_logic                      := '1';
        o_ram_oe_neg  : out   std_logic                      := '1';
        o_ram_we_neg  : out   std_logic                      := '1';
        o_ram_ub_neg  : out   std_logic                      := '1';
        o_ram_lb_neg  : out   std_logic                      := '1';

          o_h_sync      : out std_logic                      := '0';
          o_v_sync      : out std_logic                      := '0';
          o_red         : out std_logic_vector(2 downto 0)   := (others => '0');
          o_green       : out std_logic_vector(2 downto 0)   := (others => '0');
          o_blue        : out std_logic_vector(1 downto 0)   := (others => '0'));
  end component;
end pong_top_package;
