library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.game_engine_package.ALL;

--This module is responsible for the movement of the ball and paddles, managing 
--the gamedata and reacting to player inputs. So this is the part where the 
--game runs. All other modules are just used to control the hardware of the 
--FPGA board.
--The game engine has an independent reset. This reset is triggered by the 
--reset key from the keyboard. It only resets the gamedata while all 
--other modules remain unaffected. This is usefull because the global reset 
--would cause a resynchronisation of the display, leaving the screen black 
--during this time.
--
--Game rules:
--During serving the ball is stuck to the serving player's paddle until the 
--serve key is pressed. Both paddles can be moved. When the serve key is 
--pressed the ball is released and moves in a random direction at a random 
--speed. The ball is reflected by the top and bottom borders of the field or by 
--the players' paddles. The corners of the paddles are designed to have a slope 
--so that the angle of the incoming ball is not equal the angle of the 
--reflected ball. The size of this slope can be changed with generics and to 
--change the angle a different package file for the ROM is needed.
--If the ball misses one players paddle the other player scores a point. If one 
--player has won enough points the game freezes until the reset key is pressed.
--The serving player changes after each five points scored.
--
--Implementation:
--Because of the high system clock frequency it is necessary to create a 
--'slower' signal for the paddle and ball movement. This is done by the event 
--trigger. It simply divides the clock by a constant factor. So each time the 
--trigger creates an event for the ball or paddles they can move one pixel.
--For more details see the corresponding modules.
--The random movement data of the ball on a serve is taken from a random number 
--generator.
--The points and the serving player are managed in the game state module. It 
--also controls the state of the game (e.g. serving, normal play or game won) 
--and enables or disables ball and paddle movement.
--Ball and paddle movement is handled separately by two modules. The ball 
--movement module also handles collisions of the ball and signalises when one 
--player scored a point.
--The new direction and speed of the ball ball after hitting the paddle corners 
--is taken from a ROM that is fed with the movement data of the ball before the 
--collision.

entity game_engine is
   --generics:
   --G_H_RESOLUTION              : horizontal resolution
   --G_V_RESOLUTION              : vertical resolution
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
   --G_PLAYER_POS_SIGNAL_RANGE   : maximum value for the position of the 
   --                              paddles
   --G_BALL_X_POS_SIGNAL_RANGE   : maximum value for the x position of the ball
   --G_BALL_Y_POS_SIGNAL_RANGE   : maximum value for the y position of the ball
   --
   --G_POINTS_TO_WIN             : points needed to win the game
   generic (G_H_RESOLUTION : integer := 640;
            G_V_RESOLUTION : integer := 480;
            
            G_PADDLE_EVENT_INTERVAL : integer := 100000;
            G_BALL_EVENT_INTERVAL : integer := 20000;
            
            G_BORDER_THICKNESS : integer := 2;
            G_PADDLE_TO_BORDER_SPACE : integer := 2;
            G_PADDLE_HEIGHT : integer := 91;
            G_PADDLE_WIDTH : integer := 15;
            G_PADDLE_SLOPE_LENGTH : integer := 10;
            G_BALL_DIAMETER : integer := 17;
            
            G_PLAYER_POS_SIGNAL_RANGE : integer := 387;
            G_BALL_X_POS_SIGNAL_RANGE : integer := 604;
            G_BALL_Y_POS_SIGNAL_RANGE : integer := 461;
            
            G_POINTS_TO_WIN : integer := 15);
   
   --ports:
   --clk                : system clock
   --reset              : synchronous reset
   --
   --i_player_1_up      : \
   --i_player_1_down    : | signals for player movement keys
   --i_player_2_up      : |
   --i_player_2_down    : /
   --i_serve_key        : input for serve key
   --
   --o_player_1_pos     : \
   --o_player_2_pos     : | position of player 1 and 2 and the ball x- and
   --o_ball_x_pos       : | y-position
   --o_ball_y_pos       : /
   --o_player_1_points  : points of player 1
   --o_player_2_points  : points of player 1
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_player_1_up : in std_logic := '0';
         i_player_1_down : in std_logic := '0';
         i_player_2_up : in std_logic := '0';
         i_player_2_down : in std_logic := '0';
         i_serve_key : in std_logic := '0';
         
         o_player_1_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
         o_player_2_pos : out integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
         o_ball_x_pos : out integer range 0 to G_BALL_X_POS_SIGNAL_RANGE := G_BORDER_THICKNESS + G_PADDLE_TO_BORDER_SPACE + G_PADDLE_WIDTH + 1;
         o_ball_y_pos : out integer range 0 to G_BALL_Y_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_BALL_DIAMETER / 2;
         o_player_1_points : out integer range 0 to G_POINTS_TO_WIN := 0;
         o_player_2_points : out integer range 0 to G_POINTS_TO_WIN := 0);
end game_engine;



architecture rtl of game_engine is

--Signals for the paddle and ball events that can be switched on or off by the 
--enable movement signal.
signal paddle_event_switched : std_logic := '0';
signal ball_event_switched : std_logic := '0';
--Reset signal to reset the ball movement and paddle movement instances
signal reset_ball_and_paddles : std_logic := '0';

