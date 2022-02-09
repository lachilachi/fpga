library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity event_trigger_tb is
end entity;

architecture beh of event_trigger_tb is

  --Component Declaration for the Unit Under Test (UUT)

  component event_trigger
    generic(G_PADDLE_EVENT_INTERVAL : integer;
             G_BALL_EVENT_INTERVAL : integer);
    port( clk : in std_logic;
         reset : in std_logic;
         
         o_paddle_event : out std_logic;
         o_ball_event : out std_logic);
  end component;

  constant G_PADDLE_EVENT_INTERVAL : integer := 5;
  constant G_BALL_EVENT_INTERVAL : integer := 10;
  
  --Signals to connect the Unit Under Test (UUT)
  
  signal clk : std_logic := '0';
  signal reset : std_logic;
  signal o_paddle_event : std_logic;
  signal o_ball_event : std_logic;
  signal stop_simulation : std_logic := '0';
  
  
begin

  --Instantiate the Unit Under Test (UUT)
  event_trigger_modul: event_trigger
    generic map(G_PADDLE_EVENT_INTERVAL => G_PADDLE_EVENT_INTERVAL,
                G_BALL_EVENT_INTERVAL => G_BALL_EVENT_INTERVAL)
    port map(clk => clk,
             reset => reset,

             o_paddle_event => o_paddle_event,
             o_ball_event => o_ball_event);

  process
  begin
  
    --Clock
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
	
    --Stop the simulation
    if (stop_simulation = '1') then
      wait;
    end if;
  end process;
  
  process(clk)
    variable cnt: integer := 0;
  begin
    if clk'event and clk = '1' then
      cnt := cnt + 1;
	  
	--Set signal to stop the simulation
      if cnt = 100 then
        stop_simulation <= '1';
      end if;
    end if;
  end process;

  reset <= '1', '0' after 40ns;
  end beh;
  

