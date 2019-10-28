library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg_tb is
end reg_tb;



architecture beh of reg_tb is

--Component Declaration for the Unit Under Test (UUT)   
component reg is
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_d : in std_logic := '0';
         
         o_q : out std_logic := '0');
end component;


--Signals to connect the Unit Under Test (UUT)
signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal i_d : std_logic := '0';
signal o_q : std_logic := '0';

--Signals used for simulation
signal stop_simulation : std_logic := '0';

begin
   
   --Instantiate the Unit Under Test (UUT)
   uut_reg : reg
      port map (clk => clk,
                reset => reset,
                i_d => i_d,
                o_q => o_q);

                
   --Clock
   process
   begin
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      
      if (stop_simulation = '1') then
         wait;
      end if;
   end process;
   

   process
   begin
      
      wait for 2 ns;
      i_d <= '1';
      wait until clk'event;      --rising
      wait for 1 ns;
      assert (o_q = '1') report "Error!!!" severity error;
      
      wait for 1 ns;
      i_d <= '0';
      wait until clk'event;      --falling
      wait for 1 ns;
      assert (o_q = '1') report "Error!!!" severity error;
      wait until clk'event;      --rising
      wait for 1 ns;
      assert (o_q = '0') report "Error!!!" severity error;
      
      wait for 1 ns;
      i_d <= '1';
      wait for 1 ns;
      assert (o_q = '0') report "Error!!!" severity error;
      wait until clk'event;      --falling
      wait for 1 ns;
      assert (o_q = '0') report "Error!!!" severity error;
      wait for 1 ns;
      i_d <= '0';
      wait until clk'event;      --rising
      wait for 1 ns;
      assert (o_q = '0') report "Error!!!" severity error;
      
      wait until clk'event;      --falling
      wait for 1 ns;
      assert (o_q = '0') report "Error!!!" severity error;
      wait for 1 ns;
      i_d <= '1';
      wait until clk'event;      --rising
      wait for 1 ns;
      assert (o_q = '1') report "Error!!!" severity error;
      wait for 1 ns;
      reset <= '1';
      wait for 1 ns;
      assert (o_q = '1') report "Error!!!" severity error;
      wait until clk'event;      --falling   
      wait for 1 ns;
      assert (o_q = '1') report "Error!!!" severity error;
      wait until clk'event;      --rising
      wait for 1 ns;
      assert (o_q = '0') report "Error!!!" severity error;
      
      stop_simulation <= '1';
      wait;
   end process;

end beh;
