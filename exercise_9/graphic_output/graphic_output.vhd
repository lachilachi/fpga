library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.graphic_output_package.all;
entity graphic_output is
  generic (G_H_PIXEL_NUMBER : integer;
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

  port(
    clk   : in std_logic := '0';
    reset : in std_logic := '0';

    i_read_done       : in std_logic                       := '0';
    i_read_data       : in std_logic_vector (32*8-1 downto 0) := (others => '0');
    i_new_frame_ready : in std_logic                       := '0';

    o_h_sync        : out std_logic                      := '0';
    o_v_sync        : out std_logic                      := '0';
    o_red           : out std_logic_vector(2 downto 0)   := (others => '0');
    o_green         : out std_logic_vector(2 downto 0)   := (others => '0');
    o_blue          : out std_logic_vector(1 downto 0)   := (others => '0');
    o_read_req      : out std_logic                      := '0';
    o_read_address  : out std_logic_vector (22 downto 0) := (others => '0');
    o_page_switched : out std_logic                      := '0');

end graphic_output;


architecture rtl of graphic_output is

begin
    
end rtl;
