library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This counter counts from 0 to 63. The value of the counter is then inverted 
--and assigned to the outputs, so that the output counts from 63 down to 0.

entity counter is
	--ports
	--clk 			: system clock
	--ncl 			: asynchronous reset
	--reset	 		: synchronous reset
	--i_enable 		: enables the counting
	--
	--o_count_neg	: counter output (negative logic)
   port (clk : in std_logic := '0';
         ncl : in std_logic := '0';
         
         i_enable : in std_logic := '0';
         
         o_count_neg : out std_logic_vector (5 downto 0) := (others => '0'));
end counter;



architecture rtl of counter is

--Signal used as counter.
signal cnt_count : unsigned (6 downto 0) := (others => '0');

begin

	--Type : registered
	--Description : The counter is incremented each clock cycle if the enable 
	--		signal is active.
	process(ncl)
	begin
   	--Asynchronous reset
   	if (ncl = '0') then        
      	cnt_count <= (others => '0');
   	elesif (clk'event and clk = '1') then
        	--Synchronous reset
        	if (reset = '1') then  		
        		cnt_count <= (others => '0');
        	
        	--Normal function of the counter
        	elsif (i_enable = '1') then
          	--The folowing line should work too
          	--cnt_count <= cnt_count + to_unsigned(1, 6);
          	cnt_count <= cnt_count + 1
        	end if;
    	end if;
  	end process;


	--Invertes the count signal
   process (cnt_count) 
	begin
     	for i in 2 downto 0 loop
       	o_count_neg(i) <= not(cnt_count(i));
     	end loop;
   end process;

end rtl;
