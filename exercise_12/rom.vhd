library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rom_package.ALL;

--This module is the ROM from which the new velocity data is read if the ball
--hits the paddle corners.
--The ROM data is stored in a constant that is declared in a package file.
--To change the angle of the paddle slope, the data in the package file needs 
--to be changed.

entity rom is
   --ports:
   --i_rom_address      : address input
   --
   --o_rom_address      : data output
   port (i_rom_address : in std_logic_vector (8 downto 0) := (others => '0');
         
         o_rom_data : out std_logic_vector (8 downto 0) := (others => '0'));
end rom;



architecture rtl of rom is
begin
   --The ROM works asynchronous.
   --Each time the address input changes the new data is read from the 
   --constrant and assigned to the data output.
   o_rom_data <= C_ROM(to_integer(unsigned(i_rom_address)));
   
end rtl;

