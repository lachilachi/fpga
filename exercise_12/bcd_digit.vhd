library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This module is one digit of a binary to bcd conversion system. The exact 
--behaviour is described in the Xilinx application note XAPP029 available on
--the Xilinx homepage.

entity bcd_digit is
   --ports:
   --clk             : system clock
   --reset           : synchronous reset
   --
   --i_serial_data   : serial input for the binary number (MSB first) or the
   --                  carry bit from the previous digit
   --
   --o_carry         : output of carry bit (connected with i_serial_data of the
   --                  following digit
   --o_bcd           : output for the bcd coded digit
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_serial_data : in std_logic := '0';
         
         o_carry : out std_logic := '0';
         o_bcd : out std_logic_vector (3 downto 0) := (others => '0'));
end bcd_digit;



architecture rtl of bcd_digit is

--Shift register to store the bits of the converted digit.
signal sr_bcd : std_logic_vector (3 downto 0) := (others => '0');

begin
   --Type : registered
   --Description : This process performs a left shift on the shift register and
   --    concatenates the serial input to the LSB of the shift register. If the 
   --    result of this shifting would be greater than 10, the three most 
   --    significant bits are fed from the shift operation, but loaded with 
   --    values so that the value of the whole shift register is the value of 
   --    the shift operation minus 10 (see below for examples).
   process (clk)
   begin
      if (clk'event and clk = '1') then
         --Synchronous reset
         if (reset = '1') then
            sr_bcd(3 downto 0) <= (others => '0');
         --Perform a shift operation but limit the value to numbers below 10.
         else
            case sr_bcd is
            --Current value is 5. The value after the shifting would be 10 or 
            --11. After subtracting 10 it will be 0 or 1. So the three MSBs 
            --must be loaded with zeros.
            when "0101" =>
               sr_bcd <= "000" & i_serial_data;
            when "0110" =>
               sr_bcd <= "001" & i_serial_data;
            when "0111" =>
               sr_bcd <= "010" & i_serial_data;
            when "1000" =>
               sr_bcd <= "011" & i_serial_data;
            when "1001" =>
               sr_bcd <= "100" & i_serial_data;
            when others =>
               sr_bcd <= sr_bcd(2 downto 0) & i_serial_data;
            end case;
         end if;
      end if;
   end process;

   --Type : logic
   --Description : This process sets the carry output if the value of the shift 
   --    register will be more than 10 after the next shift operation (a left 
   --    shift at least doubles the value of the shift register, so if the 
   --    current value is 5 or bigger it will exceed the 10 after the next 
   --    shift operation and the carry bit is set)
   --Input signals : 
   --Output signals :
   process (sr_bcd)
   begin
      case sr_bcd is
      when "0101" | "0110" | "0111" | "1000" | "1001" =>
         o_carry <= '1';
      when others =>
         o_carry <= '0';
      end case;
   end process;

   --The shift register is assigned to the output
   o_bcd <= sr_bcd;

end rtl;

