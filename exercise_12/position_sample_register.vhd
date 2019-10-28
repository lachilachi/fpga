library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This module samples the positions of the ball and the paddles before a new 
--frame is rendered and stores them in a regfister. This prevents a change in 
--the position data used during rendering.
--To trigger the sampling the sample input must be activated.

entity position_sample_register is
   --generics:
   --G_PLAYER_POS_SIGNAL_RANGE   : maximum value for the position of the 
   --                              paddles
   --G_BALL_X_POS_SIGNAL_RANGE   : maximum value for the x position of the ball
   --G_BALL_Y_POS_SIGNAL_RANGE   : maximum value for the y position of the ball
 generic (G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
          G_BALL_X_POS_SIGNAL_RANGE : integer := 604;
          G_BALL_Y_POS_SIGNAL_RANGE : integer := 461);
   
   --ports:
   --clk                   : system clock
   --reset                 : synchronous reset
   --
   --i_sample_positions    : triggers the sampling of the positions
   --i_player_1_pos        : \
   --i_player_2_pos        : | the incoming positions of player 1, player 2
   --i_ball_x_pos          : | and the ball x and y position
   --i_ball_y_pos          : /
   --
   --o_player_1_pos        : \
   --o_player_2_pos        : | the sampled positions
   --o_ball_x_pos          : |
   --o_ball_y_pos          : /
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
end position_sample_register;



architecture rtl of position_sample_register is
begin
   --Type : registered
   --Description : If the i_sample_position input is one the incoming position 
   --    data will be written into the corresponding output registers.
   process (clk)
   begin
      if (clk'event and clk = '1') then
         --Synchronous reset and sampling of the position data
         if (reset = '1' or i_sample_positions = '1') then
            o_player_1_pos <= i_player_1_pos;
            o_player_2_pos <= i_player_2_pos;
            o_ball_x_pos <= i_ball_x_pos;
            o_ball_y_pos <= i_ball_y_pos;
         end if;
      end if;
   end process;
   
end rtl;

