library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Moore state machine

entity moore_fsm is
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';

         i_a : in std_logic := '0';
         i_b : in std_logic := '0';

         o_c : out std_logic := '0';
         o_d : out std_logic := '0');
end moore_fsm;



architecture rtl of moore_fsm is



end rtl;

