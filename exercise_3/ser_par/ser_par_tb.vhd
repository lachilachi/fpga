library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity ser_par_tb is
end ser_par_tb;



architecture beh of ser_par_tb is

--Component Declaration for the Unit Under Test (UUT)   
component ser_par
   port(clk : in std_logic;  
        ncl : in std_logic;
        reset : in std_logic;
        i_enable : in std_logic;
        i_serial_in : in std_logic;
        o_parallel_out : out std_logic_vector (25 downto 0);
        o_conv_complete : out std_logic);
end component;


--Signals to connect the Unit Under Test (UUT)
signal clk : std_logic := '0';
signal ncl : std_logic := '0';
signal reset : std_logic := '0';
signal i_enable : std_logic := '0';
signal i_serial_in : std_logic := '0';
signal o_parallel_out : std_logic_vector (25 downto 0) := (others => '0');
signal o_conv_complete : std_logic := '0';

--Signals used for simulation
signal stop_simulation : std_logic := '0';

begin
   --Instantiate the Unit Under Test (UUT)
   uut_ser_par : ser_par 
	   port map (clk => clk, 
	             ncl => ncl,
	             reset => reset,
	             i_enable => i_enable,
	             i_serial_in => i_serial_in,
	             o_parallel_out => o_parallel_out,
	             o_conv_complete => o_conv_complete);


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


   --Read testvector from file
   process(ncl, clk)
   
   file vector_file : text is in "ser_par.vec";
   variable read_line : line;
   variable stimulus_bit : std_logic;
   
   begin
      if (ncl = '0') then
         i_serial_in <= '0';
      elsif (clk'event and clk = '1') then
         if (not(endfile(vector_file))) then
            readline(vector_file, read_line);
            read(read_line, stimulus_bit);
            
            i_serial_in <= stimulus_bit;
         --Set signal to stop the simulation
         else
            stop_simulation <= '1';
         end if;
      end if;
   end process;
   
   
   --Resetting the converter
   process (clk)
   begin
      if (clk'event and clk = '1') then
         if (o_conv_complete = '1') then
            reset <= '1';
         else
            reset <= '0';
         end if;
      end if;
   end process;
   
   
   --Setting of the enable signal and the asynchronous reset
   ncl <= '0', '1' after 60 ns;
   i_enable <= '1', '0' after 900 ns, '1' after 940 ns;      
   
end beh;