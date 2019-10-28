library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.graphic_engine_package.all;

--This module is responsible for calculating the image data and displaying it 
--on the screen. It is build to comply with the standard VGA resolutions of 
--640x480, 800x600 and 1024x768 pixel. The colour depth is 3 bit (1 bit for 
--each colour component, so it is capable of displaying 8 different colours).  
--Only analog output is supported.
--To guarantee that valid image data is available all the time, the graphic 
--engine was designed to use so called page flipping. This means one frame is 
--rendered and written to one part of the memory while the frame that is being 
--displayed at the moment is read from a different part of the memory. When the 
--whole frame was displayed and a new one was rendered, the pages are flipped 
--(i.e. the pointers to the part of the RAM from where to read or where to 
--write are swapped) and the new frame is rendered to the part of the RAM 
--where the last frame was read from and last rendered frame is now being 
--displayed. This guarantees that the current frame on display is not changed 
--during its display period.
--The image data is stored in words of 24 bits (3 bits per pixel x 8 pixels per 
--word). Because the RAM data port is 32 bit broad, 8 bits remain unused. 
--Although these bits could have been used to store pixel data and use the RAM 
--more efficiently the number of pixels per dataword was limited to eight 
--because the number of horizontal pixels of all compatible resolutions can 
--be diveded by eight. So at each end of a frame the last read dataword was 
--completely displayed and there is no need to reset the buffers used to store 
--the dataword.
--Important: The graphic output is not connected to the system clock but runs 
--with its own clock. This clock's cycle time is equivalent to the time between 
--two pixels are displayed on the screen. That is why it is called pixel clock.

entity graphic_engine is
  --generics:
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
  --G_V_BACK_PORCH              : vertical back porch length in pixels
  --G_V_SYNC_LENGTH             : vertical sync pulse length in pixels
  --G_V_SYNC_ACTIVE             : vertical sync pulse polarity 
  --                              (1 = pos, 0 = neg)
  --
  --G_BORDER_THICKNESS          : thickness of the border around the playing 
  --                              field
  --G_PADDLE_TO_BORDER_SPACE    : space between paddle and border
  --G_PADDLE_HEIGHT             : height of the paddles
  --G_PADDLE_WIDTH              : width of the paddles
  --G_BALL_DIAMETER             : diameter of the ball
  --
  --G_PLAYER_POS_SIGNAL_RANGE   : maximum value for the position of the 
  --                              paddles
  --G_BALL_X_POS_SIGNAL_RANGE   : maximum value for the x position of the ball
  --G_BALL_Y_POS_SIGNAL_RANGE   : maximum value for the y position of the ball
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

  --ports:
  --clk                   : system clock
  --reset                 : synchronous reset
  --
  --i_external_pixel_clk  : 
  --i_player_1_pos        : \
  --i_player_2_pos        : | position of player 1 and 2 and the ball x- and
  --i_ball_x_pos          : | y-posiotion
  --i_ball_y_pos          : /
  --
  --io_ram_data           : bidirectional data port to the RAM
  --
  --o_ram_address         : address port connected to the RAM
  --o_ce_1_neg            : chip enable for RAM chip 1 (negative logic)
  --o_ce_2_neg            : chip enable for RAM chip 2 (negative logic)
  --o_oe_neg              : output enable of RAM (negative logic)
  --o_we_neg              : write enable of RAM (negative logic)
  --o_ub_1_neg            : upper byte enable for RAM chip 1 (negative logic)
  --o_ub_2_neg            : upper byte enable for RAM chip 2 (negative logic)
  --o_lb_1_neg            : lower byte enable for RAM chip 1 (negative logic)
  --o_lb_2_neg            : lower byte enable for RAM chip 2 (negative logic)
  --o_h_sync              : horizontal synchronisation impulse
  --o_v_sync              : vertical synchronisation impulse
  --o_red                 : output of red component of the current pixel
  --o_green               : output of green component of the current pixel
  --o_blue                : output of blue component of the current pixel
  port (clk   : in std_logic := '0';
        reset : in std_logic := '0';

        --internal interface
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

        -- VGA out
        o_h_sync : out std_logic                    := '0';
        o_v_sync : out std_logic                    := '0';
        o_red    : out std_logic_vector(2 downto 0) := (others => '0');
        o_green  : out std_logic_vector(2 downto 0) := (others => '0');
        o_blue   : out std_logic_vector(1 downto 0) := (others => '0'));
end graphic_engine;

architecture rtl of graphic_engine is

  ------------------------------------------------------------------------------------------------------------
  -- constants
  ------------------------------------------------------------------------------------------------------------
  constant G_BURST_COUNT : integer := 16;
  constant G_DATA_WIDTH  : integer := 16;

