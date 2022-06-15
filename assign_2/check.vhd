-- VHDL code for seven-segment display on Basys 3 FPGA
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity check is
    Port (  Input: in STD_LOGIC_VECTOR (3 downto 0);
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);
           Output_LED : out STD_LOGIC_VECTOR (6 downto 0));
end check;

architecture Behavioral of check is

signal n0,n1,n2,n3,p0,p1,p2,p3 : STD_LOGIC;



begin

n0 <= NOT Input(0);
n1 <= NOT Input(1);
n2 <= NOT Input(2);
n3 <= NOT Input(3);

p0 <=  Input(0);
p1 <=  Input(1);
p2 <=  Input(2);
p3 <=  Input(3);

Anode_Activate <= "1110";
process(Input)
begin

    Output_LED(0) <=   (n2 AND p3  AND p0 AND p1 ) OR (n3 AND n2 AND n1 AND p0) OR  (p3 AND p2 AND n1 AND p0) OR  (n3 AND p2 AND n1 AND n0);
    
 
    
    Output_LED(1) <=   (p0 AND p1 AND p3) OR (p2 AND p1 AND n0)  OR (p2 AND p3 AND n0 AND n1) OR (n3 AND p2 AND n1 AND p0); 
    
    Output_LED(2) <=  (p1 AND p2 AND p3) OR (n2 AND n3 AND p1 AND n0) OR (p2 AND p3 AND n0);
    
    Output_LED(3) <=  (n3 AND p2 AND n1 AND n0) OR (n1 AND n2 AND n3 AND p0) OR  (p3 AND n2 AND p1 AND n0) OR  (p0 AND  p1 AND p2);
                      
    Output_LED(4) <= (n1 AND p2 AND n3) OR (n2 AND n1 AND p0) OR (p0 AND n3);
    
    Output_LED(5) <= (n2 AND n3 AND p0) OR  (n2 AND n3 AND p1)  OR (p3 AND p2 AND n1 AND p0) OR (n3 AND p1 AND p0);
    
    Output_LED(6) <= (n1 AND n2 AND n3) OR (p2 AND p3 AND n1 AND n0) OR (n3 AND p0 AND p1 AND p2);
    
          
end process;


end Behavioral;
