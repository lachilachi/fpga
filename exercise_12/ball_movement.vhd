library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--This module controls the ball movement, collision detection and signalises 
--points scored by players.
--
--The ball moves only on events from the event trigger, but unlike the paddle
--movement, the ball must be able to move at different speeds. This is 
--implemented by two counters that count the ball events for x and y movement. 
--The ball only moves when these counters have reached a value defined by the 
--velocity of the ball. The velocity values are taken from the random number 
--generator during serving.
--NOTE: The velocity values are not a real velocity, but the reciprocal value 
--of the velocity, i.e. 0 is the fastest speed (movement at every ball event) 
--of the ball and 15 the slowest (movement only every 15th ball event).
--With this movement model there is no possibility that the ball moves in one 
--direction (e.g. only in the x direction and no movement in y direction). This
--is important to prevent a deadlock where the ball travels either from the top 
--to the bottom without moving in x direction or from left to right without 
--movement in y direction.
--
--On a collision with an object (border or paddle) the ball is reflected. 
--For a reflection at the paddles it is enough to have an overlapping between 
--the ball and the paddle of only one pixel.
--At a reflection the ball's absolute speed does not change and the incoming 
--angle relative to the normal vector of the objects surface is equal to the 
--outgoing angle.
--This is in most cases done by inverting only one of the ball's direction and 
--leaving the velocity values, because most objects are at a right angle to 
--either x or y direction.
--The only exception are the corners of the paddles. In these areas there is a 
--simulated slope (not visible on the screen). To keep the movement model 
--correct it is not sufficient to only invert the movement direction of the 
--ball, instead the current movement data is fed to the address input of a 
--ROM which delivers the new correct movement data.
--
--The ball is only reflected when there is an overlapping of the ball 
--and the paddle at least at one pixel.

entity ball_movement is
   --generics:
   --G_H_RESOLUTION              : horizontal resolution
   --G_V_RESOLUTION              : vertical resolution
   --
   --G_BORDER_THICKNESS          : thickness of the border around the playing 
   --                              field
   --G_PADDLE_TO_BORDER_SPACE    : space between paddle and border
   --G_PADDLE_HEIGHT             : height of the paddles
   --G_PADDLE_WIDTH              : width of the paddles
   --G_PADDLE_SLOPE_LENGTH       : size of the slope on the paddle corners
   --G_BALL_DIAMETER             : diameter of the ball  
   --
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
            G_PADDLE_SLOPE_LENGTH : integer := 10;
            G_BALL_DIAMETER : integer := 17;
            
            G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
            G_BALL_X_POS_SIGNAL_RANGE : integer := 604;
            G_BALL_Y_POS_SIGNAL_RANGE : integer := 461);
   
   --ports:
   --clk                : system clock
   --reset              : synchronous reset
   --
   --i_ball_event       : input for ball event
   --i_random_number    : input from random number generator
   --i_ball_free        : signalises if the ball is free to move or bound to 
   --                     the paddle
   --i_serving_player   : indicates the serving player (0 = player 1, 
   --                     1 = player 2)
   --i_player_1_pos     : position of player 1
   --i_player_2_pos     : position of player 2
   --i_rom_data         : data input from the ROM
   --
   --o_point_player_1   : set to 1 when player 1 scores a point
   --o_point_player_2   : set to 2 when player 1 scores a point
   --o_ball_x_pos       : output for ball x position
   --o_ball_y_pos       : output for ball x position
   --o_rom_address      : address output to the ROM
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
end ball_movement;



architecture rtl of ball_movement is

--These constants define the maximum and minimum values for the position of 
--the ball in x- and y-direction.
constant C_BALL_MIN_X_POS : integer := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH;
constant C_BALL_MAX_X_POS : integer := G_BALL_X_POS_SIGNAL_RANGE;
constant C_BALL_MIN_Y_POS : integer := G_BORDER_THICKNESS;
constant C_BALL_MAX_Y_POS : integer := G_BALL_Y_POS_SIGNAL_RANGE;

