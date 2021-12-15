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
            G_H_RESOLUTION : integer := 640; --4
            G_H_FRONT_PORCH : integer := 8;  --1
            G_H_BACK_PORCH : integer := 48;  --3
            G_H_SYNC_LENGTH : integer := 96; --2
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

begin

column: process(clk, reset)
variable i:integer := 1;
variable j:integer := 1;
begin
	if reset = '1' then
		o_h_sync <= G_H_SYNC_ACTIVE;
		o_v_sync <= G_V_SYNC_ACTIVE;
		o_in_active_region <= '0';
	
	elsif clk'event and clk='1' then
		if (j>0 and j<G_V_FRONT_PORCH) then
			if (i>0 and i<G_H_FRONT_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
		
			elsif (i>=G_H_FRONT_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH) then
				o_h_sync <= G_H_SYNC_ACTIVE;
				
				i := i+1;
				
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION and i<=G_H_PIXEL_NUMBER) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
				if i>G_H_PIXEL_NUMBER then 
					i:=1;
					j := j+1;
				end if;
			end if;
			o_v_sync <= not G_V_SYNC_ACTIVE;
			o_in_active_region <= '0';
			
		
		elsif (j>=G_V_FRONT_PORCH and j<G_V_FRONT_PORCH+G_V_SYNC_LENGTH) then
			if (i>0 and i<G_H_FRONT_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
		
			elsif (i>=G_H_FRONT_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH) then
				o_h_sync <= G_H_SYNC_ACTIVE;
				
				i := i+1;
				
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION and i<=G_H_PIXEL_NUMBER) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
				if i>G_H_PIXEL_NUMBER then 
					i:=1;
					j := j+1;
				end if;
			end if;
			o_v_sync <= G_V_SYNC_ACTIVE;
			o_in_active_region <= '0';
			
			
		elsif (j>=G_V_FRONT_PORCH+G_V_SYNC_LENGTH and j<G_V_FRONT_PORCH+G_V_SYNC_LENGTH+G_V_BACK_PORCH) then
			if (i>=0 and i<G_H_FRONT_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
		
			elsif (i>=G_H_FRONT_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH) then
				o_h_sync <= G_H_SYNC_ACTIVE;
				
				i := i+1;
				
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION and i<=G_H_PIXEL_NUMBER) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
				if i>G_H_PIXEL_NUMBER then 
					i:=1;
					j := j+1;
				end if;
			end if;
			o_v_sync <= not G_V_SYNC_ACTIVE;
			o_in_active_region <= '0';
			
		
		elsif (j>=G_V_FRONT_PORCH+G_V_SYNC_LENGTH+G_V_BACK_PORCH and j<G_V_FRONT_PORCH+G_V_SYNC_LENGTH+G_V_BACK_PORCH+G_V_RESOLUTION) then
			if (i>=0 and i<G_H_FRONT_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				o_in_active_region <= '0';
				i := i+1;
		
			elsif (i>=G_H_FRONT_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH) then
				o_h_sync <= G_H_SYNC_ACTIVE;
				o_in_active_region <= '0';
				i := i+1;
				
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				o_in_active_region <= '0';
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				o_in_active_region <= '1';
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION and i<=G_H_PIXEL_NUMBER) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				o_in_active_region <= '0';
				i := i+1;
				if i>G_H_PIXEL_NUMBER then 
					i:=1;
					j := j+1;
				end if;
			end if;
			o_v_sync <= not G_V_SYNC_ACTIVE;
			
			
		
		elsif (j>G_V_FRONT_PORCH+G_V_SYNC_LENGTH+G_V_BACK_PORCH+G_V_RESOLUTION and j<=G_V_PIXEL_NUMBER) then
			if (i>0 and i<G_H_FRONT_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
		
			elsif (i>=G_H_FRONT_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH) then
				o_h_sync <= G_H_SYNC_ACTIVE;
				
				i := i+1;
				
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH and i<G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
			
			elsif (i>=G_H_FRONT_PORCH+G_H_SYNC_LENGTH+G_H_BACK_PORCH+G_H_RESOLUTION and i<=G_H_PIXEL_NUMBER) then
				o_h_sync <= not G_H_SYNC_ACTIVE;
				
				i := i+1;
				if i>G_H_PIXEL_NUMBER then 
					i:=1;
					j := j+1;
				end if;
			end if;
			o_v_sync <= not G_V_SYNC_ACTIVE;
			o_in_active_region <= '0';
			
			if j>G_V_PIXEL_NUMBER then j:=1;
			end if;
		end if;
	end if;
end process;
		
end rtl;

