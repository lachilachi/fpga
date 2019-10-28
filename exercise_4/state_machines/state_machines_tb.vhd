library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity state_machines_tb is
end state_machines_tb;



architecture beh of state_machines_tb is

--Component Declaration for the Unit Under Test (UUT)
component moore_fsm is
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_a : in std_logic := '0';
         i_b : in std_logic := '0';
         
         o_c : out std_logic := '0';
         o_d : out std_logic := '0');
end component;

component mealy_fsm is
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';

         i_a : in std_logic := '0';
         i_b : in std_logic := '0';

         o_c : out std_logic := '0';
         o_d : out std_logic := '0');
end component;



--Signals to connect the Unit Under Test (UUT)
signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal i_a : std_logic := '0';
signal i_b : std_logic := '0';
signal o_c_moore_fsm : std_logic := '0';
signal o_d_moore_fsm : std_logic := '0';
signal o_c_mealy_fsm : std_logic := '0';
signal o_d_mealy_fsm : std_logic := '0';


--Signals used for simulation
signal stop_simulation : std_logic := '0';

begin
   --Instantiate the Unit Under Test (UUT)
   uut_moore_fsm : moore_fsm
      port map (clk => clk,
                reset => reset,
                i_a => i_a,
                i_b => i_b,
                o_c => o_c_moore_fsm,
                o_d => o_d_moore_fsm);

   uut_mealy_fsm : mealy_fsm
      port map (clk => clk,
                reset => reset,
                i_a => i_a,
                i_b => i_b,
                o_c => o_c_mealy_fsm,
                o_d => o_d_mealy_fsm);

   --Clock
   process
   begin
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;

      --Stop the simulation
      if (stop_simulation = '1') then
         wait;
      end if;
   end process;

   --Read testvector from file
   process(clk)

   file vector_file : text is in "state_machines.vec";
   variable read_line : line;
   variable test_vector : std_logic_vector (1 to 2);

   begin
      if (clk'event and clk = '1') then
         --Read data for inputs from file
         if (not(endfile(vector_file))) then
            readline(vector_file, read_line);
            read(read_line, test_vector);

            i_a <= test_vector(1);
            i_b <= test_vector(2);
         --Set signal to stop the simulation
         else
            stop_simulation <= '1';
         end if;
      end if;
   end process;

   --Reset the UUT at start
   reset <= '1', '0' after 15 ns;

end beh;
