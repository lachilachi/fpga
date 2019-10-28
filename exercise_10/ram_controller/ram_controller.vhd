library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--This module is responsible for the communication between the FPGA and the 
--RAM. It processes incoming write and read requests and acts as a multiplexer 
--switching the data and address ports between the ones from the render 
--engine and the graphic output. It is also responsible for guaranteeing the 
--right timing of the RAM inputs. 

-- edited by c.bohnens@tu-bs.de
-- 05.09.2013 changed ram interface to Cellular Ram (Nexys3 Board)

entity ram_controller is
  --ports:
  --clk                : system clock (100MHz)
  --reset              : synchronous reset
  --
  --i_read_req         : request read operation from RAM
  --i_write_req        : request write operation to RAM
  --i_read_address     : address to read from
  --i_write_address    : address to write to
  --i_write_data       : data that should be written to the RAM
  --
  --io_ram_data        : bidirectional data port to the RAM
  --
  --o_read_done        : read operation complete
  --o_write_done       : write operation complete
  --o_read_data        : data read from the RAM
  --o_ram_address      : address port connected to the RAM
  --o_ce_neg         : chip enable of RAM (negative logic)
  --o_oe_neg           : output enable of RAM (negative logic)
  --o_we_neg           : write enable of RAM (negative logic)
  --o_ub_neg         : upper byte enable of RAM (negative logic)
  --o_lb_neg         : lower byte enable of RAM (negative logic)
  generic (
    G_BURST_COUNT : integer := 16;
    G_DATA_WIDTH  : integer := 16);
  port (clk   : in std_logic := '0';
        reset : in std_logic := '0';

        -- internal interface
        i_read_req      : in  std_logic                                                := '0';
        i_write_req     : in  std_logic                                                := '0';
        i_read_address  : in  std_logic_vector (22 downto 0)                           := (others => '0');
        i_write_address : in  std_logic_vector (22 downto 0)                           := (others => '0');
        i_write_data    : in  std_logic_vector (G_BURST_COUNT*G_DATA_WIDTH-1 downto 0) := (others => '0');
        o_read_done     : out std_logic                                                := '0';
        o_write_done    : out std_logic                                                := '0';
        o_read_data     : out std_logic_vector (G_BURST_COUNT*G_DATA_WIDTH-1 downto 0) := (others => '0');

        -- ram interface
        io_ram_dq     : inout std_logic_vector (15 downto 0) := (others => 'Z');
        o_ram_address : out   std_logic_vector (22 downto 0) := (others => '0');
        o_ram_clk     : out   std_logic                      := '0';
        o_ram_adv_neg : out   std_logic                      := '1';
        o_ram_cre     : out   std_logic                      := '0';
        o_ram_ce_neg  : out   std_logic                      := '1';
        o_ram_oe_neg  : out   std_logic                      := '1';
        o_ram_we_neg  : out   std_logic                      := '1';
        o_ram_ub_neg  : out   std_logic                      := '1';
        o_ram_lb_neg  : out   std_logic                      := '1');
end ram_controller;



architecture rtl of ram_controller is

  ------------------------------------------------------------------------------------------------------------
  -- signals
  ------------------------------------------------------------------------------------------------------------
  type t_ram_ctrl_state is (IDLE, <insert config states>
                            READ_INIT, READ_WAIT, READING,
                            WRITE_INIT, WRITING, WRITE_WAIT);
  signal s_ram_ctrl_state : t_ram_ctrl_state                    := <first config state>;
  signal s_ram_ctrl_cnt   : integer range 0 to G_BURST_COUNT+10 := 0;

  signal s_ram_dq_in  : std_logic_vector(15 downto 0) := (others => '0');
  signal s_ram_dq_out : std_logic_vector(15 downto 0) := (others => 'Z');

  signal s_ram_clk : std_logic := '0';

  ------------------------------------------------------------------------------------------------------------
  -- constants
  ------------------------------------------------------------------------------------------------------------
  

  constant C_INIT_WAIT : integer          := 3;

  -- it might be prudent to create some constants for the config parameters . . .

  
