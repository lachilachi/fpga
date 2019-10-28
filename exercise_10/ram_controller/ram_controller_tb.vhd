-------------------------------------------------------------------------------
-- Title      : Testbench for design "ram_controller"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ram_controller_tb.vhd<2>
-- Author     : Prak. Amilcar  <chipw1@cclientng1.net.ida>
-- Company    : IDA, TU-Braunschweig, Germany
-- Created    : 2013-09-05
-- Last update: 2013-12-13
-- Platform   : Xilinx XC2V2000
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 IDA, TU-Braunschweig, Germany
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-09-05  1.0      chipw1  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------------------------------------

entity ram_controller_tb is

end ram_controller_tb;

--------------------------------------------------------------------------------------------------------------

architecture beh of ram_controller_tb is

  component cellram
    port (
      clk    : in    std_logic;
      adv_n  : in    std_logic;
      cre    : in    std_logic;
      o_wait : out   std_logic;
      ce_n   : in    std_logic;
      oe_n   : in    std_logic;
      we_n   : in    std_logic;
      lb_n   : in    std_logic;
      ub_n   : in    std_logic;
      addr   : in    std_logic_vector(22 downto 0);
      dq     : inout std_logic_vector(15 downto 0));
  end component;

  component ram_controller
    generic (
      G_BURST_COUNT : integer;
      G_DATA_WIDTH  : integer);
    port (
      clk             : in    std_logic                                                := '0';
      reset           : in    std_logic                                                := '0';
      i_read_req      : in    std_logic                                                := '0';
      i_write_req     : in    std_logic                                                := '0';
      i_read_address  : in    std_logic_vector (22 downto 0)                           := (others => '0');
      i_write_address : in    std_logic_vector (22 downto 0)                           := (others => '0');
      i_write_data    : in    std_logic_vector (G_BURST_COUNT*G_DATA_WIDTH-1 downto 0) := (others => '0');
      o_read_done     : out   std_logic                                                := '0';
      o_write_done    : out   std_logic                                                := '0';
      o_read_data     : out   std_logic_vector (G_BURST_COUNT*G_DATA_WIDTH-1 downto 0) := (others => '0');
      io_ram_dq       : inout std_logic_vector (15 downto 0)                           := (others => 'Z');
      o_ram_address   : out   std_logic_vector (22 downto 0)                           := (others => '0');
      o_ram_clk       : out   std_logic                                                := '1';
      o_ram_adv_neg   : out   std_logic                                                := '1';
      o_ram_cre       : out   std_logic                                                := '0';
      o_ram_ce_neg    : out   std_logic                                                := '1';
      o_ram_oe_neg    : out   std_logic                                                := '1';
      o_ram_we_neg    : out   std_logic                                                := '1';
      o_ram_ub_neg    : out   std_logic                                                := '1';
      o_ram_lb_neg    : out   std_logic                                                := '1');
  end component;

  -- component generics
  constant G_BURST_COUNT : integer := 16;
  constant G_DATA_WIDTH  : integer := 16;

  -- component ports
  signal reset           : std_logic                                                := '0';
  signal i_read_req      : std_logic                                                := '0';
  signal i_write_req     : std_logic                                                := '0';
  signal i_read_address  : std_logic_vector (22 downto 0)                           := (others => '0');
  signal i_write_address : std_logic_vector (22 downto 0)                           := (others => '0');
  signal i_write_data    : std_logic_vector (G_BURST_COUNT*G_DATA_WIDTH-1 downto 0) := (others => '0');
  signal o_read_done     : std_logic                                                := '0';
  signal o_write_done    : std_logic                                                := '0';
  signal o_read_data     : std_logic_vector (G_BURST_COUNT*G_DATA_WIDTH-1 downto 0) := (others => '0');
  signal io_ram_dq       : std_logic_vector (15 downto 0)                           := (others => 'Z');
  signal o_ram_address   : std_logic_vector (22 downto 0)                           := (others => '0');
  signal o_ram_clk       : std_logic                                                := '1';
  signal o_ram_adv_neg   : std_logic                                                := '1';
  signal o_ram_cre       : std_logic                                                := '0';
  signal o_ram_ce_neg    : std_logic                                                := '1';
  signal o_ram_oe_neg    : std_logic                                                := '1';
  signal o_ram_we_neg    : std_logic                                                := '1';
  signal o_ram_ub_neg    : std_logic                                                := '1';
  signal o_ram_lb_neg    : std_logic                                                := '1';

  signal o_wait : std_logic := '0';

  -- clock
  signal clk : std_logic := '1';

