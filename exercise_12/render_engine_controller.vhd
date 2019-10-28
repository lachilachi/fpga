library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--This module activates the renderer and stores the data of the render buffer 
--to the RAM. It also set the new frame ready signal to indicate that a 
--complete frame was rendered.

entity render_engine_controller is
  --generics:
  --G_H_RESOLUTION  : horizontal resolution
  --G_V_RESOLUTION  : vertical resolution
  generic (G_H_RESOLUTION : integer := 640;
           G_V_RESOLUTION : integer := 480);

  --ports:
  --clk                : system clock
  --reset              : synchronous reset
  --
  --i_buffer_full      : signalises that the buffer is full and that its 
  --                     content has to be written to the RAM
  --i_write_done       : indicates that the buffer was written to the RAM
  --i_page_switched    : indicates that the graphic output has done a page 
  --                     flip.
  --    
  --o_sample_positions : this output triggers the sampling of the ball and 
  --                     player positions
  --o_create_new_data  : activates the renderer
  --o_write_req        : requests a writing to the RAM
  --o_write_address    : the address where the data should be written
  --o_new_frame_ready  : indicates that a new frame was rendered and written 
  --                     to the RAM
  port (clk   : in std_logic := '0';
        reset : in std_logic := '0';

        i_buffer_full   : in std_logic := '0';
        i_write_done    : in std_logic := '0';
        i_page_switched : in std_logic := '0';

        o_sample_positions : out std_logic                      := '0';
        o_create_new_data  : out std_logic                      := '0';
        o_write_req        : out std_logic                      := '0';
        o_write_address    : out std_logic_vector (22 downto 0) := (others => '0');
        o_new_frame_ready  : out std_logic                      := '0');
end render_engine_controller;



architecture rtl of render_engine_controller is

--Type used to define the states of the state machine.
  type t_state_render_engine_controller is (CALCULATING, SAVE_BUFFER, FRAME_FINISHED);

--Signal set by process 1
--State of the state machine
  signal state_render_engine_controller : t_state_render_engine_controller := CALCULATING;
--Signal to increment the address
  signal increment_address              : std_logic                        := '0';

--Signal set by process 2
--This signal represents the MSB of the RAM address and is used to define in 
--which part (page) of the RAM data should be written. Its initial/reset value 
--has to be different from the one from the graphic output.
  signal page          : std_logic                                             := '1';
--Counter for the RAM address where to write data.
  signal cur_ram_block : integer range 0 to G_V_RESOLUTION*G_H_RESOLUTION/32-1 := 0;  -- 640*480/32 = 9600
  
