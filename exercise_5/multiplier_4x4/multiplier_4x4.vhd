library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity multiplier_4x4 is

  port (clk   : in std_logic := '0';
        reset : in std_logic := '0';

        i_a : in std_logic_vector (3 downto 0) := (others => '0');
        i_b : in std_logic_vector (3 downto 0) := (others => '0');

        o_p : out std_logic_vector (7 downto 0) := (others => '0'));

end multiplier_4x4;

architecture rtl of multiplier_4x4 is




  
  
begin



  io_register : process (clk)
  begin  -- process mult
    if rising_edge(clk) then            -- rising clock edge
      if reset = '1' then               -- synchronous reset (active high)

        
        
      else


        
      end if;
    end if;
  end process io_register;

----------------------------------------------------------------------------------------------------
-- Generate statements
-- nested loop with j = row, i = column
--------------------------------------------------------------------------------------------------------------

  row : for j in 0 to 3 generate
    column : for i in 0 to 3 generate




      



      
    end generate column;
  end generate row;

end rtl;
