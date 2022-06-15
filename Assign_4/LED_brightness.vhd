library IEEE;                                        -- importing libraries/modules which are going to be used
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;


entity LED_brightness is                        -- defining an entity named led-brightness in which we will define input output ports

 Port (  Input: in STD_LOGIC_VECTOR (15 downto 0);    -- standard 16 bit input switch handler taken as a vector
         clck : in STD_LOGIC;                         -- standard clock which we will be using
         Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);    -- the anode activate vector in which we will be just changing the voltage values corresponding to a certain seven segment
         Output_LED : out STD_LOGIC_VECTOR (6 downto 0));  -- it defines the 7 segments led display

end LED_brightness;

architecture Behavioral of LED_brightness is          --  defining the behavioral of our led brightness entity

signal n0,n1,n2,n3,p0,p1,p2,p3 : STD_LOGIC ;          -- defining some signals which we are going to use afterwards
signal which_led : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');   -- another vector defined (as 0000) which of the 4 segments will be lighting
signal refresh_timer : STD_LOGIC_VECTOR (19 downto 0) := (others => '0');  -- 20 bit vector taken (initially defined by 0s) which we will be using as a counter
signal LED_activation :STD_LOGIC_VECTOR (1 downto 0) ;        -- 2 bit led activation vector which will be defining by the 18th and 19th bit of refresh timer
signal counter : integer := 0;   -- a counter integer defined just for counting the rising clock edges
 

begin                                 -- begining the behavioral


process(which_led)  -- logic for 7 segment led display using Boolean expression

begin


n0 <= NOT which_led(0);            -- giving values to some of defined signals using which_led vector
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
  
process(clck)             -- a new process on clock starts
begin 

    if(rising_edge(clck)) then  -- during the rising edge of the clock counter and refresh timer is increased and LED_activation has assigned 2-bit value
         refresh_timer <= refresh_timer + '1';
         counter <= counter + 1;
         LED_activation <= refresh_timer(19 downto 18);
         
    end if;
 end process;
    
 process(LED_activation)  --a new process on the led activations starts 
 begin
       case LED_activation is        -- using case statement for varying anode activation and which_led for the variation of 2 bits of led brightness
             when "00" =>
                 Anode_Activate <= "0111"; 
                 
                 which_led <= Input(15 downto 12);
                 
             when "01" =>

             	 if((counter mod 2200) < 1200) then       -- these if counter statements are just to make sure that the brightness vary because of the lighting time of the corresponding 7 segment
             	
                 	Anode_Activate <= "1011";
                 	
                 	
                 else Anode_Activate <= "1111";
                 
                 end if;

                  
                 which_led <= Input(11 downto 8);
                 
             when "10" =>

                 if((counter mod 2200) < 500) then
             		
                 	Anode_Activate <= "1101";
 
                 	
                 else Anode_Activate <= "1111";
             	
             	 end if;
             	
             	 
                 which_led <= Input(7 downto 4);
                 
             when "11" =>

             	if((counter mod 2200) < 100 ) then
             		
                 	Anode_Activate <= "1110";
             	
             	else Anode_Activate <= "1111";
             	
             	end if;
             	
             	which_led <= Input(3 downto 0);
                 
            when others =>
                 Anode_Activate <= "1111";    -- usually unreachable but just used for debugging
         end case;           -- end case statement
end process;                 -- end the process

end Behavioral;                   