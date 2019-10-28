library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity example is
   port (clk : in std_logic := '0';
         i_in : in std_logic := '0';
         
         o_out : out std_logic := '0');
end example;



architecture rtl of example is

signal a : std_logic := '0';

begin
   process (clk)
   begin 
      if (rising_edge(clk)) then
         a <= i_in;
         o_out <= a;
      end if;
   end process;
   
end rtl;
