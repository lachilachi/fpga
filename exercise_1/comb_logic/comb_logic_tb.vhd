library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comb_logic_tb is
end comb_logic_tb;



architecture beh of comb_logic_tb is

--Component Declaration for the Unit Under Test (UUT)   
component comb_logic is
   port (i_a : in std_logic := '0';
         i_b : in std_logic := '0';
         
         o_c : out std_logic := '0');
end component;


--Signals to connect the Unit Under Test (UUT)
signal i_a : std_logic := '0';
signal i_b : std_logic := '0';
signal o_c : std_logic := '0';

--Signals used for simulation

begin
   
   --Instantiate the Unit Under Test (UUT)
   uut_combinational_logic : comb_logic
      port map (i_a => i_a,
                i_b => i_b,
                o_c => o_c);

                
   --Truth table of the UUT:
   --i_a    i_b      o_c
   -- 0      0        0
   -- 0      1        0
   -- 1      0        1
   -- 1      1        0
   process
   begin
      i_a <= '0';
      i_b <= '0';
      wait for 10 ns;
      assert (o_c = '0') report "Error: got '1', expected '0'" severity error;

      i_a <= '0';
      i_b <= '1';
      wait for 10 ns;
      assert (o_c = '0') report "Error: got '1', expected '0'" severity error;

      i_a <= '1';
      i_b <= '0';
      wait for 10 ns;
      assert (o_c = '1') report "Error: got '0', expected '1'" severity error;

      i_a <= '1';
      i_b <= '1';
      wait for 10 ns;
      assert (o_c = '0') report "Error: got '1', expected '0'" severity error;
      
      wait;
   end process;

end beh;
