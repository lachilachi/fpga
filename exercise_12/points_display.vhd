library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.points_display_package.ALL;

--This module converts the player's points from it's binary value to BCD. This 
--is necessary to display the points on the seven segment displays in decimal 
--values.
--To save resources of the FPGA the conversion is not done in one cycle, but 
--uses a method described in the Xilinx application note XAPP029 with the aid 
--of one shift register for each BCD digit.
--Both numbers are converted one after another, so a state machine is used to 
--control the conversion process.
--The second part of this module controls the activation of the seven segement 
--displays (please see FPGA manual for more information on how to drive the 
--displays).

entity points_display is
   --generics:
   --G_POINTS_TO_WIN    : points neededg to win the game
   generic (G_POINTS_TO_WIN : integer := 15);
   
   --ports:
   --clk                : system clock
   --reset              : synchronous reset
   --
   --i_player_1_points  : points of player 1
   --i_player_2_points  : points of player 2
   --
   --o_anodes           : output for driving the anodes of the seven segment 
   --                     display
   --o_cathodes         : output for driving the cathodes of the seven segment 
   --                     display
   port (clk : in std_logic := '0';
         reset : in std_logic := '0';
         
         i_player_1_points : in integer range 0 to G_POINTS_TO_WIN := 0;
         i_player_2_points : in integer range 0 to G_POINTS_TO_WIN := 0;
         
         o_anodes : out std_logic_vector (3 downto 0) := "0111";
         o_cathodes : out std_logic_vector (7 downto 0) := (others => '1'));
end points_display;



architecture rtl of points_display is

--The number of bits needed to store the points of one player
constant C_POINT_BITS : integer := number_of_bits(G_POINTS_TO_WIN);
--Interval time between anode change in clock cycles
constant C_ANODE_CHANGE_INTERVAL : integer := 1023;

--Defines the states of the state machine
type t_state_conversion is (FETCHING, CONVERTING);

--Signals to connect the instances
signal bcd_tens_sig : std_logic_vector (3 downto 0) := (others => '0');
signal bcd_ones_sig : std_logic_vector (3 downto 0) := (others => '0');
signal carry_sig : std_logic := '0';

--Signals set in process 1
--State of the state machine
signal state_conversion : t_state_conversion := FETCHING;
--Selects the number that should be converted to BCD (0 = points of player 1, 
--1 = points of player 2).
signal input_select : std_logic := '0';
--Shift register for the number that should be converted to BCD
signal sr_number_to_convert : std_logic_vector (C_POINT_BITS - 1 downto 0) := (others => '0');
--Counter for the number of shift operations
signal cnt_shifted_bits : integer range 0 to C_POINT_BITS := 0;
--Reset signal for the BCD converter instances
signal reset_bcd : std_logic := '0';
--Four registers to store the bcd converted points
signal player_1_tens : std_logic_vector (3 downto 0) := (others => '0');
signal player_1_ones : std_logic_vector (3 downto 0) := (others => '0');
signal player_2_tens : std_logic_vector (3 downto 0) := (others => '0');
signal player_2_ones : std_logic_vector (3 downto 0) := (others => '0');

--Signal set by process 2
--Counter for the interval between anode changes
signal cnt_anode_change_interval : integer range 0 to C_ANODE_CHANGE_INTERVAL := 0;
--Selects the active anode (0 = active, 1 inactive)
signal sr_anodes : std_logic_vector (3 downto 0) := "0111";

