library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This module generates the data fed to the render buffer. It works on a pixel 
--basis and calculates the colour values for each pixel individualy.
--Two counters are used. One for the horizontal pixel position and one for the 
--vertical position. To check if the current pixel lies within one object or 
--not, so called region flags are used. For each object there are two flags. 
--One for the vertical region and one for horizontal region. The horizontal 
--flag is set if the horizontal pixel counter passes the left border of the 
--object and it is reset if the counter passes the right border. The same 
--principle applies for the vertical flag, only that it is set by the vertical 
--counter while passing the top border and reset while passing the bottom 
--border. If both flags are set, the current pixel lies within the object and 
--will be coloured.

entity renderer is
   --generics:
   --G_H_RESOLUTION              : horizontal resolution
   --G_V_RESOLUTION              : vertical resolution
   
   --G_BORDER_THICKNESS          : thickness of the border around the playing 
   --                              field
   --G_PADDLE_TO_BORDER_SPACE    : space between paddle and border
   --G_PADDLE_HEIGHT             : height of the paddles
   --G_PADDLE_WIDTH              : width of the paddle
   --G_BALL_DIAMETER             : diameter of the ball
   
   --G_PLAYER_POS_SIGNAL_RANGE   : maximum value for the position of the 
   --                              paddles
   --G_BALL_X_POS_SIGNAL_RANGE   : maximum value for the x position of the ball
   --G_BALL_Y_POS_SIGNAL_RANGE   : maximum value for the y position of the ball
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
            
   --ports:
   --clk                      : system clock
   --reset                    : synchronous reset
   --
   --i_render_enable          : enables the rendering process
   --i_player_1_pos           : \
   --i_player_2_pos           : | the positions of player 1 and player 2 and
   --i_ball_x_pos             : | the ball x- and y-position
   --i_ball_y_pos             : /
   --
   --o_buffer_shift_enable    : output to enable the shift operation in the 
   --                           render buffer
   --o_rgb                    : output of the rendered data 
   --                           MSB(RRRGGGBB)LSB
   port (clk : in std_logic;
         reset : in std_logic;
         
         i_render_enable : in std_logic := '0';
         i_player_1_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
         i_player_2_pos : in integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
         i_ball_x_pos : in integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
         i_ball_y_pos : in integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2;
         
         o_buffer_shift_enable : out std_logic := '0';
         o_rgb : out std_logic_vector (7 downto 0) := (others => '0'));
end renderer;



architecture rtl of renderer is

--These two counters are used to specify the pixel that is rendered at the 
--moment.
signal cnt_column : integer range 0 to G_H_RESOLUTION - 1 := 0;
signal cnt_row : integer range 0 to G_V_RESOLUTION - 1 := 0;
--These are the region flags for the objects paddle 1, paddle 2, ball and 
--border. The h in the signal name indicates the horizontal flag and the v the 
--vertical flag.
signal in_h_paddle_1_region : std_logic := '0';
signal in_v_paddle_1_region : std_logic := '0';
signal in_h_paddle_2_region : std_logic := '0';
signal in_v_paddle_2_region : std_logic := '0';
signal in_h_ball_region : std_logic := '0';
signal in_v_ball_region : std_logic := '0';
signal in_h_border_region : std_logic := '0';
signal in_v_border_region : std_logic := '0';

