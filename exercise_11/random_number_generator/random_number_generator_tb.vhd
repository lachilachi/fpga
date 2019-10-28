library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Simulated time needed : 1300 ns
--
--The testbench checks if all numbers between 1 and 63 have been generated.
--This should happen after 63 clock cycles and is indicated by the signal 
--all_numbers_present going from 0 to 1.

entity random_number_generator_tb is
end random_number_generator_tb;



architecture beh of random_number_generator_tb is

--Component declaration for the Unit Under Test (UUT)
component random_number_generator
   port (clk : in std_logic;
         
         o_random_number : out std_logic_vector(5 downto 0));
end component;


--Signal to indicate that all numbers between 1 and 63 have been generated
signal all_numbers_present : std_logic := '0';
--Counter for number of clock cycles needed to generate all random numbers
signal cnt_cycles : integer := 1;

--Signals to connect the Unit Under Test (UUT)
signal clk : std_logic := '0';
signal o_random_number : std_logic_vector(5 downto 0) := (others => '0');

begin
   --Instantiate the Unit Under Test (UUT)
   uut_random_number_generator : random_number_generator 
	   port map (clk => clk,
	             o_random_number => o_random_number);
   
   
   --Clock
   process
   begin
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
      
      --Stop the simulation
      if (all_numbers_present = '1') then
         wait;
      end if;
   end process;
   
   
   --Checks if all numbers have been generated and counts the clock cycles 
   --needed.
   process (clk)
   
   --Vector used to store if a number was generated. If element n = 1 then the 
   --number n has been generated.
   variable test_vector : std_logic_vector (63 downto 1) := (others => '0');
   --Variable used to check all vector elements
   variable test : std_logic := '1';
   --Counter
   variable cnt : integer := 0;
   
   begin
      if (clk'event and clk = '1') then
         --Set vectorelement to 1
         test_vector (to_integer(unsigned(o_random_number))) := '1';
         --Set variable to initial value
         test := '1';
         
         --Increase the cycle counter
         cnt_cycles <= cnt_cycles + 1;
         
         --Check if all elements of the vector are 1
         for cnt in 63 downto 1 loop
            test := test and test_vector(cnt);
         end loop;
         
         --If all elements are 1 set all_numbers_present to 1
         if (test = '1') then
            all_numbers_present <= '1';
         else
            all_numbers_present <= '0';
         end if;
      end if;
   end process;
   
end beh;
