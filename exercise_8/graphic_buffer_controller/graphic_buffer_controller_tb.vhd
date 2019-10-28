library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity graphic_buffer_controller_tb is
end graphic_buffer_controller_tb;



architecture beh of graphic_buffer_controller_tb is

--Component Declaration for the Unit Under Test (UUT)
component graphic_buffer_controller
   generic (G_H_RESOLUTION : integer := 640;
            G_V_RESOLUTION : integer := 480);

   port (clk : in std_logic := '0';
         reset : in std_logic := '0';

         i_data_req_reg_0 : in std_logic := '0';
         i_data_req_reg_1 : in std_logic := '0';
         i_read_done : in std_logic := '0';
         i_new_frame_ready : in std_logic := '0';

         o_reg_select : out std_logic := '0';
         o_load_reg : out std_logic := '0';
         o_read_req : out std_logic := '0';
         o_read_address : out std_logic_vector (22 downto 0) := (others => '0');
         o_page_switched : out std_logic := '0');
end component;


--Signals to connect the Unit Under Test (UUT)
signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal i_data_req_reg_0 : std_logic := '0';
signal i_data_req_reg_1 : std_logic := '0';
signal i_read_done : std_logic := '0';
signal i_new_frame_ready : std_logic := '0';
signal o_reg_select : std_logic := '0';
signal o_load_reg : std_logic := '0';
signal o_read_req : std_logic := '0';
signal o_read_address : std_logic_vector (22 downto 0) := (others => '0');
signal o_page_switched : std_logic := '0';

--Signals used for simulation
signal stop_simulation : std_logic := '0';

begin
   --Instantiate the Unit Under Test (UUT)
   uut_graphic_buffer_controller : graphic_buffer_controller
      generic map (G_H_RESOLUTION => 16,
                   G_V_RESOLUTION => 8)

      port map (clk => clk,
                reset => reset,
                i_data_req_reg_0 => i_data_req_reg_0,
                i_data_req_reg_1 => i_data_req_reg_1,
                i_read_done => i_read_done,
                i_new_frame_ready => i_new_frame_ready,
                o_reg_select => o_reg_select,
                o_load_reg => o_load_reg,
                o_read_req => o_read_req,
                o_read_address => o_read_address,
                o_page_switched => o_page_switched);


   --Clock
   process   begin
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
   process(clk)
   
   file vector_file : text is in "graphic_buffer_controller.vec";
   variable read_line : line;
   variable stimulus_vector : std_logic_vector (1 to 4);
   
   begin
      if (rising_edge(clk)) then
         if (not(endfile(vector_file))) then
            readline(vector_file, read_line);
            read(read_line, stimulus_vector);

            i_data_req_reg_0 <= stimulus_vector(1);
            i_data_req_reg_1 <= stimulus_vector(2);
            i_read_done <= stimulus_vector(3);
            i_new_frame_ready <= stimulus_vector(4);
         --Set signal to stop the simulation
         else
            stop_simulation <= '1';
         end if;
      end if;
   end process;

	reset <= '1', '0' after 21 ns;

end beh;
