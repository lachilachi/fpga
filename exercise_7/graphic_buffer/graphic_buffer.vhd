library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--The graphic buffer stores the data read from the RAM and converts the parallel
--data of each colour into a serial data stream by shifting it out of the
--register one byte at a time.  A counter is also included that counts the
--number of shifts and sets an output signal if new data should be read from the RAM.

entity graphic_buffer is
  --ports:
  --clk             : pixel clock
  --reset           : synchronous reset
  --
  --i_select        : indicates if the buffer is selected
  --i_shift_enable  : enables the shift operation
  --i_load          : loads new data into the shift registers
  --i_rgb_data      : new data loaded into shift registers
  --
  --o_data_req      : output to request new data
  --o_rgb           : output of the current pixel colour 
  --                  (MSB = red, LSB = blue)
  port (clk   : in std_logic := '0';
        reset : in std_logic := '0';

        i_select       : in std_logic                          := '0';
        i_shift_enable : in std_logic                          := '0';
        i_load         : in std_logic                          := '0';
        i_rgb_data     : in std_logic_vector (32*8-1 downto 0) := (others => '0');

        o_data_req : out std_logic                     := '1';
        o_rgb      : out std_logic_vector (7 downto 0) := (others => '0'));
end graphic_buffer;



architecture rtl of graphic_buffer is
signal i : integer := 0;
signal reg : std_logic_vector (32*8-1 downto 0) := (others => '0');

begin

  process (clk)
  
  begin
    if rising_edge(clk) then
		if (reset = '1') then
			o_data_req <= '1';
			i <= 0;
		else
			if (i_select = '1' and i_shift_enable = '1' and i /= 31) then
			  reg <= "00000000" & reg(32*8-1 downto 8);
			  i <= i + 1;
			  
			  
			  
					if (i = 32 - 2) then
						o_data_req <= '1';
					end if;	
			end if;
			
			
			if (i_load = '1' and i_select = '0') then
				
				reg <= i_rgb_data;
				i <= 0;
				o_data_req <= '0';
			end if;

		end if;
    end if;
  end process;
  o_rgb <= reg (7 downto 0);
  
end rtl;
