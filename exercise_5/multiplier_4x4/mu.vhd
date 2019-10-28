library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity mu is
  port (s_in : in std_logic := '0';
        b_in : in std_logic := '0';
        a_in : in std_logic := '0';
        c_in : in std_logic := '0';

        s_out : out std_logic := '0';
        b_out : out std_logic := '0';
        c_out : out std_logic := '0';
        a_out : out std_logic := '0');

end mu;

architecture rtl of mu is
  signal A : std_logic := '0';
  signal B : std_logic := '0';
  
begin

  A <= s_in;
  B <= a_in and b_in;
  s_out <= (A xor B) xor c_in;
  c_out <= (A and B) or (c_in and (A xor B));
  a_out <= a_in;
  b_out <= b_in;

end rtl;
