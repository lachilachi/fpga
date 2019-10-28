library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--This module keeps the reset signal active for some time even after the reset 
--key is released. This ensures that all processes (especially those not 
--synchronous with the system clock) get a valid reset signal and that bouncing 
--effects of the switch can be neglected.

entity reset_circuit is
  --ports:
  --clk          : system clock
  --
  --i_reset      : input directly from the reset switch
  --
  --o_reset      : generated reset signal
  port (clk : in std_logic := '0';

        i_reset : in std_logic := '1';

        o_reset : out std_logic := '1');
end reset_circuit;



architecture rtl of reset_circuit is

--Counter used to delay the negative edge of the generated reset signal.
  signal cnt_cycle_counter : integer range 0 to 1023 := 0;

begin
  --Type : registered
  --Description : Delays negative edge of reset signal.
  process (clk)
  begin
    if (clk'event and clk = '1') then
      --When the reset key is pressed, the counter is set to 0 and the
      --generated reset signal is set to one.
      if (i_reset = '1') then
        cnt_cycle_counter <= 0;
        o_reset           <= '1';
      --When the conter reaches its maximum the generated reset signal is
      --set to zero.
      elsif (cnt_cycle_counter = 1023) then
        o_reset <= '0';
      --The counter is increased by one each clock cycle and the output
      --reset is set to one.
      else
        cnt_cycle_counter <= cnt_cycle_counter + 1;
        o_reset           <= '1';
      end if;
    end if;
  end process;
end rtl;

