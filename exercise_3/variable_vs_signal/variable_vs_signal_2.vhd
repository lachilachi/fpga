library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;



entity variable_vs_signal_2 is
  port (clk   : in  std_logic;
        reset : in  std_logic;
        a_in  : in  std_logic_vector (3 downto 0) := "0000";
        b_in  : in  std_logic_vector (3 downto 0) := "0000";
        q     : out std_logic_vector (15 downto 0));
end variable_vs_signal_2;

architecture behavioral of variable_vs_signal_2 is

 
  
begin
  
  calc : process (clk, reset)


    
  begin
 

end behavioral;
