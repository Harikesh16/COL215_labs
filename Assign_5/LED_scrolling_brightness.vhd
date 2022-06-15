library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;


entity LED_scrolling_brightness is

 Port (  Input_start: in STD_LOGIC_VECTOR (15 downto 0); 
         clck : in STD_LOGIC;
         button_digit : in STD_LOGIC;
         button_brightness :in STD_LOGIC;
         Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0); 
         Output_LED : out STD_LOGIC_VECTOR (6 downto 0)
         );  

end LED_scrolling_brightness;


--Some important signal defined here 

architecture Behavioral of LED_scrolling_brightness is

signal n0,n1,n2,n3,p0,p1,p2,p3 : STD_LOGIC ;  -- used for Boolean expression calculation
signal which_led : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');   -- used to obtain input from 4 group of swithches where each group contain 4 switches
signal refresh_timer : STD_LOGIC_VECTOR (19 downto 0) := (others => '0');  -- used for obtaining selection bit for 4:1 MUX  
signal LED_activation :STD_LOGIC_VECTOR (1 downto 0) ;   -- store the value of 4:1 MUX selection bit
signal Input : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');  -- temp signal 
signal Input1 : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');  --temporary signal

signal counter  : integer := 0;
signal counter1 : integer :=0;
signal counter2 : integer :=0;
signal seg_1 : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');   --used to store brightness value for particular digit  
signal seg_2 : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');  -- used to store brightness value for particular digit  
signal seg_3 : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');   -- used to store brightness value for particular digit  
signal seg_4 : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');  --used to store brightness value for particular digit   


begin



--procee for showing digit on 7 segment LED display usin Boolean expression derived from K map
process(which_led)

begin


n0 <= NOT which_led(0);
n1 <= NOT which_led(1);
n2 <= NOT which_led(2);
n3 <= NOT which_led(3);

p0 <=  which_led(0);
p1 <=  which_led(1);
p2 <=  which_led(2);
p3 <=  which_led(3);





    Output_LED(0) <=   (n2 AND p3  AND p0 AND p1 ) OR (n3 AND n2 AND n1 AND p0) OR  (p3 AND p2 AND n1 AND p0) OR  (n3 AND p2 AND n1 AND n0);
      
    Output_LED(1) <=   (p0 AND p1 AND p3) OR (p2 AND p1 AND n0)  OR (p2 AND p3 AND n0 AND n1) OR (n3 AND p2 AND n1 AND p0); 
    
    Output_LED(2) <=  (p1 AND p2 AND p3) OR (n2 AND n3 AND p1 AND n0) OR (p2 AND p3 AND n0);
    
    Output_LED(3) <=  (n3 AND p2 AND n1 AND n0) OR (n1 AND n2 AND n3 AND p0) OR  (p3 AND n2 AND p1 AND n0) OR  (p0 AND  p1 AND p2);
                      
    Output_LED(4) <= (n1 AND p2 AND n3) OR (n2 AND n1 AND p0) OR (p0 AND n3);
    
    Output_LED(5) <= (n2 AND n3 AND p0) OR  (n2 AND n3 AND p1)  OR (p3 AND p2 AND n1 AND p0) OR (n3 AND p1 AND p0);
    
    Output_LED(6) <= (n1 AND n2 AND n3) OR (p2 AND p3 AND n1 AND n0) OR (n3 AND p0 AND p1 AND p2);
    
          
end process;


-- clock usage as counter and logical expression for "selection bit " for 4:1 MUX

process(clck)


begin 

    if(rising_edge(clck)) then
   
         refresh_timer <= refresh_timer + '1';
         counter <= counter + 1;
         LED_activation <= refresh_timer(19 downto 18);
         
    end if;
 end process;
 
 -- Deboucing condtion for Push button and case of handling the brightness retaind during rotation of digits
process(button_digit,button_brightness,clck)

begin
  if(rising_edge(clck)) then
  
  
         --debouncing condition for brightness change using  push button
    if (button_brightness = '1' and counter2 >=10) then
      seg_1 <= Input_start(1 downto 0);
      seg_2 <= Input_start(3 downto 2);
      seg_3 <= Input_start(5 downto 4);
      seg_4 <= Input_start(7 downto 6);
      Input1 <= Input_start;
       
      elsif ((counter mod 400000000) <100000000 ) then  seg_4 <= Input1(7 downto 6);seg_3 <= Input1(5 downto 4);
       seg_2 <= Input1(3 downto 2);seg_1 <= Input1(1 downto 0);
      elsif ((counter mod 400000000) < 200000000 ) then   seg_4 <= Input1(5 downto 4);seg_3 <= Input1(3 downto 2);
        seg_2 <= Input1(1 downto 0);seg_1 <= Input1(7 downto 6);
      elsif ((counter mod 400000000) < 300000000 ) then  seg_4 <= Input1(3 downto 2);seg_3 <= Input1(1 downto 0);
         seg_2 <= Input1(7 downto 6);seg_1 <= Input1(5 downto 4);
      else  seg_4 <= Input1(1 downto 0); seg_4 <= Input1(1 downto 0);  seg_3 <= Input1(7 downto 6);seg_2 <= Input1(5 downto 4);
       seg_1 <= Input1(3 downto 2);
      end if;
  
     --debouncing condition for digit change using push button

       if (button_digit = '1' and counter1 >= 10) then
          Input <= Input_start;
        end if;
        
        -- reset of counter values
        
        if(button_digit = '1') then counter1 <= counter1+1; else counter1 <= 0;end if; 
        if(button_brightness = '1') then counter2 <= counter2+1; else counter2 <= 0; end if;
      
  end if;

