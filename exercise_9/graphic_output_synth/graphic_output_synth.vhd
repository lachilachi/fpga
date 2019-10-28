library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This test project is used to test the module graphic_output and all its 
--sub-modules. It creates all signal the original project would create. The 
--image data is taken from a ROM. A page switch is simulated by setting the 
--signal new_frame_ready each 1.35 seconds.
--
--The output o_read_address of the module graphic_output is not used, except 
--the MSB, which signifies the currently active page.

entity graphic_output_synth is
   generic (G_H_PIXEL_NUMBER : integer := 800;
            G_H_RESOLUTION : integer := 640;
            G_H_FRONT_PORCH : integer := 8;
            G_H_BACK_PORCH : integer := 48;
            G_H_SYNC_LENGTH : integer := 96;
            G_H_SYNC_ACTIVE : std_logic := '0';
            
            G_V_PIXEL_NUMBER : integer := 525;
            G_V_RESOLUTION : integer := 480;
            G_V_FRONT_PORCH : integer := 2;
            G_V_BACK_PORCH : integer := 33;
            G_V_SYNC_LENGTH : integer := 2;
            G_V_SYNC_ACTIVE : std_logic := '0');
  
   port (clk : in std_logic := '0' ;
         reset : in std_logic := '0';

         o_player_1_up : out std_logic := '0';
         
         o_h_sync : out std_logic := '0';
         o_v_sync : out std_logic := '0';
         o_red : out std_logic_vector(2 downto 0) := (others => '0');
         o_green : out std_logic_vector(2 downto 0) := (others => '0');
         o_blue : out std_logic_vector(1 downto 0) := (others => '0'));
end graphic_output_synth;



architecture rtl of graphic_output_synth is

--Component of the pixel clock divider
component pixel_clk_generator is
   port (clk : in std_logic := '0';
         
         o_pixel_clk : out std_logic := '0');
end component;

--Component of graphic_output
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

--Cmponent of the rom used to store image data
component rom is
   port (i_rom_address : in std_logic_vector (2 downto 0) := (others => '0');
                
         o_rom_data : out std_logic_vector (31 downto 0) := (others => '0'));
end component;

--Constants for interval lengths
constant C_NEW_FRAME_READY_INTERVAL : integer := 67108863;
constant COLOR_WHITE : std_logic_vector(7 downto 0) := (others => '1');
constant COLOR_BLACK : std_logic_vector(7 downto 0) := (others => '0');
constant COLOR_BLUE : std_logic_vector(7 downto 0) := x"03";
constant COLOR_YELLOW : std_logic_vector(7 downto 0) := x"FC";

--Signals to connect the instances
signal pixel_clk_sig : std_logic := '0';
signal read_done_sig : std_logic := '0';
signal read_data_sig : std_logic_vector (32*8-1 downto 0) := (others => '0');
signal new_frame_ready_sig : std_logic := '0';
signal read_req_sig : std_logic := '0';
signal read_address_sig : std_logic_vector (22 downto 0) := (others => '0');
signal page_switched_sig : std_logic := '0';

signal rom_address_sig : std_logic_vector (2 downto 0) := (others => '0');
signal rom_data_sig : std_logic_vector (31 downto 0) := (others => '0');
--Column and row address for the ROM
signal lineNr : integer range 0 to 7 := 0;

signal led : std_logic := '0';

begin
   --Instantiate all modules
   pixel_clk_generator_inst : pixel_clk_generator
      port map (clk => clk,
                
                o_pixel_clk => pixel_clk_sig);

   graphic_output_inst : graphic_output
     generic map (
       G_H_PIXEL_NUMBER => G_H_PIXEL_NUMBER,
       G_H_RESOLUTION   => G_H_RESOLUTION,
       G_H_FRONT_PORCH  => G_H_FRONT_PORCH,
       G_H_BACK_PORCH   => G_H_BACK_PORCH,
       G_H_SYNC_LENGTH  => G_H_SYNC_LENGTH,
       G_H_SYNC_ACTIVE  => G_H_SYNC_ACTIVE,
       G_V_PIXEL_NUMBER => G_V_PIXEL_NUMBER,
       G_V_RESOLUTION   => G_V_RESOLUTION,
       G_V_FRONT_PORCH  => G_V_FRONT_PORCH,
       G_V_BACK_PORCH   => G_V_BACK_PORCH,
       G_V_SYNC_LENGTH  => G_V_SYNC_LENGTH,
       G_V_SYNC_ACTIVE  => G_V_SYNC_ACTIVE)
      port map (clk => pixel_clk_sig,
                reset => reset,
              
                i_read_done => read_done_sig,
                i_read_data => read_data_sig,
                i_new_frame_ready => new_frame_ready_sig,
               
                o_h_sync => o_h_sync,
                o_v_sync => o_v_sync,
                o_red => o_red,
                o_green => o_green,
                o_blue => o_blue,
                o_read_req => read_req_sig,
                o_read_address => read_address_sig,
                o_page_switched => page_switched_sig);

	rom_inst : rom
      port map (i_rom_address => rom_address_sig,
                
                o_rom_data => rom_data_sig);


   --Type : Registered
   --Description : Set and reset of read_done_sig and increment rom_address 
   --    after each read operation. This simulates the behaviour of the ram 
   --    controller without write requests.
	
   process (clk)
		variable cnt : integer range 0 to 24 := 0;
   begin
      if (rising_edge(clk)) then
         if (reset = '1') then
				lineNr <= 0;
				cnt := 0;
         else
            if (read_req_sig = '1') then
               read_done_sig <= '1';
            else
               read_done_sig <= '0';
               
               --Increase ROM address in cycle where read_done_sig is set to 0
               if (read_done_sig = '1') then
						if (cnt < 24) then
							cnt := cnt + 1;
						else
							cnt := 0;
							lineNr <= lineNr + 1;
						end if;
               end if;
            end if;
         end if;
      end if;
   end process;
   
	rom_address_sig <= std_logic_vector(to_unsigned(lineNr,3));

   --Type : Registered
   --Description : Set and reset new_frame_ready_sig
   process (clk)
   
   --Counter for interval between signal changes
   variable cnt_new_frame_ready_interval : integer range 0 to C_NEW_FRAME_READY_INTERVAL := 0;
   
   begin
      if (rising_edge(clk)) then
         if (reset = '1') then
            cnt_new_frame_ready_interval := 0;
            new_frame_ready_sig <= '0';
         else
            if (new_frame_ready_sig = '0') then
               if (cnt_new_frame_ready_interval = C_NEW_FRAME_READY_INTERVAL) then
                  new_frame_ready_sig <= '1';
                  led <= not led;
                  cnt_new_frame_ready_interval := 0;
               else
                  cnt_new_frame_ready_interval := cnt_new_frame_ready_interval + 1;
               end if;
            else
               if (page_switched_sig = '1') then
                 new_frame_ready_sig <= '0';
               end if;
            end if;
         end if;
      end if;
   end process;


   o_player_1_up <= led;

   --Assign the ROM output to the data input of the module graphic_output
	readDataSig: for i in 0 to 31 generate
		read_data_sig(i*8+7 downto i*8) <= 
				COLOR_WHITE when (rom_data_sig(i) = '1' and read_address_sig(18) = '0') else
				COLOR_BLUE  when (rom_data_sig(i) = '0' and read_address_sig(18) = '0') else
				COLOR_YELLOW when (rom_data_sig(i) = '1' and read_address_sig(18) = '1') else
				COLOR_BLACK  when (rom_data_sig(i) = '0' and read_address_sig(18) = '1') else 
				(others => '0');
	end generate readDataSig;
	

end rtl;

