library IEEE; -- importing required library
use IEEE.STD_LOGIC_unsigned.all; 
use IEEE.STD_LOGIC_1164.ALL;  


entity StopWatch is -- defining new entity named StopWatch

 Port ( --Input: in STD_LOGIC_VECTOR (15 downto 0); -- 16 bit input vector corresponding to 16 bit switch handler
         clck : in STD_LOGIC; -- using standard clock
         button_start : in STD_LOGIC; -- taking input the three buttons used for different purposes
         button_reset: in STD_LOGIC;
         button_pause : in STD_LOGIC;
         Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0); -- the anode activate vector in which we will be just changing
         -- the voltage values corresponding to a certain seven segment
         Output_LED : out STD_LOGIC_VECTOR (6 downto 0)); -- it defines the 7 segments led display


end StopWatch;  

architecture Behavioral of StopWatch is -- defining the behavioral of our StopWatch entity

signal n0,n1,n2,n3,p0,p1,p2,p3 : STD_LOGIC ; -- defining some signals which we are going to use afterwards
signal which_led : STD_LOGIC_VECTOR (3 downto 0) := (others => '0'); -- another vector defined (as 0000) which of the 4 segments will be lighting
signal refresh_timer : STD_LOGIC_VECTOR (19 downto 0) := (others => '0'); -- 20 bit vector taken (initially defined by 0s) which we will be using as a counter
signal LED_activation :STD_LOGIC_VECTOR (1 downto 0) ; -- 2 bit led activation vector which will be defining by the 18th and 19th bit of refresh timer
signal is_running : STD_LOGIC := '0';
signal clock_timer : natural range 0 to 10000005 ;
signal one_tenth_sec : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');   
signal one_sec : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');   
signal ten_secs : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');   
signal minute : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');   


begin -- -- begining the behavioral


process(which_led) -- logic for 7 segment led display using Boolean expression
begin
n0 <= NOT which_led(0); -- giving values to some of defined signals using which_led vector
n1 <= NOT which_led(1);
n2 <= NOT which_led(2);
n3 <= NOT which_led(3);
p0 <= which_led(0);
p1 <= which_led(1);
p2 <= which_led(2);
p3 <= which_led(3);
    ---- logic for all of the 7 leds defined using karnaugh map on the above signals

    Output_LED(0) <= (n2 AND p3 AND p0 AND p1 ) OR (n3 AND n2 AND n1 AND p0) OR (p3 AND p2 AND n1 AND p0) OR (n3 AND p2 AND n1 AND n0);
      
    Output_LED(1) <= (p0 AND p1 AND p3) OR (p2 AND p1 AND n0) OR (p2 AND p3 AND n0 AND n1) OR (n3 AND p2 AND n1 AND p0); 
    
    Output_LED(2) <= (p1 AND p2 AND p3) OR (n2 AND n3 AND p1 AND n0) OR (p2 AND p3 AND n0);
    
    Output_LED(3) <= (n3 AND p2 AND n1 AND n0) OR (n1 AND n2 AND n3 AND p0) OR (p3 AND n2 AND p1 AND n0) OR (p0 AND p1 AND p2);
                      
    Output_LED(4) <= (n1 AND p2 AND n3) OR (n2 AND n1 AND p0) OR (p0 AND n3);
    
    Output_LED(5) <= (n2 AND n3 AND p0) OR (n2 AND n3 AND p1) OR (p3 AND p2 AND n1 AND p0) OR (n3 AND p1 AND p0);
    
    Output_LED(6) <= (n1 AND n2 AND n3) OR (p2 AND p3 AND n1 AND n0) OR (n3 AND p0 AND p1 AND p2);     
end process;
  
process(clck) -- a new process on clock starts
begin  
    if(rising_edge(clck)) then -- during the rising edge of the clock counter and refresh timer is increased and LED_activation has assigned 2-bit value
        refresh_timer <= refresh_timer + '1';
         LED_activation <= refresh_timer(19 downto 18);
         if is_running ='1' then
            clock_timer <= clock_timer + 1;         
         end if;
         if clock_timer = 10000000 then
            clock_timer <= 0;
            one_tenth_sec <= one_tenth_sec+'1';
         end if;
         if one_tenth_sec = "1010" then
            one_tenth_sec <= "0000";
            one_sec <= one_sec+'1';
         end if;
         if one_sec="1010" then
            one_sec <= "0000";
            ten_secs <= ten_secs + '1';
         end if;
         if ten_secs = "0110" then
            ten_secs <= "0000";
            minute <=minute + '1';
         end if;
         if minute = "1010" then
            minute<= "0000";
         end if;  
         if button_start ='1' then
            is_running <= '1';
         end if;
         if button_pause ='1' then
           is_running <= '0';
         end if;
         if button_reset ='1' then
               one_tenth_sec <="0000";
               one_sec <= "0000";
               minute <= "0000";
               ten_secs <= "0000";
               is_running <= '0';
         end if;
    end if;
 end process;
    
 process(LED_activation) --a new process on the led activations starts 
 begin
       case LED_activation is -- using case statement for varying anode activation and which_led for the variation of 2 bits of led brightness
             when "00" =>
                 Anode_Activate <= "0111"; 
                 which_led <= minute;
             when "01" =>
                 Anode_Activate <= "1011"; 
                 which_led <= ten_secs;
             when "10" =>
                 Anode_Activate <= "1101"; 
                 which_led <= one_sec;
             when "11" =>
                 Anode_Activate <= "1110"; 
                 which_led <= one_tenth_sec; 
            when others =>
                 Anode_Activate <= "1111"; -- usually unreachable but just used for debugging
         end case; -- end case statement
end process; -- end the process

end Behavioral;