begin

  ------------------------------------------------------------------------------------------------------------
  -- concurrent assignments
  ------------------------------------------------------------------------------------------------------------
  io_ram_dq   <= s_ram_dq_out;
  s_ram_dq_in <= io_ram_dq;
  o_ram_clk <= s_ram_clk;

  -----------------------------------------------------------------------------
  -- procs
  -----------------------------------------------------------------------------
  p_ram_ctrl : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        s_ram_ctrl_state <= <first config state>;
        o_ram_oe_neg     <= '1';
        o_ram_ce_neg     <= '1';
        o_ram_we_neg     <= '1';
        o_ram_ub_neg     <= '1';
        o_ram_lb_neg     <= '1';
        o_ram_adv_neg    <= '1';
        o_ram_cre        <= '0';
        s_ram_dq_out     <= (others => 'Z');
        o_ram_address    <= (others => '0');
        s_ram_clk        <= '0';

        o_read_done  <= '0';
        o_write_done <= '1';
        o_read_data  <= (others => '0');
      else
        o_read_done  <= '0';
        o_write_done <= '0';
        s_ram_dq_out <= (others => 'Z');
        case s_ram_ctrl_state is
          when <first config state> =>
          when <last config state> =>
            if <done> then
              s_ram_ctrl_state <= IDLE;
            end if;
          when IDLE =>
            o_ram_oe_neg <= '1';
            if i_read_req = '1' then
              -- prioritize reads
              o_ram_ce_neg     <= '0';
              o_ram_address    <= i_read_address;
              o_ram_adv_neg    <= '0';
              o_ram_ub_neg     <= '0';
              o_ram_lb_neg     <= '0';
              s_ram_ctrl_cnt   <= C_INIT_WAIT;  -- fixed lat. wait time
              s_ram_ctrl_state <= READ_INIT;
            elsif i_write_req = '1' then
              o_ram_ce_neg     <= '0';
              o_ram_address    <= i_write_address;
              o_ram_adv_neg    <= '0';
              o_ram_ub_neg     <= '0';
              o_ram_lb_neg     <= '0';
              o_ram_we_neg     <= '0';
              s_ram_ctrl_cnt   <= C_INIT_WAIT;
              s_ram_ctrl_state <= WRITE_INIT;
            end if;
          when WRITE_INIT =>
            -- wait for initial latency to pass
            s_ram_clk <= not s_ram_clk;
            if s_ram_clk = '0' then
              -- rising ram clk
              if s_ram_ctrl_cnt /= 0 then
                s_ram_ctrl_cnt <= s_ram_ctrl_cnt - 1;
              else
                s_ram_ctrl_state <= WRITING;
                s_ram_ctrl_cnt   <= 0;
              end if;
            else
              -- falling ram clk
              o_ram_we_neg  <= '1';
              o_ram_adv_neg <= '1';
            end if;
          when WRITING =>
            s_ram_clk <= not s_ram_clk;
            if s_ram_clk = '1' then
              -- falling ram clk
              s_ram_dq_out <= i_write_data(15+s_ram_ctrl_cnt*16 downto s_ram_ctrl_cnt*16);
              if s_ram_ctrl_cnt < G_BURST_COUNT then
                s_ram_ctrl_cnt <= s_ram_ctrl_cnt + 1;
              end if;
            else
              -- rising
              if s_ram_ctrl_cnt = G_BURST_COUNT then
                s_ram_ctrl_state <= WRITE_WAIT;
                o_write_done     <= '1';
              end if;
              s_ram_dq_out <= s_ram_dq_out;
            end if;
          when WRITE_WAIT =>
            -- make sure clock stops low
            if s_ram_clk = '1' then
              s_ram_clk    <= '0';
              o_ram_ce_neg <= '1';
            end if;
            if i_write_req = '0' then
              s_ram_ctrl_state <= IDLE;
            else
              o_write_done <= '1';
            end if;
          when READ_INIT =>
            o_ram_oe_neg <= '0';
            -- wait for initial latency to pass
            s_ram_clk    <= not s_ram_clk;
            if s_ram_clk = '0' then
              -- rising ram clk
              if s_ram_ctrl_cnt /= 0 then
                s_ram_ctrl_cnt <= s_ram_ctrl_cnt - 1;
              else
                s_ram_ctrl_state <= READING;
                s_ram_ctrl_cnt   <= 0;
              end if;
            else
              -- falling ram clk
              o_ram_adv_neg <= '1';
            end if;
          when READING =>
            s_ram_clk <= not s_ram_clk;
            if s_ram_clk = '0' then
              o_read_data(15+s_ram_ctrl_cnt*16 downto s_ram_ctrl_cnt*16) <= s_ram_dq_in;
              if s_ram_ctrl_cnt < G_BURST_COUNT-1 then
                s_ram_ctrl_cnt <= s_ram_ctrl_cnt + 1;
              else
                s_ram_ctrl_state <= READ_WAIT;
                o_read_done      <= '1';
              end if;
            end if;
          when READ_WAIT =>
            -- make sure clock stops low
            if s_ram_clk = '1' then
              s_ram_clk    <= '0';
              o_ram_ce_neg <= '1';
            end if;
            -- wait for request to fade
            if i_read_req = '0' then
              s_ram_ctrl_state <= IDLE;
            else
              o_read_done <= '1';
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process p_ram_ctrl;
  
end rtl;

