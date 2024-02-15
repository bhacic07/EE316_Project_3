library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity stateMachine is
	PORT (
		iClk					: in std_logic;
		reset					: in std_logic;
		key1					: in std_logic;
		key2					: in std_logic;
		key3					: in std_logic;
		counter				: in std_logic_vector(7 downto 0);
		state					: out std_logic_vector (3 downto 0);
		freq					: out std_logic_vector(1 downto 0)
	);

end stateMachine;

architecture Behavioral of stateMachine is

	type State_type is (INIT, TEST, PAUSE, PWM_GEN) ;
	type freq_state_type is (SIXTY, ONE_TWENTY, ONE_THOUSAND);
	signal CS, next_state : state_type;
	signal CS_freq : freq_state_type;
	signal state_value: std_logic_vector(3 downto 0);
	signal init_flag	:std_logic := '0';
	--signal freq_value : std_logic_vector(1 downto 0) := "00";
	
	
	 

	

	
	begin 
	

    process(iClk, reset) 

    begin 

        if reset = '1' then 
				
				init_flag <= '0';				
            CS <= INIT; 

             

        elsif rising_edge(iClk) then  

            CS <= next_state; 

             

        end if; 

		if counter = "11111111" then
			init_flag <= '1';				--Initilzation Flag Sets After Initilzation Finishes
		end if;	
    end process; 
	
	
	
	
	
	
	
	
	process(iclk, key3, reset)
	begin
		if reset = '1' then
			CS_freq <= SIXTY;
		elsif(rising_edge(iclk) and state_value = "1000") then
			case CS_freq is
				when SIXTY =>
					freq <= "00";
					if key3 = '1' then
						CS_freq <= ONE_TWENTY;
					end if;
				when ONE_TWENTY =>
					freq <= "01";
					if key3 = '1' then
						CS_freq <= ONE_THOUSAND;
					end if;
				when ONE_THOUSAND =>
					freq <= "10";
					if key3 = '1' then
						CS_freq <= SIXTY;
					end if;
			end case;
	end if;
end process;
	
	
	
	
	process(CS, key1 ,key2, key3, counter)
	begin
	  next_state <= CS;
	      case CS is
			
	        when INIT =>  
					 if counter = "00000000" and init_flag = '1' then 
                    next_state <= TEST; 
                    --counter <= (others => '0'); 
                end if; 	
					
					
	        when TEST =>
					if key1 = '1' then			--key1 Send to PAUSE
						next_state <= PAUSE;
					elsif key2 = '1' then		-- key2 Send to PWM_GEN
						next_state <= PWM_GEN;
					end if;
					
					
			  when PAUSE =>
					if key1 = '1' then			--key1 Send to TEST
						next_state <= TEST;
					end if;

	
	
			  when PWM_GEN =>
					if key2 = '1' then			--key2 Send to TEST
						next_state <= TEST;
					end if;
			  
        when others => next_state <= INIT;
			  
			  
       end case;
   	            	               	    	    
	end process;
	
	
  with cs select
  state_value <= "0001" when INIT,

                 "0010" when TEST, 

                 "0100" when  PAUSE, 

                 "1000" when  PWM_GEN,  

                 "0000" when others;  -- Default value for unknown states 
                 state <= state_value;
end Behavioral;




