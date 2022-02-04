library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This module generates pseudo random numbers from a linear feedback register.
--Once it is started it generates a sequence of random numbers between 1 and
--63 (2^6 - 1).

entity random_number_generator is
   --ports:
   --clk                   : sytem clock
   --
   --o_random_number       : the output for the random number
   port (clk : in std_logic := '0';
         
         o_random_number : out std_logic_vector (5 downto 0) := (others => '1'));
end random_number_generator;



architecture rtl of random_number_generator is
      signal seed : std_logic_vector(5 downto 0) := (others => '1');

begin
      if rising_edge(clk) then
            seed(5 downto 1)<= seed(4 downto 0);
                seed(0) <= (seed(5) XOR seed(4));
      end if;
      o_random_number <= seed;
end rtl;

