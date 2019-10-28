library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity input_decoder_tb is
   generic (G_PLAYER_1_UP : std_logic_vector (10 downto 0) := "10000111000";     --a key
            G_PLAYER_1_DOWN : std_logic_vector (10 downto 0) := "10000110100";   --y key
            G_PLAYER_2_UP : std_logic_vector (10 downto 0) := "11010000100";     --k key
            G_PLAYER_2_DOWN : std_logic_vector (10 downto 0) := "11001110100";   --m key
            G_SERVE_KEY : std_logic_vector (10 downto 0) := "10001010010";       --space key
            G_RESET_KEY : std_logic_vector (10 downto 0) := "10011101100");      --esc key
end input_decoder_tb;



architecture beh of input_decoder_tb is

--Component Declaration for the Unit Under Test (UUT)   
component input_decoder is
   generic (G_PLAYER_1_UP : std_logic_vector (10 downto 0) := "10000111000";     --a key
            G_PLAYER_1_DOWN : std_logic_vector (10 downto 0) := "10000110100";   --y key
            G_PLAYER_2_UP : std_logic_vector (10 downto 0) := "11010000100";     --k key
            G_PLAYER_2_DOWN : std_logic_vector (10 downto 0) := "11001110100";   --m key
            G_SERVE_KEY : std_logic_vector (10 downto 0) := "10001010010";       --space key
            G_RESET_KEY : std_logic_vector (10 downto 0) := "10011101100");      --esc key
   
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_ps2_clk : in std_logic := '0';
         i_ps2_data : in std_logic := '0';
         
         o_player_1_up : out std_logic := '0';
         o_player_1_down : out std_logic := '0';
         o_player_2_up : out std_logic := '0';
         o_player_2_down : out std_logic := '0';
         o_serve_key : out std_logic := '0';
         o_reset_key : out std_logic := '0');
end component;

--Signals to connect the Unit Under Test (UUT)
signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal i_ps2_clk : std_logic := '0';
signal i_ps2_data : std_logic := '0';
signal o_player_1_up : std_logic := '0';
signal o_player_1_down : std_logic := '0';
signal o_player_2_up : std_logic := '0';
signal o_player_2_down : std_logic := '0';
signal o_serve_key : std_logic := '0';
signal o_reset_key : std_logic := '0';

--Signals used for simulation
signal stop_simulation : std_logic := '0';
--used to enable the ps/2 clock (and thereby to enable reading ps/2 data from 
--the vector file
signal enable_ps2_clk : std_logic := '0';

begin
   --Instantiate the Unit Under Test (UUT)
   uut_input_decoder : input_decoder
      generic map (G_PLAYER_1_UP,
                   G_PLAYER_1_DOWN,
                   G_PLAYER_2_UP,
                   G_PLAYER_2_DOWN,
                   G_SERVE_KEY,
                   G_RESET_KEY)
                   
      port map (clk => clk,
                reset => reset,
                i_ps2_clk => i_ps2_clk,
                i_ps2_data => i_ps2_data,
                o_player_1_up => o_player_1_up,
                o_player_1_down => o_player_1_down,
                o_player_2_up => o_player_2_up,
                o_player_2_down => o_player_2_down,
                o_serve_key => o_serve_key,
                o_reset_key => o_reset_key);


   --System Clock
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

   --PS/2 Clock
   process
   begin
      if (enable_ps2_clk = '1') then
         wait for 4000 ns;
         i_ps2_clk <= '0';
         wait for 4000 ns;
         i_ps2_clk <= '1';
      else 
         wait for 8000 ns;
      end if;
      
      --Stop the simulation
      if (stop_simulation = '1') then
         wait;
      end if;
   end process;


   --Read testvector from file
   process(i_ps2_clk)
   
   file vector_file : text is in "input_decoder.vec";
   variable read_line : line;
   variable stimulus_bit : std_logic;
   
   begin
      if (rising_edge(i_ps2_clk)) then
         if (not(endfile(vector_file))) then
            readline(vector_file, read_line);
            read(read_line, stimulus_bit);
            
            i_ps2_data <= stimulus_bit;
         --Set signal to stop the simulation
         else
            stop_simulation <= '1';
         end if;
      end if;
   end process;
   
   --used to test the timeout of the input decoder
   enable_ps2_clk <= '1', '0' after 1650 us, '1' after 3740 us;
   
   reset <= '1', '0' after 50 ns;
   
end beh;