library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seq_logic_tb is
end seq_logic_tb;



architecture beh of seq_logic_tb is

--Component of UUT
component seq_logic is
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_a : in std_logic := '0';
         i_b : in std_logic := '0';
         
         o_q : out std_logic := '0');
end component;

--Signals used to connect the UUT
signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal i_a : std_logic := '0';
signal i_b : std_logic := '0';
signal o_q : std_logic := '0';

begin
   --Instantiate UUT
   uut_seq_logic : seq_logic
      port map (clk => clk,
                reset => reset,
                i_a => i_a,
                i_b => i_b,
                o_q => o_q);
   

   process
   begin
      --Stimuli
      clk <= '0';
      i_a <= '0';
      i_b <= '0';
      wait for 5 ns;
      
      clk <= '0';
      i_a <= '0';
      i_b <= '1';
      wait for 5 ns;
      
      clk <= '0';
      i_a <= '1';
      i_b <= '1';
      wait for 5 ns;
      
      clk <= '0';
      i_a <= '1';
      i_b <= '0';
      wait for 5 ns;
      
      clk <= '1';
      wait for 5 ns;
            
      i_a <= '0';
      i_b <= '0';
      wait for 5 ns;
   
      clk <= '0';
      i_a <= '0';
      i_b <= '1';
      wait for 5 ns;
      
      clk <= '0';
      i_a <= '1';
      i_b <= '1';
      wait for 5 ns;
   
      clk <= '0';
      i_a <= '1';
      i_b <= '0';
      wait for 5 ns;
   
      clk <= '0';
      i_a <= '0';
      i_b <= '0';
      wait for 5 ns;
      
      clk <= '1';
      i_a <= '0';
      i_b <= '0';
      wait for 5 ns;
      
      clk <= '0';
      i_a <= '1';
      i_b <= '0';
      wait for 5 ns;
      
      clk <= '1';
      wait for 5 ns;
      
      reset <= '1';
      clk <= '0';
      i_a <= '1';
      i_b <= '0';
      wait for 5 ns;
      
      clk <= '1';
      
      wait for 10 ns;
      wait;
      
   end process;
   
end beh;
