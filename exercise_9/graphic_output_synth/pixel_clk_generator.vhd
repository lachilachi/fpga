library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity pixel_clk_generator is
  port (clk : in std_logic := '0';

        o_pixel_clk : out std_logic := '0');
end pixel_clk_generator;



architecture rtl of pixel_clk_generator is

  signal pixel_clk : std_logic := '0';
  signal i         : std_logic := '0';
begin

  process (clk)
  begin
    if (rising_edge(clk)) then
      i <= not i;
      if i = '1' then
        pixel_clk <= not(pixel_clk);
      end if;
    end if;
  end process;

  o_pixel_clk <= pixel_clk;
end rtl;

