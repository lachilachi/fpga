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

-- signal declaration
signal stemp : std_logic_vector (19 downto 0) := (others => '0');
signal ctemp : std_logic_vector (19 downto 0) := (others => '0');
signal atemp : std_logic_vector (19 downto 0) := (others => '0');
signal btemp : std_logic_vector (19 downto 0) := (others => '0');
signal ptemp : std_logic_vector (19 downto 0) := (others => '0');


-- component declaration
--component comb_logic is
--  port (s_in : in std_logic := '0';
--        b_in : in std_logic := '0';
--        a_in : in std_logic := '0';
--        c_in : in std_logic := '0';

--        s_out : out std_logic := '0';
--        b_out : out std_logic := '0';
--        c_out : out std_logic := '0';
--        a_out : out std_logic := '0');
--end component comb_logic;


  
  
begin



  io_register : process (clk, reset)
  begin  -- process mult
    if rising_edge(clk) then            -- rising clock edge
      if reset = '1' then               -- synchronous reset (active high)

        atemp(0) <= '0';
        atemp(4) <= '0';
        atemp(8) <= '0';
        atemp(12) <= '0';
        btemp(0) <= '0';
        btemp(1) <= '0';
        btemp(2) <= '0';
        btemp(3) <= '0';
        ptemp <= (others => '0');
        
      else
        
        atemp(0) <=i_a(0) ;
        atemp(4) <=i_a(1) ;
        atemp(8) <=i_a(2) ;
        atemp(12) <=i_a(3) ;
        btemp(0) <= i_b(0);
        btemp(1) <= i_b(1);
        btemp(2) <= i_b(2);
        btemp(3) <= i_b(3);

        o_p(7) <= ctemp(19);
        o_p(6) <= stemp(19);
        o_p(5) <= stemp(18);
        o_p(4) <= stemp(17);
        o_p(3) <= stemp(16);
        o_p(2) <= stemp(12);
        o_p(1) <= stemp(8);
        o_p(0) <= stemp(4);

        
        
      end if;
    end if;
  end process io_register;



 
 
 
----------------------------------------------------------------------------------------------------
-- Generate statements
--nested loop with j = row, i = column
--------------------------------------------------------------------------------------------------------------

 -- row : for j in 0 to 3 generate
    column : for i in 0 to 15 generate
      
      -- first row 
      
     -- first_row: if (j=0) generate
      begin
        
      column_begin_1: if (i=0) generate
      MU1: entity work.mu port map (s_in => stemp(i),
          b_in => btemp(i),
          a_in => atemp(i),
          c_in => ctemp(i),
          s_out => stemp(i+4),
          b_out => btemp(i+4),
          c_out => ctemp(i+1),
          a_out => atemp(i+1));
      end generate;

      column_mittel_1: if (i=1) and (i=2) generate
      MU2: entity work.mu
        port map (
          s_in => stemp(i),
          b_in => btemp(i),
          a_in => atemp(i),
          c_in => ctemp(i),
          
          s_out => stemp(i+4),
          b_out => btemp(i+4),
          c_out => ctemp(i+1),
          a_out => atemp(i+1));
      end generate;
      
      column_end_1: if(i=3) generate
      MU3: entity work.mu
        port map (
          s_in => stemp(i),
          b_in => btemp(i),
          a_in => atemp(i),
          c_in => ctemp(i),
          
          s_out => stemp(i+4),
          b_out => btemp(i+4),
          c_out => ptemp(i),
          a_out => open);
      end generate;
      
      column_end_2: if(i=7) and (i=11) and (i=15) generate
      MU4: entity work.mu
        port map (
          s_in => ptemp(i-4),
          b_in => btemp(i),
          a_in => atemp(i),
          c_in => ctemp(i),
          
          s_out => stemp(i+4),
          b_out => btemp(i+4),
          c_out => ptemp(i),
          a_out => open);
      end generate;
      
      column_mittel_2: if (i=5) and (i=6) and (i=9)and (i=10)and (i=13)and (i=14)generate
      MU5: entity work.mu
        port map (
          s_in => stemp(i+1),
          b_in => btemp(i),
          a_in => atemp(i),
          c_in => ctemp(i),
          
          s_out => stemp(i+4),
          b_out => btemp(i+4),
          c_out => ctemp(i+1),
          a_out => atemp(i+1));
      end generate;
      
       column_begin_2: if (i=4) and (i=8)and (i=12)generate
      MU6: entity work.mu port map (s_in => stemp(i+1),
          b_in => btemp(i),
          a_in => atemp(i),
          c_in => ctemp(i),
          s_out => stemp(i+4),
          b_out => btemp(i+4),
          c_out => stemp(i+1),
          a_out => atemp(i+1));
      end generate;
  --  end generate first_row;
      
      
     --j_1: if (j>0 and j<3) generate
    
     -- column : for i in 0 to 4 generate
      --column_begin: if (i=0) generate
     -- mu_begin: entity work.mu
       -- port map (
         -- s_in => stemp((j-1)*4+i+1),
     --     b_in => i_b(i),
       --   a_in => i_a(j),
      --    c_in => '0',
          
      --    s_out => stemp(i+j*4),
      --    b_out => btemp(i),
      --    c_out => ctemp(i),
       --   a_out => atemp(j));
      --end generate;

   --   column_mittel: if (i>0) and (i<4) generate
   --   mu_mittel: entity work.mu
    --    port map (
     --     s_in => stemp((j-1)*4+i+1),
      --    b_in => btemp(i),
     --     a_in => atemp(j),
     --     c_in => ctemp(j*4+i-1),
          
      --    s_out => stemp(i+j),
      --    b_out => btemp(i),
      --    c_out => ctemp(j*4+i),
       --   a_out => atemp(j));
     -- end generate;

  --  end generate;

      
    end generate column;
--  end generate row;


end rtl;