end process;


--prcoess for digit rotation 

process(LED_activation)


begin

 case LED_activation is
 
    when "00" =>
               
         if ((counter mod 400000000) <100000000 ) then which_led <= Input(15 downto 12);
         elsif ((counter mod 400000000) < 200000000 ) then which_led <= Input(11 downto 8);  
         elsif ((counter mod 400000000) < 300000000 ) then which_led <= Input(7 downto 4);
         else which_led <= Input(3 downto 0); 
         end if ;
                 
    
                 
     when "01" =>
         
         if ((counter mod 400000000) < 100000000 ) then which_led <= Input(11 downto 8); 
         elsif ( (counter mod 400000000) < 200000000  ) then which_led <= Input(7 downto 4); 
         elsif ((counter mod 400000000) < 300000000 ) then which_led <= Input(3 downto 0); 
         else which_led <= Input(15 downto 12);
         end if ;
                  
          
                 
      when "10" =>

         if ((counter mod 400000000) < 100000000 ) then which_led <= Input(7 downto 4);
         elsif ( (counter mod 400000000) < 200000000 ) then which_led <= Input(3 downto 0); 
         elsif ((counter mod 400000000) < 300000000 ) then which_led <= Input(15 downto 12); 
         else which_led <= Input(11 downto 8); 
         end if ;

                 
      when "11" =>
             
                 
         if ((counter mod 400000000) <  100000000 ) then which_led <= Input(3 downto 0); 
         elsif ( (counter mod 400000000) < 200000000 ) then which_led <= Input(15 downto 12); 
         elsif ((counter mod 400000000) < 300000000 ) then which_led <= Input(11 downto 8); 
         else which_led <= Input(7 downto 4); 
         end if ;
                  
                 
            when others =>
                 which_led <=Input(3 downto 0);
         end case; 

end process;




  -- logic for brightness control of digit (basically time distribution of Anode activation)
  
 process(LED_activation,seg_1,seg_2,seg_3,seg_4)
 begin
       case LED_activation is
             when "00" =>
             
                 case seg_4 is
                 
                    when "00" => if ((counter mod 2200)<100) then  Anode_Activate <="0111"; else Anode_Activate <="1111"; end if;
                      
                    when "01" => if ((counter mod 2200)<500) then  Anode_Activate <="0111";
                    else Anode_Activate <="1111"; end if;
                    when "10" => if ((counter mod 2200)<1200) then  Anode_Activate <="0111";

                    
                     else Anode_Activate <="1111"; end if;
                     
                    when "11" =>  Anode_Activate <="0111";


                    when others => Anode_Activate <= "1111";
                  end case;
             

                 
             when "01" =>
             
                 case seg_3 is
                 when "00" => if ((counter mod 2200)<100) then Anode_Activate <="1011";

                      else Anode_Activate <="1111"; end if;
                      
                    when "01" => if ((counter mod 2200)<500) then Anode_Activate <="1011";
                    

                    
                     else Anode_Activate <="1111"; end if;
                     
                    when "10" => if ((counter mod 2200)<1200) then Anode_Activate <="1011";

                    
                     else Anode_Activate <="1111"; end if;
                     
                    when "11" => Anode_Activate <="1011";

               
                
                    when others => Anode_Activate <= "1111";
                 end case;
         
                  
          
                 
             when "10" =>
                 case seg_2 is
                 when "00" => if ((counter mod 2200)<100) then Anode_Activate <="1101";

                      
                      else Anode_Activate <="1111"; end if;
                      
                    when "01" => if ((counter mod 2200)<500) then Anode_Activate <="1101";
                    

                    
                     else Anode_Activate <="1111"; end if;
                    when "10" => if ((counter mod 2200)<1200) then Anode_Activate <="1101";

                    
                     else Anode_Activate <="1111"; end if;
                     
                     when "11" => Anode_Activate <="1101";

                   
                
                    when others => Anode_Activate <= "1111";
                  end case;

                 
             when "11" =>
             
             
                 case seg_1 is
                 when "00" => if ((counter mod 2200)<100) then Anode_Activate <="1110";

                      
                      else Anode_Activate <="1111"; end if;
                      
                    when "01" => if ((counter mod 2200)<500) then Anode_Activate <="1110";
                    

                     else Anode_Activate <="1111"; end if;
                     
                    when "10" => if ((counter mod 2200)<1200) then Anode_Activate <="1110";

                    
                     else Anode_Activate <="1111"; end if;
                     
                    when "11" => Anode_Activate <="1110";

                
                    when others => Anode_Activate <= "1111";
                  end case;
                 
            when others =>
                 Anode_Activate <= "1111"; 
         end case; 
end process;

end Behavioral;