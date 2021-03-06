library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--This module controls the reloading of the graphic buffers. On each data 
--request of one of the buffers the active buffer is changed and the inactive 
--one is reloaded with data. This is done by sending a request to the ram 
--controller. After the data was loaded from the RAM it is stored in the 
--inactive. After that it also calculates the new address for the next read 
--operation. This includes inverting the page after a frame has been completely 
--displayed and the renderer singanlised that a new one was rendered (if no new 
--frame is ready after the current one is displayed, the current frame will be 
--repeated).

entity graphic_buffer_controller is
  --generics:
  --G_H_RESOLUTION  : horizontal resolution
  --G_V_RESOLUTION  : vertical resolution
  generic (G_H_RESOLUTION : integer := 640;
           G_V_RESOLUTION : integer := 480);

  --ports:
  --clk                : pixel clock
  --reset              : synchronous reset
  --
  --i_data_req_reg_0   : buffer 0 requests data
  --i_data_req_reg_1   : buffer 1 requests data
  --i_read_done        : signalises that data was read from the RAM
  --i_new_frame_ready  : signalises that a new frame is cmpletely stored in 
  --                     the RAM
  --
  --o_reg_select       : output for buffer selection (0 = buffer 0, 
  --                     1 = buffer 1)
  --o_load_reg         : load command for the buffers
  --o_read_req         : output for a read request (goes to ram controller)
  --o_read_address     : the address to read from
  --o_page_switched    : output to indicate a page flip (used by renderer as 
  --                     a signal to start rendering the next frame)
  port (clk   : in std_logic := '0';
        reset : in std_logic := '0';

        i_data_req_reg_0  : in std_logic := '0';
        i_data_req_reg_1  : in std_logic := '0';
        i_read_done       : in std_logic := '0';
        i_new_frame_ready : in std_logic := '0';

        o_reg_select    : out std_logic                      := '0';
        o_load_reg      : out std_logic                      := '0';
        o_read_req      : out std_logic                      := '0';
        o_read_address  : out std_logic_vector (22 downto 0) := (others => '0');
        o_page_switched : out std_logic                      := '0');
end graphic_buffer_controller;



architecture rtl of graphic_buffer_controller is

type fsm_states is (WAITING, REG_EMPTY, LOAD_REG);
signal state_fsm : fsm_states := WAITING;
signal flag : std_logic := '0';
signal address : integer := 0;



begin
 
    state_transitions : process (clk)
	--Umwandlung von meanlystate
	begin
		if rising_edge(clk) then
       
			if reset = '1' then
        		state_fsm <= WAITING;
				
        	else
        		case state_fsm is
        	    	when WAITING =>
        	            if(i_data_req_reg_0 = '1' or i_data_req_reg_1 = '1') then
						    state_fsm <= REG_EMPTY;
						end if;
					when REG_EMPTY =>
					    if(i_read_done = '1') then
						    state_fsm <= LOAD_REG;
						end if;
						
					when LOAD_REG =>
					
						 state_fsm <= LOAD_REG;
				end case;
			end if;
		end if;
	end process state_transitions;
	
	output: process(clk)
	-- output von unterschiedlichen Staten
	
	begin 
	    if rising_edge(clk) then
		
		    if reset = '1' then 
			   o_reg_select <= '0';
			   o_load_reg <= '0';
			   o_read_req <= '0';
			   address <= 0;
			   flag <= '0';
			   o_page_switched <= '0';
            else
			    if state_fsm = REG_EMPTY then
			        o_read_req <= '1';  --changed buffer
			        if i_data_req_reg_0 = '1' then    --aktiv buffer ist 0
			            o_reg_select <= '1';
			        else
				        o_reg_select <= '0';
				    end if;
					
			    elsif state_fsm = LOAD_REG then
			        o_load_reg <= '1';  
					 
				elsif state_fsm = WAITING then
				    o_load_reg <= '0';
					o_read_req <= '0';
					
				    if address = (G_H_RESOLUTION*G_V_RESOLUTION/2-16) then    --ein Bild ist ferig gelesen
					    address <= 0;
					    if i_new_frame_ready ='1' then
					        flag <= not(flag);
							o_page_switched <= '1';       --ein neue Frame ist vorbereitet, umwandeln wir um andere Seit
						else
						    o_page_switched <= '0';
                            flag <= flag;
                        end if;
                    else 
                        address <= address+16;
                        o_page_switched <= '0';
                    end if;
                end if;		  
			
			end if;
      			
		end if;
    		
	end process output;		
				
    o_read_address <= "0000" & flag & std_logic_vector(to_unsigned(address,18));




end rtl;