--Counters that count ball events for x and y direction movement.
signal cnt_ball_x_movement_timer : unsigned (3 downto 0) := (others => '0');
signal cnt_ball_y_movement_timer : unsigned (3 downto 0) := (others => '0');
--The ball an
signal ball_x_pos : integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
signal ball_y_pos : integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_BALL_DIAMETER / 2;
--Movement data for the ball. Direction and velocity for x and y movement.
signal ball_x_direction : std_logic := '0';
signal ball_y_direction : std_logic := '0';
signal ball_x_velocity : std_logic_vector (3 downto 0) := (others => '0');
signal ball_y_velocity : std_logic_vector (3 downto 0) := (others => '0');

begin

   --Type : registered
   --Description : This process calculates the position of the ball relative to 
   --    the paddles. It also executes ball movement and collision detection 
   --    and calculates the address for the ROM.
   process (clk)

   --Variables used to indicate in which region of the paddle the ball is.
   --Set if the ball is in the corresponding region (top, middle, bottom)
   variable ball_in_paddle_1_top_region : std_logic := '0';
   variable ball_in_paddle_1_middle_region : std_logic := '0';
   variable ball_in_paddle_1_bottom_region : std_logic := '0';
   --Set if the ball center is above the paddle center
   variable ball_above_paddle_1_middle : std_logic := '0';
   --Same as the above variables, but for paddle 2.
   variable ball_in_paddle_2_top_region : std_logic := '0';
   variable ball_in_paddle_2_middle_region : std_logic := '0';
   variable ball_in_paddle_2_bottom_region : std_logic := '0';
   variable ball_above_paddle_2_middle : std_logic := '0';

   begin
      if (clk'event and clk = '1') then
         --Each cycle the position of the ball relative to both paddles is 
         --calculated.
         --First it is checked if the ball is above the middle of the paddle.
         if ((ball_y_pos + G_BALL_DIAMETER / 2) < (i_player_1_pos + G_PADDLE_HEIGHT / 2)) then
            ball_above_paddle_1_middle := '1';
         else
            ball_above_paddle_1_middle := '0';
         end if;
         --Now it is checked if there is an overlapping between the ball and 
         --the paddle.
         if ((ball_y_pos + G_BALL_DIAMETER) > i_player_1_pos and ball_y_pos < (i_player_1_pos + G_PADDLE_HEIGHT)) then
            --If the ball is in the paddle area ,the third step is to check if 
            --the ball is in the middle region of the paddle (the center of the 
            --ball has to be in the middle region of the paddle). If so, the 
            --middle region flag is set.
            if ((ball_y_pos + G_BALL_DIAMETER / 2) > (i_player_1_pos + G_PADDLE_SLOPE_LENGTH - 1) and (ball_y_pos + G_BALL_DIAMETER / 2) < (i_player_1_pos + G_PADDLE_HEIGHT - G_PADDLE_SLOPE_LENGTH + 1)) then
               ball_in_paddle_1_middle_region := '1';
            else
               ball_in_paddle_1_middle_region := '0';
            end if;
            --If the ball is in the paddle area but not in the middle region of 
            --the paddle it has to be either in the top (if the ball is above 
            --the paddle middle) or bottom (ball below the paddle middle) 
            --region.
            ball_in_paddle_1_top_region := ball_above_paddle_1_middle and not(ball_in_paddle_1_middle_region);
            ball_in_paddle_1_bottom_region := not(ball_above_paddle_1_middle) and not(ball_in_paddle_1_middle_region);
         --If there is no overlapping of the ball and the paddle, all flags are 
         --set to 0.
         else
            ball_in_paddle_1_top_region := '0';
            ball_in_paddle_1_middle_region := '0';
            ball_in_paddle_1_bottom_region := '0';
         end if;
         
         --These following block is the same as above, only for paddle 2.
         if ((ball_y_pos + G_BALL_DIAMETER / 2) < (i_player_2_pos + G_PADDLE_HEIGHT / 2)) then
            ball_above_paddle_2_middle := '1';
         else
            ball_above_paddle_2_middle := '0';
         end if;
         if ((ball_y_pos + G_BALL_DIAMETER) > i_player_2_pos and ball_y_pos < (i_player_2_pos + G_PADDLE_HEIGHT)) then
            if ((ball_y_pos + G_BALL_DIAMETER / 2) > (i_player_2_pos + G_PADDLE_SLOPE_LENGTH - 1) and (ball_y_pos + G_BALL_DIAMETER / 2) < (i_player_2_pos + G_PADDLE_HEIGHT - G_PADDLE_SLOPE_LENGTH + 1)) then
               ball_in_paddle_2_middle_region := '1';
            else
               ball_in_paddle_2_middle_region := '0';
            end if;
            ball_in_paddle_2_top_region := ball_above_paddle_2_middle and not(ball_in_paddle_2_middle_region);
            ball_in_paddle_2_bottom_region := not(ball_above_paddle_2_middle) and not(ball_in_paddle_2_middle_region);
         else
            ball_in_paddle_2_top_region := '0';
            ball_in_paddle_2_middle_region := '0';
            ball_in_paddle_2_bottom_region := '0';
         end if;
         
         --The address for the ROM is created from the velocity and direction
         --of the ball. It consists of (from MSB to LSB) the x velocity, 
         --the y direction and the y velocity.
         o_rom_address(8 downto 5) <= ball_x_velocity;
         --Because the ROM stores only data for hits to the top corners of the
         --paddles the y-direction has to be inverted if the ball hits a bottom
         --corner. (The trick is that hitting the bottom corner is the same as
         --hitting the top corner with the inverted y-direction and inverting
         --the resulting y-direction. In this case the ROM output representing
         --the new y-direction has to be inverted too. This is done later.)
         if ((ball_x_direction = '1' and ball_above_paddle_1_middle = '1') or (ball_x_direction = '0' and ball_above_paddle_2_middle = '1')) then
            o_rom_address(4) <= ball_y_direction;
         else
            o_rom_address(4) <= not(ball_y_direction);
         end if;
         o_rom_address(3 downto 0) <= ball_y_velocity;
         
         
         --Synchronous reset
         if (reset = '1') then
            cnt_ball_x_movement_timer <= (others => '0');
            cnt_ball_y_movement_timer <= (others => '0');
            ball_x_pos <= G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
            ball_y_pos <= G_V_RESOLUTION / 2 - G_BALL_DIAMETER / 2;
            ball_x_direction <= '0';
            ball_y_direction <= '0';
            ball_x_velocity <= (others => '0');
            ball_y_velocity <= (others => '0');
            o_point_player_1 <= '0';
            o_point_player_2 <= '0';
         
         
         --During serving (ball is bound to the paddle of the serving player).
         elsif (i_ball_free = '0') then
            --Each cycle a new value from the random number generator is 
            --assigned to the ball direction and velocity signals. The ball 
            --x-direction is only dependent of the serving player.
            ball_x_direction <= i_serving_player;
            ball_y_direction <= i_random_number(5);
            ball_x_velocity <= "01" & i_random_number(4 downto 3);
            ball_y_velocity <= '1' & i_random_number(2 downto 0);
            cnt_ball_x_movement_timer <= (others => '0');
            cnt_ball_y_movement_timer <= (others => '0');   
            
            --During serving the ball follows the paddle of the serving player.
            if (i_serving_player = '0') then
               ball_x_pos <= C_BALL_MIN_X_POS + 1;
               ball_y_pos <= i_player_1_pos + G_PADDLE_HEIGHT / 2 - G_BALL_DIAMETER / 2;
            else
               ball_x_pos <= C_BALL_MAX_X_POS - 1;
               ball_y_pos <= i_player_2_pos + G_PADDLE_HEIGHT / 2 - G_BALL_DIAMETER / 2;
            end if;
         
         
         --The ball is in motion
         --Each time the ball_event input is high there is a possibility of a
         --ball movement
         elsif (i_ball_event = '1') then
            --If the movement timer reaches the value of the ball_x_velocity 
            --signal the ball moves one pixel in x direction (either to the 
            --left or right side, according to the ball_x_direction signal, and 
            --the movement timer is set to 0.
            if (cnt_ball_x_movement_timer = unsigned(ball_x_velocity)) then
               cnt_ball_x_movement_timer <= (others => '0');
               if (ball_x_direction = '0') then
                  ball_x_pos <= ball_x_pos + 1;
               else
                  ball_x_pos <= ball_x_pos - 1;
               end if;
            --If the movement timer is not equal to the ball velocity the timer
            --is increased by 1.
            else
               cnt_ball_x_movement_timer <= cnt_ball_x_movement_timer + 1;
            end if;
            
            --The rules for movement in x-direction apply for the movement in 
            --y-direction too.
            if (cnt_ball_y_movement_timer = unsigned(ball_y_velocity)) then
               cnt_ball_y_movement_timer <= (others => '0');
               if (ball_y_direction = '0') then
                  ball_y_pos <= ball_y_pos + 1;
               else
                  ball_y_pos <= ball_y_pos - 1;
               end if;
            --No movement, the movement timer is increased
            else
               cnt_ball_y_movement_timer <= cnt_ball_y_movement_timer + 1;
            end if;
         
         
         --All collision detection is done when there is no ball event. So one 
         --cycle after a ball movement the collision detection is done, the 
         --new movement data is calculated for the next ball movement and the 
         --signals for scored points are set. 
         else
            --Collision with top border
            if (ball_y_pos = C_BALL_MIN_Y_POS) then
               ball_y_direction <= '0';
            end if;
            
            --Collision with bottom border
            if (ball_y_pos = C_BALL_MAX_Y_POS) then
               ball_y_direction <= '1';
            end if;
            
            --Collision with left border/paddle
            if (ball_x_pos = C_BALL_MIN_X_POS and ball_x_direction = '1') then
               --On each hit with the left border the x-direction has to be 
               --inverted. 
               ball_x_direction <= '0';
               --Hit in the top region. New movement data is assigned from the 
               --ROM.
               if (ball_in_paddle_1_top_region = '1') then
                  ball_x_velocity <= i_rom_data(8 downto 5);
                  ball_y_direction <= i_rom_data(4);
                  ball_y_velocity <= i_rom_data(3 downto 0);
               --Hit in the middle region. Only the x-direction has to be 
               --inverted.
               elsif (ball_in_paddle_1_middle_region = '1') then
               --Hit in the bottom region. New movement data is assigned from 
               --the ROM (Note that the y-dirction is inverted as described 
               --above).
               elsif (ball_in_paddle_1_bottom_region = '1') then
                  ball_x_velocity <= i_rom_data(8 downto 5);
                  ball_y_direction <= not(i_rom_data(4));
                  ball_y_velocity <= i_rom_data(3 downto 0);
               --No paddle hit. Player 2 scores a point.
               else
                  o_point_player_2 <= '1';
               end if;
            end if;
            
            --Collision with right border/paddle
            --Same as collision with left border, only with paddle 2.
            if (ball_x_pos = C_BALL_MAX_X_POS and ball_x_direction = '0') then
               ball_x_direction <= '1';
               if (ball_in_paddle_2_top_region = '1') then
                  ball_x_velocity <= i_rom_data(8 downto 5);
                  ball_y_direction <= i_rom_data(4);
                  ball_y_velocity <= i_rom_data(3 downto 0);
               elsif (ball_in_paddle_2_middle_region = '1') then
               elsif (ball_in_paddle_2_bottom_region = '1') then
                  ball_x_velocity <= i_rom_data(8 downto 5);
                  ball_y_direction <= not(i_rom_data(4));
                  ball_y_velocity <= i_rom_data(3 downto 0);
               else
                  o_point_player_1 <= '1';
               end if;
            end if;
         end if;
      end if;
   end process;

   --The ball position is assigned to the outputs.
   o_ball_x_pos <= ball_x_pos;
   o_ball_y_pos <= ball_y_pos;

end rtl;

