library IEEE;
use IEEE.STD_LOGIC_1164.all;

package graphic_engine_package is
  component graphic_engine
    generic (G_H_PIXEL_NUMBER : integer   := 800;
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

             G_BORDER_THICKNESS       : integer := 2;
             G_PADDLE_TO_BORDER_SPACE : integer := 2;
             G_PADDLE_HEIGHT          : integer := 91;
             G_PADDLE_WIDTH           : integer := 15;
             G_BALL_DIAMETER          : integer := 17;

             G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
             G_BALL_X_POS_SIGNAL_RANGE : integer := 604;
             G_BALL_Y_POS_SIGNAL_RANGE : integer := 461);
    port (
      clk            : in    std_logic                                    := '0';
      reset          : in    std_logic                                    := '0';
      i_player_1_pos : in    integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
      i_player_2_pos : in    integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
      i_ball_x_pos   : in    integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
      i_ball_y_pos   : in    integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;
      io_ram_dq      : inout std_logic_vector (15 downto 0)               := (others => 'Z');
      o_ram_address  : out   std_logic_vector (22 downto 0)               := (others => '0');
      o_ram_clk      : out   std_logic                                    := '0';
      o_ram_adv_neg  : out   std_logic                                    := '1';
      o_ram_cre      : out   std_logic                                    := '0';
      o_ram_ce_neg   : out   std_logic                                    := '1';
      o_ram_oe_neg   : out   std_logic                                    := '1';
      o_ram_we_neg   : out   std_logic                                    := '1';
      o_ram_ub_neg   : out   std_logic                                    := '1';
      o_ram_lb_neg   : out   std_logic                                    := '1';
      o_h_sync       : out   std_logic                                    := '0';
      o_v_sync       : out   std_logic                                    := '0';
      o_red          : out   std_logic_vector(2 downto 0)                 := (others => '0');
      o_green        : out   std_logic_vector(2 downto 0)                 := (others => '0');
      o_blue         : out   std_logic_vector(1 downto 0)                 := (others => '0'));
  end component;

  component render_engine is
    generic (G_H_RESOLUTION : integer := 640;
             G_V_RESOLUTION : integer := 480;

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

          i_page_switched : in std_logic                                    := '0';
          i_write_done    : in std_logic                                    := '0';
          i_player_1_pos  : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
          i_player_2_pos  : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
          i_ball_x_pos    : in integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
          i_ball_y_pos    : in integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;

          o_write_req       : out std_logic                         := '0';
          o_write_address   : out std_logic_vector (22 downto 0)    := (others => '0');
          o_write_data      : out std_logic_vector (32*8-1 downto 0) := (others => '0');
          o_new_frame_ready : out std_logic                         := '0');
  end component;

  component ram_controller
    generic (
      G_BURST_COUNT : integer := 16;
      G_DATA_WIDTH  : integer := 16);
    port (
      clk             : in    std_logic                                                := '0';
      reset           : in    std_logic                                                := '0';
      i_read_req      : in    std_logic                                                := '0';
      i_write_req     : in    std_logic                                                := '0';
      i_read_address  : in    std_logic_vector (22 downto 0)                           := (others => '0');
      i_write_address : in    std_logic_vector (22 downto 0)                           := (others => '0');
      i_write_data    : in    std_logic_vector (G_BURST_COUNT*G_DATA_WIDTH-1 downto 0) := (others => '0');
      o_read_done     : out   std_logic                                                := '0';
      o_write_done    : out   std_logic                                                := '0';
      o_read_data     : out   std_logic_vector (G_BURST_COUNT*G_DATA_WIDTH-1 downto 0) := (others => '0');
      io_ram_dq       : inout std_logic_vector (15 downto 0)                           := (others => 'Z');
      o_ram_address   : out   std_logic_vector (22 downto 0)                           := (others => '0');
      o_ram_clk       : out   std_logic                                                := '0';
      o_ram_adv_neg   : out   std_logic                                                := '1';
      o_ram_cre       : out   std_logic                                                := '0';
      o_ram_ce_neg    : out   std_logic                                                := '1';
      o_ram_oe_neg    : out   std_logic                                                := '1';
      o_ram_we_neg    : out   std_logic                                                := '1';
      o_ram_ub_neg    : out   std_logic                                                := '1';
      o_ram_lb_neg    : out   std_logic                                                := '1');
  end component;

  component graphic_output is
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
             G_V_SYNC_ACTIVE  : std_logic := '0');

    port (clk   : in std_logic := '0';
          reset : in std_logic := '0';

          i_read_done       : in  std_logic                           := '0';
          i_read_data       : in  std_logic_vector (32*8-1 downto 0) := (others => '0');
          i_new_frame_ready : in  std_logic                           := '0';
          o_red             : out std_logic_vector(2 downto 0)        := (others => '0');
          o_green           : out std_logic_vector(2 downto 0)        := (others => '0');
          o_blue            : out std_logic_vector(1 downto 0)        := (others => '0');
          o_h_sync          : out std_logic                           := '0';
          o_v_sync          : out std_logic                           := '0';
          o_read_req        : out std_logic                           := '0';
          o_read_address    : out std_logic_vector (22 downto 0)      := (others => '0');
          o_page_switched   : out std_logic                           := '0');
  end component;
end graphic_engine_package;
