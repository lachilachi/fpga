library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.render_engine_package.all;

--This module generates the new image data and writes it to the RAM.
--It consists of four submodules. 
--The render engine controller controls all other submodules.
--The position sample register samples all object positions before rendering a 
--new frame.
--The render buffer stores the generated data until it is stored in the RAM.
--The renderer creates new image data.

entity render_engine is
  --generics:
  --G_H_RESOLUTION              : horizontal resolution
  --G_V_RESOLUTION              : vertical resolution
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
  generic (G_H_RESOLUTION : integer := 640;
           G_V_RESOLUTION : integer := 480;

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
  --i_page_switched       : signalise that the graphic output flipped the page
  --i_write_done          : indicate that the buffer was written to the RAM
  --i_player_1_pos        : \
  --i_player_2_pos        : | positions of paddle 1 and 2 and the ball x- and
  --i_ball_x_pos          : | y-position
  --i_ball_y_pos          : /
  --
  --o_write_req           : request to write the buffer content to the RAM
  --o_write_address       : address where to write in the RAM
  --o_write_data          : data that should be written to the RAM
  --o_new_frame_ready     : signalises that a new frame has been rendered
  port (clk   : in std_logic := '0';
        reset : in std_logic := '0';

        i_page_switched : in std_logic                                    := '0';
        i_write_done    : in std_logic                                    := '0';
        i_player_1_pos  : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
        i_player_2_pos  : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
        i_ball_x_pos    : in integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
        i_ball_y_pos    : in integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;

        o_write_req       : out std_logic                          := '0';
        o_write_address   : out std_logic_vector (22 downto 0)     := (others => '0');
        o_write_data      : out std_logic_vector (32*8-1 downto 0) := (others => '0');
        o_new_frame_ready : out std_logic                          := '0');
end render_engine;



architecture rtl of render_engine is

--Used to activate the renderer.
  signal render_enable : std_logic := '0';

--The following signals are used to connect the instances with each other
  signal sample_positions_sig    : std_logic                                    := '0';
  signal create_new_data_sig     : std_logic                                    := '0';
  signal buffer_full_sig         : std_logic                                    := '0';
  signal buffer_shift_enable_sig : std_logic                                    := '0';
  signal player_1_pos_sig        : integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := 0;
  signal player_2_pos_sig        : integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := 0;
  signal ball_x_pos_sig          : integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := 0;
  signal ball_y_pos_sig          : integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := 0;
  signal rgb_sig                 : std_logic_vector (7 downto 0)                := (others => '0');
  signal write_data_sig          : std_logic_vector(32*8-1 downto 0)            := (others => '0');


begin

--The render engine controller controls all other instances of the render 
  --engine and is responsible for communication with the RAM controller and 
  --calculates the RAM address to where the data should be written.
  render_engine_controller_inst : render_engine_controller
    generic map (G_H_RESOLUTION,
                 G_V_RESOLUTION)

    port map (clk   => clk,
              reset => reset,

              i_buffer_full   => buffer_full_sig,
              i_write_done    => i_write_done,
              i_page_switched => i_page_switched,

              o_sample_positions => sample_positions_sig,
              o_create_new_data  => create_new_data_sig,
              o_write_req        => o_write_req,
              o_write_address    => o_write_address,
              o_new_frame_ready  => o_new_frame_ready);

  --The position sample register samples the position of the paddles and the 
  --ball at the beginning of the rendering of a new frame, so the data 
  --remains the same for the whole rendering process.
  position_sample_register_inst : position_sample_register
    generic map (G_PLAYER_POS_SIGNAL_RANGE,
                 G_BALL_X_POS_SIGNAL_RANGE,
                 G_BALL_Y_POS_SIGNAL_RANGE)

    port map (clk   => clk,
              reset => reset,

              i_sample_positions => sample_positions_sig,
              i_player_1_pos     => i_player_1_pos,
              i_player_2_pos     => i_player_2_pos,
              i_ball_x_pos       => i_ball_x_pos,
              i_ball_y_pos       => i_ball_y_pos,

              o_player_1_pos => player_1_pos_sig,
              o_player_2_pos => player_2_pos_sig,
              o_ball_x_pos   => ball_x_pos_sig,
              o_ball_y_pos   => ball_y_pos_sig);

  --The renderer generates the colour data for each pixel.
  renderer_inst : renderer
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

              i_render_enable => render_enable,
              i_player_1_pos  => player_1_pos_sig,
              i_player_2_pos  => player_2_pos_sig,
              i_ball_x_pos    => ball_x_pos_sig,
              i_ball_y_pos    => ball_y_pos_sig,

              o_buffer_shift_enable => buffer_shift_enable_sig,
              o_rgb                 => rgb_sig);

  --The render buffer stores the data from the renderer until they are written 
  --to the RAM
  render_buffer_inst : render_buffer
    port map (clk   => clk,
              reset => reset,

              i_shift_enable => buffer_shift_enable_sig,
              i_rgb          => rgb_sig,

              o_buffer_full => buffer_full_sig,
              o_rgb_data    => write_data_sig);

  --This statement creates the enable signal for the renderer.
  --The renderer should generate new data only if the render controller 
  --activates it and the render buffer is not full. This signal is neccessary
  --because the render engine controller would set the disable signal for the 
  --renderer one cycle after the render buffer is full. With this signal the 
  --renderer disable signal is set in the same cycle as the buffer full 
  --signal.
  render_enable <= create_new_data_sig and not(buffer_full_sig);

  -- assign outputs
  o_write_data <= write_data_sig;
  

end rtl;

