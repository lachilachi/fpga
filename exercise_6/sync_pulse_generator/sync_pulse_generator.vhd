library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--This module creates the horizontal and vertical synchronisation impulses for
--the monitor.
--It also sets an output when the electron beam on the screen is in the active 
--picture area.
--The first and last rows and columns of a picture are not displayed. They are 
--used for synchronisation impulses and to move the electron beam back to the 
--left or top of the screen. For that time the colour data must not be send to 
--the monitor because otherwise it could not synchronise correctly. To indicate 
--if the electron beam is in the picture area, there is an output called 
--in_active_region.

entity sync_pulse_generator is
   --generics:
   --G_H_PIXEL_NUMBER   : horizontal pixel number (incl. non visible)
   --G_H_RESOLUTION     : horizontal resolution
   --G_H_FRONT_PORCH    : horizontal front porch length in pixels
   --G_H_BACK_PORCH     : horizontal back porch length in pixels
   --G_H_SYNC_LENGTH    : horizontal sync pulse length in pixels
   --G_H_SYNC_ACTIVE    : horizontal sync pulse polarity (1 = pos, 0 = neg)
   --
   --G_V_PIXEL_NUMBER   : vertical pixel number (incl. non visible)
   --G_V_RESOLUTION     : vertical resolution
   --G_V_FRONT_PORCH    : vertical front porch length in pixels
   --G_V_BACK_PORCH     : vertical back porch length in pixels
   --G_V_SYNC_LENGTH    : vertical sync pulse length in pixels
   --G_V_SYNC_ACTIVE    : vertical sync pulse polarity (1 = pos, 0 = neg)
   generic (G_H_PIXEL_NUMBER : integer := 800;
            G_H_RESOLUTION : integer := 640;
            G_H_FRONT_PORCH : integer := 8;
            G_H_BACK_PORCH : integer := 48;
            G_H_SYNC_LENGTH : integer := 96;
            G_H_SYNC_ACTIVE : std_logic := '0';
             
            G_V_PIXEL_NUMBER : integer := 525;
            G_V_RESOLUTION : integer := 480;
            G_V_FRONT_PORCH : integer := 2;
            G_V_BACK_PORCH : integer := 33;
            G_V_SYNC_LENGTH : integer := 2;
            G_V_SYNC_ACTIVE : std_logic := '0');

   port (clk : in  std_logic := '0';
         reset : in std_logic := '0';
         
         o_h_sync : out std_logic := G_H_SYNC_ACTIVE;
         o_v_sync : out std_logic := G_V_SYNC_ACTIVE;
         o_in_active_region : out std_logic := '0');
end sync_pulse_generator;



architecture rtl of sync_pulse_generator is

signal i : integer := 0;
signal j : integer := 0;
signal act_h : std_logic := '0';
signal act_v : std_logic := '0';



begin
o_in_active_region <= act_h and act_v;
			 
process (clk)
begin
	if (clk'event and clk = '1') then
		if (reset = '1') then   
			i <= 0;
			j <= 0;
			act_h <= '0';
			act_v <= '0';
			o_h_sync <= not(G_H_SYNC_ACTIVE);
			o_v_sync <= not(G_V_SYNC_ACTIVE);    
		else
			
			if (i = G_H_PIXEL_NUMBER - 1) then  
				i <= 0;                               
				if (j = G_V_PIXEL_NUMBER - 1) then  
					j <= 0;                            
				else
					j <= j + 1;
				end if;
			else
				i <= i + 1;
			end if;
			
			
			--row
			if (i = G_H_FRONT_PORCH - 1) then
				o_h_sync <= G_H_SYNC_ACTIVE;
			elsif (i = G_H_FRONT_PORCH + G_H_SYNC_LENGTH - 1) then
				o_h_sync <= not(G_H_SYNC_ACTIVE);
			end if;
			
			--column
			if (i = G_H_PIXEL_NUMBER - 1) then  --right border
				if (j = G_V_FRONT_PORCH - 1) then
					o_v_sync <= G_V_SYNC_ACTIVE;
				elsif (j = G_V_FRONT_PORCH + G_V_SYNC_LENGTH - 1) then
					o_v_sync <= not(G_V_SYNC_ACTIVE);
				end if;
			end if;
			
			if (i = G_H_FRONT_PORCH + G_H_SYNC_LENGTH + G_H_BACK_PORCH - 1) then
				act_h <= '1';
			elsif (i = G_H_FRONT_PORCH + G_H_SYNC_LENGTH + G_H_BACK_PORCH + G_H_RESOLUTION - 1) then
				act_h <= '0';
			end if;
			
			
			if (j = G_V_FRONT_PORCH + G_V_SYNC_LENGTH + G_V_BACK_PORCH) then
				act_v <= '1';
			elsif (j = G_V_FRONT_PORCH + G_V_SYNC_LENGTH + G_V_BACK_PORCH + G_V_RESOLUTION) then
				act_v <= '0';
			end if;
			
			

		end if;
	end if;
end process;

end rtl;

