library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This module generates events for ball or paddle movement. This is done with
--a counter for each event. When the counter reaches its limit it is reset
--to 0 and the event output signal is set to 1 for one clock cycle.

entity event_trigger is
   --generics: 
   --G_PADDLE_EVENT_INTERVAL  : clock cycles between two paddle events
   --G_BALL_EVENT_INTERVAL    : clock cycles between two ball events
   generic (G_PADDLE_EVENT_INTERVAL : integer := 100000;
            G_BALL_EVENT_INTERVAL : integer := 20000);
   
   --ports:
   --clk             : system clock
   --reset           : synchronous reset
   --
   --o_paddle_event  : set to one if a paddle event occurs
   --o_ball_event    : set to one if a ball event occurs
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         o_paddle_event : out std_logic := '0';
         o_ball_event : out std_logic := '0');
end event_trigger;



architecture rtl of event_trigger is



begin






  
end rtl;