begin
   
   --Instances of both BCD conversion digits
   bcd_digit_tens_inst : bcd_digit
      port map (clk => clk,
                reset => reset_bcd,
                
                i_serial_data => carry_sig,
                
                o_carry => open,
                o_bcd => bcd_tens_sig);
   
   bcd_digit_ones_inst : bcd_digit
      port map (clk => clk,
                reset => reset_bcd,
                
                i_serial_data => sr_number_to_convert(C_POINT_BITS - 1),
                
                o_carry => carry_sig,
                o_bcd => bcd_ones_sig);

   --Type : registered Mealy state machine
   --       States : FETCHING    : loads a new number to convert
   --                CONVERTING  : converts the input data to BCD
   --Description : This process controls the binary to BCD conversion. First 
   --    the number to convert is loaded into a shift register. In the next 
   --    state the MSB of the register is loaded into the BCD converter and the 
   --    register is right shifted. When all data was loaded into the converter
   --    the result is written to the registers for the BCD data (one for each 
   --    digit) and the next number is converted.
   process (clk)
   begin
      if (clk'event and clk = '1') then
         --Synchronous reset
         if (reset = '1') then
            state_conversion <= FETCHING;
            input_select <= '0';
            cnt_shifted_bits <= 0;
            reset_bcd <= '0';
         else
            --Check current state and calculate transitions.
            case state_conversion is
            
            when FETCHING =>
               state_conversion <= CONVERTING;
               reset_bcd <= '0';
               --Load the shift register with the number of points of the 
               --selected player.
               if (input_select = '0') then
                  sr_number_to_convert <= std_logic_vector(to_unsigned(i_player_1_points, C_POINT_BITS));
               else
                  sr_number_to_convert <= std_logic_vector(to_unsigned(i_player_2_points, C_POINT_BITS));
               end if;
            
            when CONVERTING =>
               --Leave the state when all bits have been shifted into the 
               --converter.
               if (cnt_shifted_bits = C_POINT_BITS) then
                  state_conversion <= FETCHING;
                  cnt_shifted_bits <= 0;
                  reset_bcd <= '1';
                  --Write the converted data to the registers of the selected 
                  --player.
                  if (input_select = '0') then
                     player_1_tens <= bcd_tens_sig;
                     player_1_ones <= bcd_ones_sig;
                  else
                     player_2_tens <= bcd_tens_sig;
                     player_2_ones <= bcd_ones_sig;
                  end if;
                  --Change the selected player
                  input_select <= not(input_select);
               
               --The shift counter is increased.
               else
                  cnt_shifted_bits <= cnt_shifted_bits + 1;
                  reset_bcd <= '0';
                  sr_number_to_convert <= sr_number_to_convert(C_POINT_BITS - 2 downto 0) & '0';
               end if;
                           
            end case;
         end if;     
      end if;
   end process;
   
   --Type : registered
   --Description : This process changes the active anode. To give the LEDs 
   --    enough time to light up, it is necessary to wait between the anode 
   --    changes. The wait time is realised by a counter.
   process (clk)
   begin
      if (clk'event and clk = '1') then
         --Synchronous reset
         if (reset = '1') then
            sr_anodes <= "0111";
            cnt_anode_change_interval <= 0;
         else
            --If the interval counter reached the interval time the active 
            --anode signal is barrel shifted to the right by one bit so that 
            --the anode on the right side of the previously selected becomes 
            --active and the interval counter is set to 0.
            if cnt_anode_change_interval = C_ANODE_CHANGE_INTERVAL then
               sr_anodes <= sr_anodes(0) & sr_anodes(3 downto 1);
               cnt_anode_change_interval <= 0;
            --Increase interval counter
            else
               cnt_anode_change_interval <= cnt_anode_change_interval + 1;
            end if;
         end if;
      end if;
   end process;
   
   --The outputs are assigned
   o_anodes <= sr_anodes;
   --The cathode signal is assigned from the corresponding register selected 
   --by the anode signal.
   o_cathodes(6 downto 0) <= bcd_to_segments(player_1_tens) when (sr_anodes = "0111")
                        else bcd_to_segments(player_1_ones) when (sr_anodes = "1011")
                        else bcd_to_segments(player_2_tens) when (sr_anodes = "1101")
                        else bcd_to_segments(player_2_ones);
   --The dot on the seven segment displays acts as a separator between the 
   --points of player 1 and player 2. It is only activated on the second and 
   --fourth display from the left.
   o_cathodes(7) <= '0' when (sr_anodes = "1011" or sr_anodes = "1110")
               else '1';
end rtl;

