library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This module controls the paddle movement for both players.
--A paddle can only be moved if a paddle event occurs and the corresponding
--paddle movement key is pressed at the same time.

entity paddle_movement is
   --generics:
   --G_V_RESOLUTION              : vertical resolution
   --       
   --G_BORDER_THICKNESS          : thickness of the border around the playing 
   --                              field
   --G_PADDLE_HEIGHT             : height of the paddles
   --
   --G_PLAYER_POS_SIGNAL_RANGE   : maximum value for the position of the 
   --                              paddles
   generic (G_V_RESOLUTION : integer := 480;
            
            G_BORDER_THICKNESS : integer := 2;
            G_PADDLE_HEIGHT : integer := 91;
            
            G_PLAYER_POS_SIGNAL_RANGE : integer := 387);
   
   --ports:
   --clk             : system clock
   --reset           : synchronous reset
   --
   --i_paddle_event  : signalises a paddle event
   --i_player_1_up   : key for up movement of paddle 1
   --i_player_1_down : key for down movement of paddle 1
   --i_player_2_up   : key for up movement of paddle 2
   --i_player_2_down : key for down movement of paddle 2
   --
   --o_player_1_pos  : position of the paddle of player 1
   --o_player_2_pos  : position of the paddle of player 2
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_paddle_event : in std_logic := '0';
         i_player_1_up : in std_logic := '0';
         i_player_1_down : in std_logic := '0';
         i_player_2_up : in std_logic := '0';
         i_player_2_down : in std_logic := '0';
         
         o_player_1_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := 0;
         o_player_2_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := 0);
end paddle_movement;



architecture rtl of paddle_movement is

--These signals are used to store the position of both peddals. They are later
--assigned to the outputs with the corresponding name
signal player_1_pos : integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
signal player_2_pos : integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;

begin
   --Type : registered
   --Description : This process is responsible for the paddle movement. At each 
   --    paddle event it checks the pressed keys and increases or decreases the 
   --    paddle coordinates.
   process (clk)
   begin
      if (clk'event and clk = '1') then
         --Synchronous reset
         if (reset = '1') then
            --The paddles position is set to the middle of the vertical axis
            --of the screen
            player_1_pos <= G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
            player_2_pos <= G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
         
         --The following instructions are only executed if the event trigger
         --generates a trigger impulse for the paddle movement.
         elsif (i_paddle_event = '1') then
            --Now the keys that are pressed at the moment of the trigger 
            --impulse are checked and the paddle position is changed.
            
            --Player 1 up key
            if (i_player_1_up = '1') then
               --Collision detection with upper border
               if (player_1_pos /= G_BORDER_THICKNESS) then 
               --Decrease position by 1
                  player_1_pos <= player_1_pos - 1;
               end if;
            --Player 1 down key
            elsif (i_player_1_down = '1') then
               --Collision detection with lower border
               if (player_1_pos /= G_PLAYER_POS_SIGNAL_RANGE) then 
               --Increase position by 1
                  player_1_pos <= player_1_pos + 1;
               end if;
            end if;

            --Player 2 up key          
            if (i_player_2_up = '1') then
               --Collision detection with upper border
               if (player_2_pos /= G_BORDER_THICKNESS) then 
               --Decrease position by 1
                  player_2_pos <= player_2_pos - 1;
               end if;
            --Player 2 down key
            elsif (i_player_2_down = '1') then
               --Collision detection with lower border
               if (player_2_pos /= G_PLAYER_POS_SIGNAL_RANGE) then 
               --Increase position by 1
                  player_2_pos <= player_2_pos + 1;
               end if;
            end if;
         end if;
      end if;
   end process;

   --The position signals are assigned to the outputs
   o_player_1_pos <= player_1_pos;
   o_player_2_pos <= player_2_pos;

end rtl;