begin
   --Type : registered
   --Description : This process controls two counters (one for x- and one for 
   --    y-dimension) that specify the current pixel that should be rendered.
   --    It also sets flags when the pixel lies within the region of one of the
   --    objects on the playing field.
   process (clk)
   begin
      if (clk'event and clk = '1') then
         --Synchronous reset
         if (reset = '1') then
            cnt_column <= 0;
            cnt_row <= 0;
            o_buffer_shift_enable <= '0';
         
         --All calculation are only executed when the rendering process is 
         --activated with the i_render_enable input
         elsif (i_render_enable = '1') then
            --Enable the shift operation of the render buffer
            o_buffer_shift_enable <= '1';
            
            --All region flags are set to one when the column or row counter 
            --reach the left or top border of the object. The flags are reset 
            --to zero when the column or row counter leave the object on the 
            --right or bottom side.
            
            --Set in_h_paddle_1_region
            if (cnt_column = G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE) then
               in_h_paddle_1_region <= '1';
            elsif (cnt_column = G_BORDER_THICKNESS + G_PADDLE_WIDTH + G_PADDLE_TO_BORDER_SPACE) then
               in_h_paddle_1_region <= '0';
            end if;
            --Set in_v_paddle_1_region
            if (cnt_row = i_player_1_pos) then
               in_v_paddle_1_region <= '1';
            elsif (cnt_row = i_player_1_pos + G_PADDLE_HEIGHT) then
               in_v_paddle_1_region <= '0';
            end if;
            
            --Set in_h_paddle_2_region
            if (cnt_column = 640 - G_BORDER_THICKNESS - G_PADDLE_WIDTH - G_PADDLE_TO_BORDER_SPACE) then
               in_h_paddle_2_region <= '1';
            elsif (cnt_column = 640 - G_BORDER_THICKNESS - G_PADDLE_TO_BORDER_SPACE) then
               in_h_paddle_2_region <= '0';
            end if;
            --Set in_v_paddle_2_region
            if (cnt_row = i_player_2_pos) then
               in_v_paddle_2_region <= '1';
            elsif (cnt_row = i_player_2_pos + G_PADDLE_HEIGHT) then
               in_v_paddle_2_region <= '0';
            end if;
            
            --Set in_h_ball_region
            if (cnt_column = i_ball_x_pos) then
               in_h_ball_region <= '1';
            elsif (cnt_column = i_ball_x_pos + G_BALL_DIAMETER) then
               in_h_ball_region <= '0';
            end if;
            --Set in_v_ball_region
            if (cnt_row = i_ball_y_pos) then
               in_v_ball_region <= '1';
            elsif (cnt_row = i_ball_y_pos + G_BALL_DIAMETER) then
               in_v_ball_region <= '0';
            end if;
            
            --Set in_h_border_region
            --No need to check for cnt_row = 0 (top border beginning) because the 
            --in_h_border_region flag is still active from the previous frame. 
            --The missing top border in the first frame isn't visible because 
            --it only lasts one frame and gets lost in the monitor synchronisation,
            --where the screen is blank.
            if (cnt_row = G_V_RESOLUTION - G_BORDER_THICKNESS) then
               in_h_border_region <= '1';
            elsif (cnt_row = G_BORDER_THICKNESS) then
               in_h_border_region <= '0';
            end if;
            
            --Set in_v_border_region
            --No need to check for cnt_column = 0 (left border beginning). For 
            --explanation see setting of in_h_border above.
            if (cnt_column = G_H_RESOLUTION - G_BORDER_THICKNESS) then
               in_v_border_region <= '1';
            elsif (cnt_column = G_BORDER_THICKNESS) then
               in_v_border_region <= '0';
            end if;
            
            --Increment the column and/or row counter for the next pixel and 
            --detect if the counters have reached their maximum value.
            if (cnt_column = G_H_RESOLUTION - 1) then
               cnt_column <= 0;
               if (cnt_row = G_V_RESOLUTION - 1) then
                  cnt_row <= 0;
               else
                  cnt_row <= cnt_row + 1;
               end if;
            else
               cnt_column <= cnt_column + 1;
            end if;
            
         --Disable the shift operation in the render buffer
         else
            o_buffer_shift_enable <= '0';
         end if;  
      end if;  
   end process;
   
   --Set the doutput according to the position flags. The first conditions have 
   --the highest priority, so there won't be any problems with two overlapping 
   --objects
--   o_rgb <= "111" when (in_h_border_region = '1' or in_v_border_region = '1')
--       else "001" when (in_h_paddle_1_region = '1' and in_v_paddle_1_region = '1') or (in_h_paddle_2_region = '1' and in_v_paddle_2_region = '1')
--       else "110" when (in_h_ball_region = '1' and in_v_ball_region = '1')
--       else "000";
--   
   o_rgb <= "11111111" when (in_h_border_region = '1' or in_v_border_region = '1')
       else "00000011" when (in_h_paddle_1_region = '1' and in_v_paddle_1_region = '1') or (in_h_paddle_2_region = '1' and in_v_paddle_2_region = '1')
       else "11111100" when (in_h_ball_region = '1' and in_v_ball_region = '1')
       else "00000000";
   
   
end rtl;

