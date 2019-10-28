library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pixel_clk_generator is
   port (i_pixel_clk : in std_logic := '0';
         
         o_pixel_clk : out std_logic := '0');
end pixel_clk_generator;



architecture rtl of pixel_clk_generator is

signal pixel_clk : std_logic := '0';

begin
   
   process (i_pixel_clk)
   begin
      --Divide the i_pixel_clk signal by two
      if (i_pixel_clk'event and i_pixel_clk = '1') then
         pixel_clk <= not(pixel_clk);
      end if;
   end process;

   o_pixel_clk <= pixel_clk;
end rtl;

