library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;


entity multiplier_4x4_tb is
end multiplier_4x4_tb;

architecture behavior of multiplier_4x4_tb is

  -- counter signals
  signal cnt_i_a : integer := 0;
  signal cnt_i_b : integer := 0;

  signal cnt_i_a_1 : integer := 0;
  signal cnt_i_b_1 : integer := 0;
  signal cnt_i_a_2 : integer := 0;
  signal cnt_i_b_2 : integer := 0;

-- result signals
  signal res_a : integer := 0;
  signal res_b : integer := 0;


-- uut signals
  signal i_a             : std_logic_vector(3 downto 0) := (others => '0');
  signal i_b             : std_logic_vector(3 downto 0) := (others => '0');
  signal o_p             : std_logic_vector(7 downto 0) := (others => '0');
  signal clk             : std_logic                    := '0';
  signal reset           : std_logic                    := '0';
  signal stop_simulation : std_logic                    := '0';

-- converted compare signals of uut  
  signal o_p_comp : integer := 0;


  component multiplier_4x4
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      i_a   : in  std_logic_vector (3 downto 0);
      i_b   : in  std_logic_vector (3 downto 0);
      o_p   : out std_logic_vector (7 downto 0));  -- i_a x i_b = o_p
  end component;
  
begin  -- behavior


  ------------------------------------------------------------------------------------------------------------
  --component instantiation
  ------------------------------------------------------------------------------------------------------------
  uut : multiplier_4x4
    port map (
      clk   => clk,
      reset => reset,
      i_a   => i_a,
      i_b   => i_b,
      o_p   => o_p);


  ------------------------------------------------------------------------------------------------------------
  -- reset uut
  ------------------------------------------------------------------------------------------------------------
  reset <= '1', '0' after 21 ns;

  ------------------------------------------------------------------------------------------------------------
  -- clock generation
  ------------------------------------------------------------------------------------------------------------
  clk_generation : process
  begin
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
    clk <= '0';

    ----------------------------------------------------------------------------------------------------------
    -- Stop the simulation
    ----------------------------------------------------------------------------------------------------------
    if (stop_simulation = '1') then
      wait;
    end if;
  end process;


  ------------------------------------------------------------------------------------------------------------
  -- stimuli generation
  ------------------------------------------------------------------------------------------------------------
  stimuli_generation : process(clk)
  begin
    if rising_edge (clk) then
      if reset = '1' then
        cnt_i_a <= 0;
        cnt_i_b <= 0;
      else
        if cnt_i_a <= 14 then
          if cnt_i_b <= 14 then
            cnt_i_b <= cnt_i_b +1;
          else
            cnt_i_a <= cnt_i_a + 1;
            cnt_i_b <= 0;
          end if;
        else
          if cnt_i_b <= 14 then
            cnt_i_b <= cnt_i_b +1;
          else
            stop_simulation <= '1';
            cnt_i_b         <= 0;
          end if;
        end if;
        
--------------------------------------------------------------------------------------------------------------
-- clock delay to check registered outputs of uut
--------------------------------------------------------------------------------------------------------------
      cnt_i_a_1 <= cnt_i_a;
      cnt_i_b_1 <= cnt_i_b;
      cnt_i_a_2 <= cnt_i_a_1;
      cnt_i_b_2 <= cnt_i_b_1;
      res_a     <= cnt_i_a_2;
      res_b     <= cnt_i_b_2;
        
      end if;

      
    end if;

  end process;
--------------------------------------------------------------------------------------------------------------
-- generate assertions if output value is wrong
--------------------------------------------------------------------------------------------------------------
  assertions : process (res_a, res_b)
  begin
    assert (o_p_comp = (res_a * res_b))
      report "wrong output value, correct value should be " & integer'image(res_a * res_b) & ", actual: " & integer'image(o_p_comp)
      severity error;
  end process;

 -------------------------------------------------------------------------------------------------------------
 --assignment of signals for uut
 -------------------------------------------------------------------------------------------------------------
  i_a      <= std_logic_vector(to_unsigned(cnt_i_a, 4));
  i_b      <= std_logic_vector(to_unsigned(cnt_i_b, 4));
  o_p_comp <= to_integer(unsigned(o_p));
end behavior;
