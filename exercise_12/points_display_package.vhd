library IEEE;
use IEEE.STD_LOGIC_1164.all;

package points_display_package is
   component points_display is
      generic (G_POINTS_TO_WIN : integer := 15);
      
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
          
            i_player_1_points : in integer range 0 to G_POINTS_TO_WIN := 0;
            i_player_2_points : in integer range 0 to G_POINTS_TO_WIN := 0;
           
           o_anodes : out std_logic_vector (3 downto 0) := "1000";
           o_cathodes : out std_logic_vector (7 downto 0) := (others => '1'));
 end component;

   component bcd_digit is
      port (clk : in std_logic := '0';
            reset : in std_logic := '0';
          
            i_serial_data : in std_logic := '0';
           
            o_carry : out std_logic := '0';
            o_bcd : out std_logic_vector (3 downto 0) := (others => '1'));
   end component;

   --Converts the BCD code to a 7 bit logic vector for driving the seven 
   --segment displays
   function bcd_to_segments 
      (signal bcd : in std_logic_vector (3 downto 0))
   return std_logic_vector;

   --Returns the number of bits needed for a signal of the range of 'number'
   function number_of_bits
      (constant number : in integer)
      return integer;

end points_display_package;


package body points_display_package is

   --Converts the BCD code to a 7 bit logic vector for driving the seven 
   --segment displays
   function bcd_to_segments 
      (signal bcd : in std_logic_vector (3 downto 0)) 
      return std_logic_vector is
   
   variable segments : std_logic_vector (6 downto 0) := (others => '1');
  
   begin
      case bcd is
      when "0000" =>
         segments := "1000000";
      when "0001" =>
         segments := "1111001";
      when "0010" =>
         segments := "0100100";
      when "0011" =>
         segments := "0110000";
      when "0100" =>
         segments := "0011001";
      when "0101" =>
         segments := "0010010";
      when "0110" =>
         segments := "0000010";
      when "0111" =>
         segments := "1111000";
      when "1000" =>
         segments := "0000000";
      when "1001" =>
         segments := "0010000";
      when others =>
         segments := "1111111";
      end case;
      return segments; 
   end bcd_to_segments;


   --Returns the number of bits needed for a signal of the range of 'number'.
   function number_of_bits
      (constant number : in integer)
      return integer is
   
   constant C_MAX_BITS : integer := 256;
   
   variable cnt : integer := 1;
   variable bits : integer := 0;
   variable max_number_with_bits : integer := 2;
   
   begin
      for cnt in 1 to C_MAX_BITS loop
         if (max_number_with_bits - 1 >= number) then
            bits := cnt;
            exit;
         elsif (bits = C_MAX_BITS) then
            bits := 0;
            exit;
         else
            max_number_with_bits := max_number_with_bits * 2;
         end if;
      end loop;
      
      return bits;
      
   end number_of_bits;
   
end points_display_package;