begin  -- beh

  -- component instantiation

  cellram_1 : cellram
    port map (
      clk    => o_ram_clk,
      adv_n  => o_ram_adv_neg,
      cre    => o_ram_cre,
      o_wait => o_wait,
      ce_n   => o_ram_ce_neg,
      oe_n   => o_ram_oe_neg,
      we_n   => o_ram_we_neg,
      lb_n   => o_ram_lb_neg,
      ub_n   => o_ram_ub_neg,
      addr   => o_ram_address,
      dq     => io_ram_dq);

  dut : ram_controller
    generic map (
      G_BURST_COUNT => G_BURST_COUNT,
      G_DATA_WIDTH  => G_DATA_WIDTH)
    port map (
      clk             => clk,
      reset           => reset,
      i_read_req      => i_read_req,
      i_write_req     => i_write_req,
      i_read_address  => i_read_address,
      i_write_address => i_write_address,
      i_write_data    => i_write_data,
      o_read_done     => o_read_done,
      o_write_done    => o_write_done,
      o_read_data     => o_read_data,
      io_ram_dq       => io_ram_dq,
      o_ram_address   => o_ram_address,
      o_ram_clk       => o_ram_clk,
      o_ram_adv_neg   => o_ram_adv_neg,
      o_ram_cre       => o_ram_cre,
      o_ram_ce_neg    => o_ram_ce_neg,
      o_ram_oe_neg    => o_ram_oe_neg,
      o_ram_we_neg    => o_ram_we_neg,
      o_ram_ub_neg    => o_ram_ub_neg,
      o_ram_lb_neg    => o_ram_lb_neg);

  -- clock generation
  Clk <= not Clk after 5 ns;

  reset <= '1', '0' after 151 us;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    
    wait until Clk = '1';
  end process WaveGen_Proc;


  test_proc : process(clk)
    variable test_cnt   : integer      := 0;
    type test_state_t is (READ_INIT, READING, WRITE_INIT, WRITING);
    variable test_state : test_state_t := WRITE_INIT;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        i_read_req  <= '0';
        i_write_req <= '0';
        test_state  := WRITE_INIT;
      else
        case test_state is
          when READ_INIT =>
            i_read_req     <= '1';
            i_read_address <= std_logic_vector(to_unsigned(test_cnt, i_read_address'length));
            test_cnt       := test_cnt + G_BURST_COUNT;
            test_state     := READING;
          when READING =>
            if o_read_done = '1' then
              i_read_req <= '0';
              test_state := WRITE_INIT;
            end if;
          when WRITE_INIT =>
            i_write_req     <= '1';
            i_write_address <= std_logic_vector(to_unsigned(test_cnt, i_write_address'length));
            i_write_data    <= std_logic_vector(to_unsigned(test_cnt+15, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+14, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+13, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+12, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+11, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+10, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+9, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+8, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+7, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+6, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+5, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+4, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+3, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+2, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+1, 16)) &
                               std_logic_vector(to_unsigned(test_cnt+0, 16));
            test_state := WRITING;
          when WRITING =>
            if o_write_done = '1' then
              i_write_req <= '0';
              test_state  := READ_INIT;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process test_proc;

end beh;

--------------------------------------------------------------------------------------------------------------

configuration ram_controller_tb_beh_cfg of ram_controller_tb is
  for beh
  end for;
end ram_controller_tb_beh_cfg;

--------------------------------------------------------------------------------------------------------------
