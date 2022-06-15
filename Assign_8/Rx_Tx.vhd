library IEEE;                    -- importing standard libraries which we will be using
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.STD_LOGIC_unsigned.all;      -- imporitng the unsigned part just to make sure we add to vectors also.

entity Rx_Tx is                      -- defining a new entity Rx_Tx
  Port (
        rx_input : IN STD_LOGIC;
        Anode_Activate : OUT STD_LOGIC_vector(3 downto 0);     -- a vector for telling which of the leds will be lightening
        Output_LED : OUT STD_LOGIC_vector( 6 downto 0);  --  a vector for the seven segment leds 
        reset_bt : IN STD_LOGIC;   -- the resdet button as input
        rx_clock : IN STD_LOGIC;          -- the rx_clock is the clock which we are taking as input
        tx_output : OUT STD_LOGIC         -- tx_output is basically the connector i.e. input output which we will be using
      
   );
end Rx_Tx;

architecture Behavioral of Rx_Tx is     -- defining the architechture of rx_Tx and then defining its components
            component Receiver      -- the reciever component
            Port(                            --  the port definitions here
               rx_in : IN STD_LOGIC;                -- the rx_input in the board
               reset_button : IN STD_LOGIC;            -- the reset button uis defined here
               rx_clock : IN STD_LOGIC;                   --  the clock we will be using in the board
               Anode_Activate : OUT STD_LOGIC_vector(3 downto 0);     -- a vector for telling which of the leds will be lightening
               Output_LED : OUT STD_LOGIC_vector( 6 downto 0) ;     --  a vector for the seven segment leds 
               vect : OUT STD_LOGIC_vector(0 to 7);                 -- a vector vect is defined which will be the bridge in two components
               tx_st : OUT STD_LOGIC                  --  the transmitter start boolean is this
              );
            end component;
            component Transmitter           -- the transmitter component
            Port (
                tx_start : IN STD_LOGIC;       --  the transition starting bit which we are recieving from the reciever part
                tx_clock : IN STD_LOGIC;           -- the transition clock
                storing_vector : IN STD_LOGIC_vector(0 TO 7);   -- the vector i.e. 8 bits which we are recieving from the reiever part
                tx_output : OUT STD_LOGIC          -- the transition output
               );
            end component;
--------------- now we will be defining the dummy vector signals here which we will be giving inputs in the reciever and Transmitter port
signal dummy_sig: STD_LOGIC;
signal dummy_vect_sig : STD_LOGIC_vector(0 to 7);
begin  
    A : Receiver port Map(      -- defining the port map entries for the reciever end
        rx_clock => rx_clock, 
        vect => dummy_vect_sig, 
        tx_st=>dummy_sig,
        Anode_Activate => Anode_Activate , 
        Output_LED => Output_LED, 
        rx_in => rx_input, 
        reset_button => reset_bt
        );
    B :  Transmitter port Map(    -- defining the port map entries for the transmitter end
        tx_start => dummy_sig,
        tx_clock => rx_clock,
        storing_vector => dummy_vect_sig,  
        tx_output => tx_output);
end Behavioral;           -- ending the behavioral part 