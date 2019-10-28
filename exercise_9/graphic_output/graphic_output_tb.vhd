library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use work.graphic_output_package.all;

entity graphic_output_tb is
end graphic_output_tb;



architecture beh of graphic_output_tb is

--Component Declaration for the Unit Under Test (UUT)
  component graphic_output is
    generic (
      G_H_PIXEL_NUMBER : integer;
      G_H_RESOLUTION   : integer;
      G_H_FRONT_PORCH  : integer;
      G_H_BACK_PORCH   : integer;
      G_H_SYNC_LENGTH  : integer;
      G_H_SYNC_ACTIVE  : std_logic;
      G_V_PIXEL_NUMBER : integer;
      G_V_RESOLUTION   : integer;
      G_V_FRONT_PORCH  : integer;
      G_V_BACK_PORCH   : integer;
      G_V_SYNC_LENGTH  : integer;
      G_V_SYNC_ACTIVE  : std_logic);
    port (
      clk               : in  std_logic                          := '0';
      reset             : in  std_logic                          := '0';
      i_read_done       : in  std_logic                          := '0';
      i_read_data       : in  std_logic_vector (32*8-1 downto 0) := (others => '0');
      i_new_frame_ready : in  std_logic                          := '0';
      o_h_sync          : out std_logic                          := '0';
      o_v_sync          : out std_logic                          := '0';
      o_red             : out std_logic_vector(2 downto 0)       := (others => '0');
      o_green           : out std_logic_vector(2 downto 0)       := (others => '0');
      o_blue            : out std_logic_vector(1 downto 0)       := (others => '0');
      o_read_req        : out std_logic                          := '0';
      o_read_address    : out std_logic_vector (22 downto 0)     := (others => '0');
      o_page_switched   : out std_logic                          := '0');
  end component graphic_output;

--Signals to connect the Unit Under Test (UUT)
  signal clk               : std_logic                          := '0';
  signal reset             : std_logic                          := '0';
  signal i_read_done       : std_logic                          := '0';
  signal i_read_data       : std_logic_vector (32*8-1 downto 0) := (others => '0');
  signal i_new_frame_ready : std_logic                          := '0';
  signal o_h_sync          : std_logic                          := '0';
  signal o_v_sync          : std_logic                          := '0';
  signal o_red             : std_logic_vector(2 downto 0)       := (others => '0');
  signal o_green           : std_logic_vector(2 downto 0)       := (others => '0');
  signal o_blue            : std_logic_vector(1 downto 0)       := (others => '0');
  signal o_read_req        : std_logic                          := '0';
  signal o_read_address    : std_logic_vector (22 downto 0)     := (others => '0');
  signal o_page_switched   : std_logic                          := '0';

--Signals used for simulation
  signal stop_simulation : std_logic := '0';
  signal read_data       : std_logic := '0';
  signal sync_difference : std_logic := '0';
  signal delay_counter   : integer   := 0;

  
begin
  --Instantiate the Unit Under Test (UUT)
  uut_graphic_output : graphic_output
    generic map (G_H_PIXEL_NUMBER => 40,
                 G_H_RESOLUTION   => 24,
                 G_H_FRONT_PORCH  => 2,
                 G_H_BACK_PORCH   => 2,
                 G_H_SYNC_LENGTH  => 2,
                 G_H_SYNC_ACTIVE  => '0',
                 G_V_PIXEL_NUMBER => 10,
                 G_V_RESOLUTION   => 5,
                 G_V_FRONT_PORCH  => 1,
                 G_V_BACK_PORCH   => 1,
                 G_V_SYNC_LENGTH  => 1,
                 G_V_SYNC_ACTIVE  => '0')

    port map (clk               => clk,
              reset             => reset,
              i_read_done       => i_read_done,
              i_read_data       => i_read_data,
              i_new_frame_ready => i_new_frame_ready,
              o_h_sync          => o_h_sync,
              o_v_sync          => o_v_sync,
              o_red             => o_red,
              o_green           => o_green,
              o_blue            => o_blue,
              o_read_req        => o_read_req,
              o_read_address    => o_read_address,
              o_page_switched   => o_page_switched);


  --Clock generation
  process
  begin
    wait for 20 ns;
    clk <= '1';
    wait for 20 ns;
    clk <= '0';

    --Stop the simulation
    if (stop_simulation = '1') then
      --wait;
      null;
    end if;
  end process;


  -- reset unit under test
  reset <= '1', '0' after 41 ns;


  proc_input_data : process (clk)
  begin

    if rising_edge(clk) then
      
      if reset = '1' then

        i_read_done       <= '0';
        i_new_frame_ready <= '0';
        i_read_data       <= (others => '0');
      else

        
        
        -- Set signal to stop the simulation        
        --stop_simulation <= '1';
      end if;
    end if;


  end process proc_input_data;

end beh;
