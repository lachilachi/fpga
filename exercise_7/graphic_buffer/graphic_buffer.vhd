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


begin

  process (clk)
  begin
    if rising_edge(clk) then

    end if;
  end process;
  
end rtl;
