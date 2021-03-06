library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--This module scans the serial datastream from the ps2 port and converts it 
--into the control signals necessary to control the game
--
--It provides basic communication from the keyboard to the host device (in this 
--case the fpga board). Communication from the host to the keyboard is not 
--implemented (and not necessary for the desired application). Because of that 
--and the missing possibility to request corrupted data again, there is no need 
--for an error detection of the received data, although a parity bit is 
--included in the data send by the keyboard. All received data (i.e. scancodes 
--of the keyboard keys) that can not be interpreted by the decoder is therefore 
--ignored, whether it is correct or not.
--To prevent errors in the transmission, the external clock is synchronised 
--with the system clock.
--Furthermore the decoder possesses a time-out function if a scancode is not 
--transmitted completely (e.g. a reset occurs during the transmission). In this 
--case the received data of the incomplete scancode is ignored when the 
--remaining data is not transmitted within a defined time interval.

entity input_decoder is
  --Generics are used to allow an easy change of the scancodes in the top entity
  --The value of each generic consists of (from left to right)
  --       1 bit as a stopbit (the last received bit, always a one)
  --       1 bit for odd parrity check (one if numbers of ones in keycode is even, else zero)
  --       8 bits (MSB downto LSB) representing the scancode for the pressed key
  --       1 bit as a startbit (the first received bit, always a zero)
  generic (G_PLAYER_1_UP   : std_logic_vector (10 downto 0) := "10000111000";   --a key
           G_PLAYER_1_DOWN : std_logic_vector (10 downto 0) := "10000110100";   --y key
           G_PLAYER_2_UP   : std_logic_vector (10 downto 0) := "11010000100";   --k key
           G_PLAYER_2_DOWN : std_logic_vector (10 downto 0) := "11001110100";   --m key
           G_SERVE_KEY     : std_logic_vector (10 downto 0) := "10001010010";   --space key
           G_RESET_KEY     : std_logic_vector (10 downto 0) := "10011101100");  --esc key

  --ports:
  -- clk               :  system clock
  -- reset             :  synchronous reset
  -- 
  -- i_ps2_clk         :  input for ps2 clock signal from keyboard
  -- i_ps2_data        :  input for ps2 data from keyboard
  --
  -- o_player_1_up     :  outputs for :  paddle 1 up key pressed
  -- o_player_1_down   :              :  paddle 1 down key pressed
  -- o_player_2_up     :              :  paddle 2 up key pressed
  -- o_player_2_down   :              :  paddle 2 down key pressed
  -- o_serve_key       :              :  serve key pressed (used for both 
  --                                     players)
  -- o_reset_key       :              :  reset key is pressed (this key will 
  --                                     only reset the module game_engine
  port (clk   : in std_logic := '0';
        reset : in std_logic := '0';

        i_ps2_clk  : in std_logic := '0';
        i_ps2_data : in std_logic := '0';

        o_player_1_up   : out std_logic := '0';
        o_player_1_down : out std_logic := '0';
        o_player_2_up   : out std_logic := '0';
        o_player_2_down : out std_logic := '0';
        o_serve_key     : out std_logic := '0';
        o_reset_key     : out std_logic := '0');
end input_decoder;



architecture rtl of input_decoder is

--Set the filter length
  constant C_PS2_CLK_FILTER_LENGTH  : integer                                                 := 8;
--The following two constants are used to define the value of the filter shift 
--register for a transition to low or high
  constant C_PS2_CLK_LOW_CONDITION  : std_logic_vector (C_PS2_CLK_FILTER_LENGTH - 1 downto 0) := (others => '0');
  constant C_PS2_CLK_HIGH_CONDITION : std_logic_vector (C_PS2_CLK_FILTER_LENGTH - 1 downto 0) := (others => '1');
--This constant defines a timeout interval in clock cycles after which the 
--already received part of the scancode is ignored. 
  constant C_TIMEOUT                : integer                                                 := 100000;

--Signals set in process 1
--In this shift register the last samples of the ps2 clock signal are saved.
  signal sr_ps2_clk_filter : std_logic_vector (C_PS2_CLK_FILTER_LENGTH - 1 downto 0) := (others => '0');
--The filtered ps2 clock signal.
  signal ps2_clk_state     : std_logic                                               := '0';
--Signalises that the data at the ps2 data input is valid.
  signal new_ps2_data      : std_logic                                               := '0';

--Signals set in process 2
--Shift register in which the already received bits of the scancode are stored.
  signal sr_scancode       : std_logic_vector (10 downto 0) := (others => '0');
--The number of received bits.
  signal cnt_scancode_bits : integer range 0 to 11          := 0;
--The counter for the timeout.
  signal cnt_timeout       : integer range 0 to C_TIMEOUT   := 0;
--Used to signalise that the next scancode is for the release of the key
  signal key_release_flag  : std_logic                      := '0';
--The next for signals are used to indicate which of the player movement keys 
--was pressed.
  signal player_1_up       : std_logic                      := '0';
  signal player_1_down     : std_logic                      := '0';
  signal player_2_up       : std_logic                      := '0';
  signal player_2_down     : std_logic                      := '0';

begin
  --Type : registered
  --Description : This process filters the ps2 clock and creates a new signal 
  --    which is synchronous with the system clock. A simple filter also 
  --    eliminates glitches in the signal. The incoming ps2 clock signal is 
  --    sampled each system clock cycle and its value is fed to a shift 
  --    register with the length of the filter length. To allow a change of
  --    the generated signal a number of consecutive ps2 clock samples have 
  --    to have the same value, i.e. all bits in the shift register have to 
  --    be either zero or one. This simple approach is possible because the 
  --    ps2 clock frequency is at least three orders of magnitude smaller 
  --    than the sytem clock (<50 kHz ps2 clock, 50 MHz system clock)
  process (clk)
  begin
    if (clk'event and clk = '1') then
      --Synchronous reset
      if (reset = '1') then
        sr_ps2_clk_filter <= (others => '0');
        ps2_clk_state     <= '0';
        new_ps2_data      <= '0';
      else
        --The sample of the ps2 clock input is fed to the shift register input
        sr_ps2_clk_filter <= i_ps2_clk & sr_ps2_clk_filter(C_PS2_CLK_FILTER_LENGTH - 1 downto 1);

        --Check if the content of the shift register allows a transition in the clock 
        --signal. If this is the case and there is a transition from high to low,
        --the new_ps2_data signal is set to one.
        if sr_ps2_clk_filter = C_PS2_CLK_LOW_CONDITION then
          if (ps2_clk_state = '1') then
            new_ps2_data <= '1';
          else
            new_ps2_data <= '0';
          end if;
          ps2_clk_state <= '0';
        elsif sr_ps2_clk_filter = C_PS2_CLK_HIGH_CONDITION then
          new_ps2_data  <= '0';
          ps2_clk_state <= '1';
        else
          new_ps2_data <= '0';
        end if;
      end if;
    end if;
  end process;







  
end rtl;