begin
  --Type : registered Mealy state machine
  --       States : CALCULATING    : the renderer is enabled
  --                SAVE_BUFFER    : write request is sent to the ram 
  --                                 controller
  --                FRAME_FINISHED : a whole frame was rendered. the state 
  --                                 machine waits for page_switched signal 
  --                                 from the graphic output before rendering 
  --                                 the next frame.
  --Description : This state machine controls the renderer and write requests 
  --    to the RAM when the buffer is full.    
  process (clk)
  begin
    if (clk'event and clk = '1') then
      --Synchronous reset
      if (reset = '1') then
        state_render_engine_controller <= CALCULATING;
        increment_address              <= '0';
        o_create_new_data              <= '0';
        o_write_req                    <= '0';
        o_new_frame_ready              <= '0';
      --Normal operation
      else
        --Check the current state and calculae transitions to following 
        --state
        case state_render_engine_controller is
          when CALCULATING =>
            --Move to SAVING state when the buffer is full, request a 
            --write access to the RAM and disable the renderer.
            if (i_buffer_full = '1') then
              state_render_engine_controller <= SAVE_BUFFER;
              increment_address              <= '0';
              o_sample_positions             <= '0';
              o_create_new_data              <= '0';
              o_write_req                    <= '1';
              o_new_frame_ready              <= '0';
            --Stay in curent state
            else
              increment_address  <= '0';
              o_sample_positions <= '0';
              o_create_new_data  <= '1';
              o_write_req        <= '0';
              o_new_frame_ready  <= '0';
            end if;
            
          when SAVE_BUFFER =>
            --Data has been stored in the RAM
            if (i_write_done = '1') then
              --Move to FRAME_FINISHED if the data stored was the last part 
              --of a frame. The new frame ready and the address 
              --counter incrementation signals are set. Positon sampling is 
              --also activated.
              if cur_ram_block = G_H_RESOLUTION*G_V_RESOLUTION/32-1 then
                state_render_engine_controller <= FRAME_FINISHED;
                increment_address              <= '1';
                o_sample_positions             <= '1';
                o_create_new_data              <= '0';
                o_write_req                    <= '0';
                o_new_frame_ready              <= '1';
              --Return to CALCULATING state
              --The counter incrementation signal is set and the renderer 
              --is activated again.
              else
                state_render_engine_controller <= CALCULATING;
                increment_address              <= '1';
                o_sample_positions             <= '0';
                o_create_new_data              <= '1';
                o_write_req                    <= '0';
                o_new_frame_ready              <= '0';
              end if;
            --Stay in curent state
            else
              increment_address  <= '0';
              o_sample_positions <= '0';
              o_create_new_data  <= '0';
              o_write_req        <= '1';
              o_new_frame_ready  <= '0';
            end if;
            
          when FRAME_FINISHED =>
            --The graphic output module has displayed the whole frame. This 
            --space in the RAM is now free for a new frame and the renderer 
            --is activated and the state is changed to CALCULATING. Position 
            --sampling is deactivated.
            if (i_page_switched = '1') then
              state_render_engine_controller <= CALCULATING;
              increment_address              <= '0';
              o_sample_positions             <= '0';
              o_create_new_data              <= '1';
              o_write_req                    <= '0';
              o_new_frame_ready              <= '0';
            --Stay in curent state
            else
              increment_address  <= '0';
              o_sample_positions <= '1';
              o_create_new_data  <= '0';
              o_write_req        <= '0';
              o_new_frame_ready  <= '1';
            end if;
        end case;
      end if;
    end if;
  end process;


  --Type : registered
  --Description : If the increment address signal is active the address 
  --counter is increased. If it has already reached its maximum value (whole 
  --frame has been rendered), it is set to 0 and the page signal is inverted.
  process (clk)
  begin
    if (clk'event and clk = '1') then
      --Synchronous reset
      if (reset = '1') then
        page          <= '1';
        cur_ram_block <= 0;
      elsif (increment_address = '1') then
        report integer'image(cur_ram_block);
        if cur_ram_block = G_H_RESOLUTION*G_V_RESOLUTION/32-1 then
          cur_ram_block <= 0;
          page          <= not page;
        else
          cur_ram_block <= cur_ram_block + 1;
        end if;
      end if;
    end if;
  end process;


--process (clk)
--begin
--  if (clk'event and clk = '1') then
--    --Synchronous reset
--    if (reset = '1') then
--      page             <= '1';
--      cur_row <= (others => '0');
--      cur_col <= (others => '0');
--    elsif (increment_address = '1') then
--      -- check if we are near the end of a row, so we have to do a skip
--      if cur_col = C_COL_END then
--        cur_col <= (others => '0');
--        if cur_row = C_ROW_END then
--          -- whole frame done, flip page
--          cur_row <= (others => '0');
--          page    <= not page;
--        else
--          cur_row <= cur_row + 1;
--        end if;
--      else
--        cur_col <= cur_col + C_BURST_COUNT;
--      end if;
--    end if;
--  end if;
--end process;


--Assign the concatenation of the page and ram address to the 
--address output.
  o_write_address <= "0000" & page & std_logic_vector(to_unsigned(cur_ram_block, 14)) & "0000";

end rtl;

