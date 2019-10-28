----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:59:52 11/17/2014 
-- Design Name: 
-- Module Name:    rom2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rom is
    Port ( i_rom_address : in  STD_LOGIC_VECTOR (2 downto 0);
           o_rom_data : out  STD_LOGIC_VECTOR (31 downto 0)
			  );
end rom;

architecture Behavioral of rom is

type t_rom is array (0 to 7) of std_logic_vector (31 downto 0);
------------------------------------
--# ###   #   # ### #  #          --
--# # #   #   #   # #  #          -- 
--# # #   #   #  ## ####          --
--  # #   #   #   # #  #          --
--# ### ### ### ### #  #          --
--                                --
--                                --
--                                --                                
------------------------------------
constant C_ROM_CONTENT : t_rom := (
			"10111000100010111010010000000000",
			"10101000100010001010010000000000",
			"10101000100010011011110000000000",
			"00101000100010001010010000000000",
			"10111011101110111010010000000000",
			"00000000000000000000000000000000",
			"00000000000000000000000000000000",
			"00000000000000000000000000000000"); --line 8

begin

		o_rom_data <= C_ROM_CONTENT(to_integer(unsigned(i_rom_address)));

end Behavioral;

