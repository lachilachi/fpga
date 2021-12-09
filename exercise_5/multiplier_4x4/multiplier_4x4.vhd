library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity multiplier_4x4 is

  port (clk   : in std_logic := '0';
        reset : in std_logic := '0';

        i_a : in std_logic_vector (3 downto 0) := (others => '0');
        i_b : in std_logic_vector (3 downto 0) := (others => '0');

        o_p : out std_logic_vector (7 downto 0) := (others => '0'));

end multiplier_4x4;

architecture rtl of multiplier_4x4 is
-- component declaration
component mu is
  
    port (s_in : in std_logic := '0';
        b_in : in std_logic := '0';
        a_in : in std_logic := '0';
        c_in : in std_logic := '0';

        s_out : out std_logic := '0';
        b_out : out std_logic := '0';
        c_out : out std_logic := '0';
        a_out : out std_logic := '0');
		
end component mu;

--用到的变量
variable btemp: std_logic_vector (19 downto 0);
variable stemp: std_logic_vector (19 downto 0);
variable atemp: std_logic_vector (19 downto 0);
variable ctemp: std_logic_vector (19 downto 0); 
variable ptemp: std_logic_vector (7 downto 0);


begin

--组件间缓存
  io_register : process (clk,reset)
  begin  -- process mult
    if rising_edge(clk) then            -- rising clock edge
      if reset = '1' then               -- synchronous reset (active high)
        btemp := (others => '0');
		stemp := (others => '0');
		atemp := (others => '0');
		ctemp := (others => '0');
		ptemp := (others => '0');
		o_p <= (others => '0');
		
      else
		btemp := (0 => i_b(0), 1 => i_b(1), 2 => i_b(2), 3 => i_b(3));
		atemp(0) := i_a(0); 
        atemp(5) := i_a(1); 
		atemp(10) := i_a(2); 
		atemp(15) := i_a(3); 
		
		ptemp(0) := stemp(4); 
        ptemp(1) := stemp(8); 
		ptemp(2) := stemp(12); 
		ptemp(3) := stemp(16); 
		ptemp(4) := stemp(17); 
		ptemp(5) := stemp(18); 
		ptemp(6) := stemp(19); 
		ptemp(7) := ctemp(19); 
		
		o_p <= ptemp;
      end if;
    end if;
  end process io_register;

----------------------------------------------------------------------------------------------------
-- Generate statements
-- nested loop with j = row, i = column
--------------------------------------------------------------------------------------------------------------

row : for j in 0 to 3 generate
	row_begin: if (j = 0) generate
	
		column : for i in 0 to 3 generate			
			column_begin: if (i = 0) generate
				mu_begin: mu
				port map(
					s_in => stemp(4*j+i),
					b_in => btemp(4*j+i),
					a_in => atemp(5*j+i),
					c_in => ctemp(5*j+i),

					s_out => stemp(4*(j+1)+i),
					b_out => btemp(4*(j+1)+i),
					a_out => atemp(5*j+i+1),
					c_out => ctemp(5*j+i+1));
				end generate;
				
			column_middle: if (i > 0) and (i < 3) generate
				mu_middle: mu
				port map(
					s_in => stemp(4*j+i),
					b_in => btemp(4*j+i),
					a_in => atemp(5*j+i),
					c_in => ctemp(5*j+i),

					s_out => stemp(4*(j+1)+i),
					b_out => btemp(4*(j+1)+i),
					a_out => atemp(5*j+i+1),
					c_out => ctemp(5*j+i+1));
				end generate;
				
			column_end: if (i = 3) generate
				mu_end: mu
				port map(
					s_in => stemp(4*j+i),
					b_in => btemp(4*j+i),
					a_in => atemp(5*j+i),
					c_in => ctemp(5*j+i),

					s_out => stemp(4*(j+1)+i),
					b_out => btemp(4*(j+1)+i),
					a_out => open,
					c_out => ctemp(5*j+i+1));
				end generate;
				
		end generate column;
	end generate
	
	row_middle: if (j > 0) and (j < 3) generate
	
		column : for i in 0 to 3 generate			
			column_begin: if (i = 0) generate
				mu_begin: mu
				port map(
					s_in => stemp(4*j+i+1),
					b_in => btemp(4*j+i),
					a_in => atemp(5*j+i),
					c_in => ctemp(5*j+i),

					s_out => stemp(4*(j+1)+i),
					b_out => btemp(4*(j+1)+i),
					a_out => atemp(5*j+i+1),
					c_out => ctemp(5*j+i+1));
				end generate;
				
			column_middle: if (i > 0) and (i < 3) generate
				mu_middle: mu
				port map(
					s_in => stemp(4*j+i+1),
					b_in => btemp(4*j+i),
					a_in => atemp(5*j+i),
					c_in => ctemp(5*j+i),

					s_out => stemp(4*(j+1)+i),
					b_out => btemp(4*(j+1)+i),
					a_out => atemp(5*j+i+1),
					c_out => ctemp(5*j+i+1));
				end generate;
				
			column_end: if (i = 3) generate
				mu_end: mu
				port map(
					s_in => ctemp(5*(j-1)+i+1),
					b_in => btemp(4*j+i),
					a_in => atemp(5*j+i),
					c_in => ctemp(5*j+i),

					s_out => stemp(4*(j+1)+i),
					b_out => btemp(4*(j+1)+i),
					a_out => open,
					c_out => ctemp(5*j+i+1));
				end generate;
				
		end generate column;
	end generate
	
	row_end: if (j = 3) generate
	
		column : for i in 0 to 3 generate			
			column_begin: if (i = 0) generate
				port map(
					s_in => stemp(4*j+i+1),
					b_in => btemp(4*j+i),
					a_in => atemp(5*j+i),
					c_in => ctemp(5*j+i),

					s_out => stemp(4*(j+1)+i),
					b_out => open,
					a_out => atemp(5*j+i+1),
					c_out => ctemp(5*j+i+1));
				end generate;
				
			column_middle: if (i > 0) and (i < 3) generate
				mu_middle: mu
				port map(
					s_in => stemp(4*j+i+1),
					b_in => btemp(4*j+i),
					a_in => atemp(5*j+i),
					c_in => ctemp(5*j+i),

					s_out => stemp(4*(j+1)+i),
					b_out => open,
					a_out => atemp(5*j+i+1),
					c_out => ctemp(5*j+i+1));
				end generate;
				
			column_end: if (i = 3) generate
				mu_end: mu
				port map(
					s_in => stemp(5*(j-1)+i+1),
					b_in => btemp(4*j+i),
					a_in => atemp(5*j+i),
					c_in => ctemp(5*j+i),

					s_out => stemp(4*(j+1)+i),
					b_out => open,
					a_out => open,
					c_out => ctemp(5*j+i+1));
				end generate;
				
		end generate column;
	end generate
	
end generate row;

end rtl;