--Signals used to connect the instances
  signal pixel_clk_sig       : std_logic                                                := '0';
  signal pixel_clk_div       : unsigned(0 downto 0)                                     := (others => '1');
  signal page_switched_sig   : std_logic                                                := '0';
  signal new_frame_ready_sig : std_logic                                                := '0';
  signal read_req_sig        : std_logic                                                := '0';
  signal write_req_sig       : std_logic                                                := '0';
  signal read_address_sig    : std_logic_vector (22 downto 0)                           := (others => '0');
  signal write_address_sig   : std_logic_vector (22 downto 0)                           := (others => '0');
  signal write_data_sig      : std_logic_vector (32*8-1 downto 0)                        := (others => '0');
  signal read_done_sig       : std_logic                                                := '0';
  signal write_done_sig      : std_logic                                                := '0';
  signal read_data_sig       : std_logic_vector (G_BURST_COUNT*G_DATA_WIDTH-1 downto 0) := (others => '1');
  signal ram_busy_sig        : std_logic                                                := '0';

  -- vga
  signal s_red   : std_logic_vector(2 downto 0) := (others => '0');
  signal s_green : std_logic_vector(2 downto 0) := (others => '0');
  signal s_blue  : std_logic_vector(1 downto 0) := (others => '0');
  
begin

  ------------------------------------------------------------------------------------------------------------
  -- concurrent stuff
  ------------------------------------------------------------------------------------------------------------
  o_red   <= s_red;
  o_green <= s_green;
  o_blue  <= s_blue;

  --Creates the clock signal for the graphic output.
  pix_clk_proc : process(clk)
  begin
    if rising_edge(clk) then
      pixel_clk_div <= pixel_clk_div - 1;
      if pixel_clk_div = 0 then
        pixel_clk_sig <= not pixel_clk_sig;
      end if;
    end if;
  end process pix_clk_proc;

  --The render engine generates new frames and stores the data into a buffer. 
  --This data is then written to the RAM by the ram controller.
  render_engine_inst : render_engine
    generic map (G_H_RESOLUTION,
                 G_V_RESOLUTION,

                 G_BORDER_THICKNESS,
                 G_PADDLE_TO_BORDER_SPACE,
                 G_PADDLE_HEIGHT,
                 G_PADDLE_WIDTH,
                 G_BALL_DIAMETER,

                 G_PLAYER_POS_SIGNAL_RANGE,
                 G_BALL_X_POS_SIGNAL_RANGE,
                 G_BALL_Y_POS_SIGNAL_RANGE)

    port map (clk   => clk,
              reset => reset,

              i_page_switched => page_switched_sig,
              i_write_done    => write_done_sig,
              i_player_1_pos  => i_player_1_pos,
              i_player_2_pos  => i_player_2_pos,
              i_ball_x_pos    => i_ball_x_pos,
              i_ball_y_pos    => i_ball_y_pos,

              o_write_req       => write_req_sig,
              o_write_data      => write_data_sig,
              o_write_address   => write_address_sig,
              o_new_frame_ready => new_frame_ready_sig);

  --The ram controller is the interface between the FPGA and the RAM. It 
  --stores the data from the render engine into the RAM and reads the data 
  --required by the graphic output from the RAM when requested to do so.
  ram_controller_1 : ram_controller
    generic map (
      G_BURST_COUNT => G_BURST_COUNT,
      G_DATA_WIDTH  => G_DATA_WIDTH)
    port map (
      clk             => clk,
      reset           => reset,
      i_read_req      => read_req_sig,
      i_write_req     => write_req_sig,
      i_read_address  => read_address_sig,
      i_write_address => write_address_sig,
      i_write_data    => write_data_sig,
      o_read_done     => read_done_sig,
      o_write_done    => write_done_sig,
      o_read_data     => read_data_sig,
      io_ram_dq       => io_ram_dq,
      o_ram_address   => o_ram_address,
      o_ram_clk       => o_ram_clk,
      o_ram_adv_neg   => o_ram_adv_neg,
      o_ram_cre       => o_ram_cre,
      o_ram_ce_neg    => o_ram_ce_neg,
      o_ram_oe_neg    => o_ram_oe_neg,
      o_ram_we_neg    => o_ram_we_neg,
      o_ram_ub_neg    => o_ram_ub_neg,
      o_ram_lb_neg    => o_ram_lb_neg);

  --The graphic output is responsible for delivering the right signals to the 
  --VGA connector on the FPGA board. It also buffers the data read from the 
  --RAM by the ram controller.
  graphic_output_inst : graphic_output
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
                 G_V_SYNC_ACTIVE)

    port map (clk   => pixel_clk_sig,
              reset => reset,

              i_read_done       => read_done_sig,
              i_read_data       => read_data_sig,
              i_new_frame_ready => new_frame_ready_sig,

              o_h_sync => o_h_sync,
              o_v_sync => o_v_sync,
              o_red    => s_red,
              o_green  => s_green,
              o_blue   => s_blue,

              o_read_req      => read_req_sig,
              o_read_address  => read_address_sig,
              o_page_switched => page_switched_sig);

end rtl;