--The following signals are used to connect the instances
signal paddle_event_sig : std_logic := '0';
signal ball_event_sig : std_logic := '0';
signal random_number_sig : std_logic_vector (5 downto 0) := (others => '0');
signal player_1_pos_sig : integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
signal player_2_pos_sig : integer range 0 to G_PLAYER_POS_SIGNAL_RANGE := G_V_RESOLUTION / 2 - G_PADDLE_HEIGHT / 2;
signal point_player_1_sig : std_logic := '0';
signal point_player_2_sig : std_logic := '0';
signal ball_free_sig : std_logic := '0';
signal serving_player_sig : std_logic := '0';
signal enable_movement_sig : std_logic := '0';
signal reset_ball_and_paddles_sig : std_logic := '0';
signal rom_data_sig : std_logic_vector (8 downto 0) := (others => '0');
signal rom_address_sig : std_logic_vector (8 downto 0) := (others => '0');

begin
   
   --Generates paddle and ball events on which the ball and paddles can be 
   --moved
   event_trigger_inst : event_trigger
      generic map (G_PADDLE_EVENT_INTERVAL,
                   G_BALL_EVENT_INTERVAL)
      
      port map (clk => clk,
                reset => reset,
                
                o_paddle_event => paddle_event_sig,
                o_ball_event => ball_event_sig);

   --Generates random numbers used during serving
   random_number_generator_inst : random_number_generator
      port map (clk => clk,
                
                o_random_number => random_number_sig);

   --Stores relevant gamedata (e.g. points, and number of serves)
   game_states_inst : game_states
      generic map (G_POINTS_TO_WIN)
      
      port map (clk => clk,
                reset => reset,
                
                i_serve_key => i_serve_key,
                i_point_player_1 => point_player_1_sig,
                i_point_player_2 => point_player_2_sig,
                
                o_ball_free => ball_free_sig,
                o_serving_player => serving_player_sig,
                o_enable_movement => enable_movement_sig,
                o_reset_ball_and_paddles => reset_ball_and_paddles_sig,
                o_player_1_points => o_player_1_points,
                o_player_2_points => o_player_2_points);

   --Controls the paddle movement
   paddle_movement_inst : paddle_movement
      generic map (G_V_RESOLUTION,
                   
                   G_BORDER_THICKNESS,
                   G_PADDLE_HEIGHT,
                   
                   G_PLAYER_POS_SIGNAL_RANGE)
      
      port map (clk => clk,
                reset => reset_ball_and_paddles,
                
                i_paddle_event => paddle_event_switched,
                i_player_1_up => i_player_1_up,
                i_player_1_down => i_player_1_down,
                i_player_2_up => i_player_2_up,
                i_player_2_down => i_player_2_down,
                
                o_player_1_pos => player_1_pos_sig,
                o_player_2_pos => player_2_pos_sig);

   --Controls the ball movement and does the collision detection for the ball
   ball_movement_inst : ball_movement
      generic map (G_H_RESOLUTION,
                   G_V_RESOLUTION,
                   
                   G_BORDER_THICKNESS,
                   G_PADDLE_TO_BORDER_SPACE,
                   G_PADDLE_HEIGHT,
                   G_PADDLE_WIDTH,
                   G_PADDLE_SLOPE_LENGTH,
                   G_BALL_DIAMETER,
                   
                   G_PLAYER_POS_SIGNAL_RANGE,
                   G_BALL_X_POS_SIGNAL_RANGE,
                   G_BALL_Y_POS_SIGNAL_RANGE)
      
      port map (clk => clk,
                reset => reset_ball_and_paddles,
                
                i_ball_event => ball_event_switched,
                i_random_number => random_number_sig,
                i_ball_free => ball_free_sig,
                i_serving_player => serving_player_sig,
                i_player_1_pos => player_1_pos_sig,
                i_player_2_pos => player_2_pos_sig,
                i_rom_data => rom_data_sig,
                
                o_point_player_1 => point_player_1_sig,
                o_point_player_2 => point_player_2_sig,
                o_ball_x_pos => o_ball_x_pos,
                o_ball_y_pos => o_ball_y_pos,
                o_rom_address => rom_address_sig);
   
   --ROM for new movement data after paddle corner collision
   rom_inst : rom
      port map (i_rom_address => rom_address_sig,
                
                o_rom_data => rom_data_sig);


   --The player positions are assigned to the outputs
   o_player_1_pos <= player_1_pos_sig;
   o_player_2_pos <= player_2_pos_sig;
   
   --The paddle and ball event signals can be switched on or off with the 
   --enable_movement_sig signal. When switched off, no event signals will reach 
   --the paddle or ball movement modules.
   paddle_event_switched <= paddle_event_sig and enable_movement_sig;
   ball_event_switched <= ball_event_sig and enable_movement_sig;
   
   --The reset of the ball_movement and the paddle_movement instances is 
   --possible with the global reset or a special local reset signal.
   --After one player scores one point both instances are reset by the 
   --reset_ball_and_paddle_sig signal.
   reset_ball_and_paddles <= reset or reset_ball_and_paddles_sig;
end rtl;

