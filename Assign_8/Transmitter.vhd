library IEEE;                    -- importing standard libraries which we will be using
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.STD_LOGIC_unsigned.all;      -- imporitng the unsigned part just to make sure we add to vectors also.

entity Transmitter is               -- defining the entity for the Transmitter 
  Port (
    tx_clock : IN std_logic;      -- the tx_clock which we have used taken as input
    tx_start : IN std_logic;      -- the tx_start input taken as the bit whether transmission started or not
    storing_vector : IN std_logic_vector(0 TO 7);          -- the storing vector which is basically the bits recieved from reciever
    tx_output : OUT std_logic            -- the output of the transmitter part sending bit by bit 
   );
end Transmitter;

architecture Behavioral of Transmitter is      -- defining the behavioral of the transmitter

type fsm_state_type is (idle, start, read_and_tr);  -- defing the fsm with the 4 states and initializing it with the idle state
signal fsm_state : fsm_state_type := idle;


signal clk_counter :natural range 0 to 6000:= 0;
signal new_small_tx_clock : std_logic := '0';

signal bits_recieved : integer := 0;


begin         -- beginning of the process
    process(tx_start, new_small_tx_clock)        -- trigerring process on our tx_start bit and as well as the smalll clock
    begin
        if(rising_edge(new_small_tx_clock)) then    -- rising edge of the small clock
            CASE fsm_state is                        -- case of fsm states in case of transmitter
                    when idle =>                      -- the case of ideal state
                        if(tx_start = '1') then       --  when transmisson bit is 1 
                            fsm_state <= start;      -- then start transmitting
                        end if;
                        
                   when start =>                     -- in case of start state
                        bits_recieved<=0;             -- bits recieved 0
                        tx_output <= '0';             -- tx_output set as 0;
                        fsm_state<= read_and_tr;             -- start reading and transmitting
                     
                   when read_and_tr =>                                 -- in read_and_tr state
                        if(bits_recieved<8) then 
                            bits_recieved <= bits_recieved+1;      -- if bits recieved less than 8 then start recieving buit by bit and transmission
                            tx_output <= storing_vector(bits_recieved);        -- the bit recieved stored here
                        else 
                            fsm_state <= idle;        -- once completely recieved then state changed to idle
                            tx_output<= '1';          -- and tx_output set to 1 again
                     --       bits_recieved <= 0;
                        end if;    
            end case;
        end if;
      end process;
        
   process(tx_clock)            -- trigering process clock
     begin                        -- begin
         if(rising_edge(tx_clock)) then  -- if rising edge of tx_clock
         clk_counter<= clk_counter+1;         -- counter increased by 1 on each clock rising edge
         if(clk_counter = (100000000/2)/9600) then              -- calculations for transmitting per cycle
             new_small_tx_clock <= not new_small_tx_clock;      -- the small clock is trigerred here
             clk_counter<=0;
         end if;
       end if;
     end process;     -- eending the ifs and as well as the processes

end Behavioral;      -- ending ythe behavioral part