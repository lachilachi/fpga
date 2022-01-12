library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;

entity graphic_buffer_tb is
end graphic_buffer_tb;



architecture beh of graphic_buffer_tb is

  --Component Declaration for the Unit Under Test (UUT)
  component graphic_buffer is
    port (clk   : in std_logic := '0';
          reset : in std_logic := '0';

          i_select       : in std_logic                          := '0';
          i_shift_enable : in std_logic                          := '0';
          i_load         : in std_logic                          := '0';
          i_rgb_data     : in std_logic_vector (32*8-1 downto 0) := (others => '0');

          o_data_req : out std_logic                     := '1';
          o_rgb      : out std_logic_vector (7 downto 0) := (others => '0'));
  end component;


  --Signals to connect the Unit Under Test (UUT)
  signal clk            : std_logic                          := '1';
  signal reset          : std_logic                          := '0';
  signal i_select       : std_logic                          := '0';
  signal i_shift_enable : std_logic                          := '0';
  signal i_load         : std_logic                          := '0';
  signal i_rgb_data     : std_logic_vector (32*8-1 downto 0) := (others => '0');
  signal o_data_req     : std_logic                          := '1';
  signal o_rgb          : std_logic_vector (7 downto 0)      := (others => '0');

  --Signals used for simulation
  signal stop_simulation : std_logic := '0';
  signal data_read       : std_logic := '0';

begin
  --Instantiate the Unit Under Test (UUT)
  uut_graphic_buffer : graphic_buffer
    port map (clk            => clk,
              reset          => reset,
              i_select       => i_select,
              i_shift_enable => i_shift_enable,
              i_load         => i_load,
              i_rgb_data     => i_rgb_data,
              o_data_req     => o_data_req,
              o_rgb          => o_rgb);



  --Stop the simulation
  process
  begin
    --Clock
    clk <= '1';
    wait for 20 ns;
    clk <= '0';
    wait for 20 ns;
    if (stop_simulation = '1') then
      wait;
    end if;
  end process;

  -- generate test data
  -- assign counter values to the input bytes
  process
    variable byte_cnt    : unsigned(7 downto 0) := (others => '0');
    variable in_data_vec : std_logic_vector(32*8-1 downto 0);
  begin
    wait until i_load = '1';
    for i in 0 to 31 loop
      in_data_vec(7+8*i downto 8*i) := std_logic_vector(byte_cnt);
      byte_cnt                      := byte_cnt + 1;
    end loop;  -- i
    i_rgb_data <= in_data_vec;
  end process;

  --Read testvector from file
  process(clk)
    
    file vector_file     : text is in "graphic_buffer.vec";
    --file data_file       : text is in "graphic_buffer_data.vec";
    variable read_line   : line;
    variable test_vector : std_logic_vector (1 to 3);

    
  begin
    if (clk'event and clk = '1') then
      if (reset = '0') then

        --Read data for other inputs from file
        if (not(endfile(vector_file))) then
          readline(vector_file, read_line);
          read(read_line, test_vector);

          i_select       <= test_vector(1);
          i_shift_enable <= test_vector(2);
          i_load         <= test_vector(3);
        --Set signal to stop the simulation
        else
          stop_simulation <= '1';
        end if;
      end if;
    end if;
  end process;

--Reset the UUT at start
  reset <= '1', '0' after 41 ns;

-- assign test signals to input

end beh;
