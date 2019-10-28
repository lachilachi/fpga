library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This module controls the state of the game and which player has the right 
--to serve.
--It consists of two state machines. The first counts the points and enables 
--or disables ball and paddle movement. The second one changes the serving 
--player after five points.

entity game_states is
   --generics:
   --G_POINTS_TO_WIN    : points needed to win the game
   generic (G_POINTS_TO_WIN : integer := 15);
   
   --ports:
   --clk                         : system clock
   --reset                       : synchronous reset
   --
   --i_serve_key                 : signalises that the serve key is pressed
   --i_point_player_1            : signalises that player 1 scored one point
   --i_point_player_2            : signalises that player 1 scored one point
   --
   --o_ball_free                 : signalises if the ball is free to move or if
   --                              it is bound to a paddle
   --o_serving_player            : identifies the serving player (0 for 
   --                              player 1, 1 for player 2)
   --o_enable_movement           : signalises if the movement of the paddles
   --                              is allowed
   --o_reset_ball_and_paddles    : resets the ball and paddle positions to
   --                              their default values
   --o_player_1_points           : points of player 1
   --o_player_2_points           : points of player 2
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_serve_key : in std_logic := '0';
         i_point_player_1 : in std_logic := '0';
         i_point_player_2 : in std_logic := '0';
         
         o_ball_free : out std_logic := '0';
         o_serving_player : out std_logic := '0';
         o_enable_movement : out std_logic := '0';
         o_reset_ball_and_paddles : out std_logic := '0';
         o_player_1_points : out integer range 0 to G_POINTS_TO_WIN := 0;
         o_player_2_points : out integer range 0 to G_POINTS_TO_WIN := 0);
end game_states;



architecture rtl of game_states is

--Constant used to define the time in clock cycles the game freezes after a
--player scores a point.
--Changed for Simulation. Standard value is 100000000.
constant C_WAIT_TIME : integer := 2;

--These types are used to define the states of the two state machines used.
type t_state_game is (SERVE, PLAYING, WAITING, WON);
type t_state_serve is (PLAYER_1, PLAYER_2);

--Signals set in process 1
--State of the state machine
signal state_game : t_state_game := SERVE;
--Counter for points
signal cnt_player_1_points : integer range 0 to G_POINTS_TO_WIN := 0;
signal cnt_player_2_points : integer range 0 to G_POINTS_TO_WIN := 0;
--Counter for waittime after a player has scored a point
signal cnt_wait_time : integer range 0 to C_WAIT_TIME := 0;

--Signals set in process 2
--State of the state machine
signal state_serve : t_state_serve := PLAYER_1;
--Counter for serves
signal cnt_serves : integer range 0 to 4 := 0;

begin
   --Type : registered Mealy state machine
   --       States : SERVE    : during serving
   --                           the ball is bound to the serving player's 
   --                           paddle, paddle movement is allowed
   --                PLAYING  : normal playing
   --                           ball and paddle movement is allowed
   --                WAITING  : waiting after scoring a point
   --                           ball and paddle movement is disabled
   --                WON      : one player has won
   --                           ball and paddle movement is disabled
   --                
   --Description : This process is responsible for counting points and 
   --    enabling or disabling the ball and paddle movement. It also resets
   --    the ball and paddle movemnt modules after a point has been scored.
   process (clk)
   begin
      if (clk'event and clk = '1') then
         --Synchronous reset
         if (reset = '1') then
            state_game <= SERVE;
            cnt_player_1_points <= 0;
            cnt_player_2_points <= 0;
            o_ball_free <= '0';
         --Normal operation
         else
            --This checks in which state the machine is and executes 
            --transitions between states. Because it is a Mealy machine all 
            --outputs are set during the transition.
            case state_game is
            when SERVE =>
               --Move to PLAYING if serve key is pressed
               if (i_serve_key = '1') then
                  state_game <= PLAYING;
                  o_ball_free <= '0';
                  o_enable_movement <= '1';
                  o_reset_ball_and_paddles <= '0';
               --Stay in state
               else
                  o_ball_free <= '0';
                  o_enable_movement <= '1';
                  o_reset_ball_and_paddles <= '0';
               end if;
            when PLAYING =>
               --Player 1 scored a point.
               if (i_point_player_1 = '1') then
                  state_game <= WAITING;
                  cnt_player_1_points <= cnt_player_1_points + 1;
                  o_ball_free <= '1';
                  o_enable_movement <= '0';
                  o_reset_ball_and_paddles <= '0';
               --Player 1 scored a point.
               elsif (i_point_player_2 = '1') then
                  state_game <= WAITING;
                  cnt_player_2_points <= cnt_player_2_points + 1;
                  o_ball_free <= '1';
                  o_enable_movement <= '0';
                  o_reset_ball_and_paddles <= '0';
               --Stay in state
               else  
                  o_ball_free <= '1';
                  o_enable_movement <= '1';
                  o_reset_ball_and_paddles <= '0';
               end if;
            when WAITING =>
               --If the wait time has passed check what transition to take
               if (cnt_wait_time = C_WAIT_TIME) then
                  cnt_wait_time <= 0;
                  --If one player has reaches the number of points to win the 
                  --game, the state is changed to WON.
                  if (cnt_player_1_points = G_POINTS_TO_WIN or cnt_player_2_points = G_POINTS_TO_WIN) then
                     state_game <= WON;
                     o_ball_free <= '0';
                     o_enable_movement <= '0';
                     o_reset_ball_and_paddles <= '0';
                  --Move to SERVE state, the ball and paddle movement modules
                  --are reset.
                  else
                     state_game <= SERVE;
                     o_ball_free <= '0';
                     o_enable_movement <= '1';
                     o_reset_ball_and_paddles <= '1';
                  end if;
               --Stay in state and increase the wait timer
               else 
                  cnt_wait_time <= cnt_wait_time + 1;
                  o_ball_free <= '1';
                  o_enable_movement <= '0';
                  o_reset_ball_and_paddles <= '0';
               end if;
            when WON =>
               --The game stays in the WON state until a reset occurs
               o_ball_free <= '0';
               o_enable_movement <= '0';
               o_reset_ball_and_paddles <= '0';
            end case;
         end if;
      end if;
   end process;
   
   --The point counters are assigned to the outputs
   o_player_1_points <= cnt_player_1_points;
   o_player_2_points <= cnt_player_2_points;
   
   
   
   --Type : registered Moore state machine
   --       States : PLAYER_1 : Serving player is player 1
   --                PLAYER_2 : Serving player is player 2
   --Description : This process is responsible for changing the serving player 
   --    after five serves.
   process (clk)
   begin
      if (clk'event and clk = '1') then
         --Synchronous reset
         if (reset = '1') then
            state_serve <= PLAYER_1;
            cnt_serves <= 0;
         --If a player score a point a counter is increased. After five serves
         --the state changes.
         elsif ((i_point_player_1 = '1' or i_point_player_2 = '1') and state_game = PLAYING) then
            --Change serving player
            if (cnt_serves = 4) then
               cnt_serves <= 0;
               if (state_serve = PLAYER_1) then
                  state_serve <= PLAYER_2;
               else
                  state_serve <= PLAYER_1;
               end if;
            --Increase counter
            else
               cnt_serves <= cnt_serves + 1;
            end if;
         end if;
      end if;
   end process;
   
   --Assign a value to the serving player output from the state of the above 
   --state machine
   o_serving_player <= '0' when ((state_serve = PLAYER_1 and cnt_player_2_points /= G_POINTS_TO_WIN) or cnt_player_1_points = G_POINTS_TO_WIN)
                  else '1';
   
end rtl;

