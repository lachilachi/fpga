library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counter_tb is
end;



architecture beh of counter_tb is

--Component Declaration for the Unit Under Test (UUT)
component counter
   port(clk : in std_logic;  
        ncl : in std_logic;
        reset : in std_logic;
        i_enable : in std_logic;
        o_count_neg : out std_logic_vector (5 downto 0));
end component;


--Signals to connect the Unit Under Test (UUT)
signal clk : std_logic := '0';
signal ncl : std_logic := '0';
signal reset : std_logic := '0';
signal i_enable : std_logic := '0';
signal o_count_neg : std_logic_vector (5 downto 0) := (others => '0');

--Signals used for simulation
signal stop_simulation : std_logic := '0';

begin
   --Instantiate the Unit Under Test (UUT)
   uut_counter : counter
      port map (clk => clk, 
                ncl => ncl,
                reset => reset,
                i_enable => i_enable,
                o_count_neg => o_count_neg);


   --Clock
   process
   begin
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      
      --Stop the simulation
      if (stop_simulation = '1') then
         wait;
      end if;
   end process;


   --Stop the simulation
   process
   begin
      wait for 1600 ns;
      stop_simulation <= '1';
      wait;
   end process;
   

   --Resetting and enabling the UUT
   ncl <= '0', '1' after 90 ns;
   reset <= '0', '1' after 280 ns, '0' after 320 ns;
   i_enable <= '1', '0' after 200 ns, '1' after 240 ns;
end beh;