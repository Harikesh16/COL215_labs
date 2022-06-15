library IEEE;                    -- importing standard libraries which we will be using
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.STD_LOGIC_unsigned.all;      -- imporitng the unsigned part just to make sure we add to vectors also.

entity Receiver is                    -- writing the entity of the receiver
Port (
    rx_in : IN std_logic;                -- the rx_input in the board
    reset_button : IN std_logic;            -- the reset button     
    rx_clock : IN std_logic;                   --  the clock we will be using
    Anode_Activate : OUT std_logic_vector(3 downto 0);     -- a vector for telling which of the leds will be lightening
    Output_LED : OUT std_logic_vector( 6 downto 0)      --  a vector for the seven segment leds 
    );
end Receiver;
 
architecture Behavioral of Receiver is              -- the behavioral of receiver written here

TYPE state_type is (idle, start, read, stop);      -- the fsm defined here with initially in idle state 
signal state : state_type := idle;             -- signal state_type in idle state

signal temp_count : natural range 0 to 700 := 0;   -- a temporary count
signal modulo_count : integer :=0;                -- a modulo count for led activation
signal new_clk : std_logic := '0';                 -- a new clock defined for trigerring after 1 cycle
signal count8 : integer := 0;
signal new_var : integer := 0;     -- defining a new int variable

 signal rx_reg : std_logic_vector(0 to 7); -- defining a new register to store value
 signal rx_reg2 : std_logic_vector(0 to 7); -- defining a new register to store value
signal which_led : STD_LOGIC_VECTOR (0 to 3) := (others => '0');   -- defining which of the led's to lighten here
signal n0,n1,n2,n3,p0,p1,p2,p3 : STD_LOGIC ;  -- defining signals for shortcut definitions used here


begin

process(which_led)  -- logic for 7 segment led display using Boolean expression
begin



n0 <= NOT which_led(0);    -- giving values to some of defined signals using which_led vector
n1 <= NOT which_led(1);
n2 <= NOT which_led(2);
n3 <= NOT which_led(3);

p0 <=  which_led(0);
p1 <=  which_led(1);
p2 <=  which_led(2);
p3 <=  which_led(3);




    ---- logic for all of the 7 leds defined using karnaugh map on the above signals
    Output_LED(0) <=   (n2 AND p3  AND p0 AND p1 ) OR (n3 AND n2 AND n1 AND p0) OR  (p3 AND p2 AND n1 AND p0) OR  (n3 AND p2 AND n1 AND n0);
      
    Output_LED(1) <=   (p0 AND p1 AND p3) OR (p2 AND p1 AND n0)  OR (p2 AND p3 AND n0 AND n1) OR (n3 AND p2 AND n1 AND p0); 
    
    Output_LED(2) <=  (p1 AND p2 AND p3) OR (n2 AND n3 AND p1 AND n0) OR (p2 AND p3 AND n0);
    
    Output_LED(3) <=  (n3 AND p2 AND n1 AND n0) OR (n1 AND n2 AND n3 AND p0) OR  (p3 AND n2 AND p1 AND n0) OR  (p0 AND  p1 AND p2);
                      
    Output_LED(4) <= (n1 AND p2 AND n3) OR (n2 AND n1 AND p0) OR (p0 AND n3);
    
    Output_LED(5) <= (n2 AND n3 AND p0) OR  (n2 AND n3 AND p1)  OR (p3 AND p2 AND n1 AND p0) OR (n3 AND p1 AND p0);
    
    Output_LED(6) <= (n1 AND n2 AND n3) OR (p2 AND p3 AND n1 AND n0) OR (n3 AND p0 AND p1 AND p2);
    
          
end process;
  


process(rx_reg2)        -- trigerring new process on rx_reg
    begin
    
        if((modulo_count mod 10000 ) <5000 ) then     -- half time first led and half time second led
        which_led(0) <= rx_reg2(0);
        which_led(1) <= rx_reg2(1); 
        which_led(2) <=rx_reg2(2);
        which_led(3) <=rx_reg2(3); 
        Anode_Activate <="1110";
        else which_led(0) <= rx_reg2(4);
        which_led(1) <= rx_reg2(5); 
        which_led(2) <=rx_reg2(6);
        which_led(3) <=rx_reg2(7); 
        Anode_Activate <="1101";
        end if;
    end process;
            


process(new_clk, rx_in, reset_button)        -- trigerring a new process on these three clock, board input and reset button
begin
if(rising_edge(new_clk)) then   


         -- if rising edge event
    if(reset_button = '1') then
       --rx_reg <="00000000";   -- to check the working of reset we can use this to display
        state <= idle;   
                             -- on resetting just move to the idle state
    else
    
    CASE state is 
        when idle =>                             -- if idle state 
            if(rx_in = '0') then                -- if input is 0 then start counting the number of 8's in count8
                count8 <= 1;
                state <= start;
            end if;
            
        when start =>         -- in start state
            if(rx_in = '1') then          -- if the rx_in is '1' then just move back to idle state and make count8 =0;
                state <= idle;
                count8 <= 0;
            elsif rx_in = '0' then 
                count8 <= count8+1;
                if(count8 = 7) then          -- if 8 one's are foind then just use it to start reading and set count8 to 0 again
                   state <= read;
                   new_var<=0; 
                   count8 <= 0;
                end if;
           end if;
           
      when read =>
            if(count8 >= 15) then                -- reading after cycle aster cycle 
                count8 <=0;
                rx_reg(new_var) <= rx_in;              -- storing data in rx_in 
                new_var  <= new_var + 1;              -- new_var value increases
               -- count8 <= count8 + 1;
            elsif(count8 <15) then
                count8 <= count8 + 1;                
            end if;
            
            if(new_var = 8) then
                rx_reg2 <= rx_reg;                 
                new_var<= 0;
                state <= stop;
            end if;
            
     when stop => 
            if(count8 <= 15) then
                count8 <= count8+1;
            else
                count8 <=0;
                state <= idle;
            end if;
            
         
      end case;
      end if;
   end if;
   
   
   
   end process;


process(rx_clock)                 -- trigerring a new process on rx_clock
    begin
        if(rising_edge(rx_clock)) then             -- if there is a rising edge in the clock
        modulo_count <= modulo_count +1;          -- adding 1 to modulo_count 
        temp_count <= temp_count+1;              -- adding 1 to cycle count
        
        if(temp_count = ((100000000/16)/2)/9600) then            -- the calculation for the number of cycles to read bits
            new_clk <= not new_clk;               -- trigerring the new_clk part
            temp_count <= 0;          -- temp count again changes to 0
        end if;
      end if;
end process;


            
              
end Behavioral;