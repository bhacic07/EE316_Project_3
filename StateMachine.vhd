library ieee;
use ieee.std_logic_1164.all;

entity StateMachine is 
      Port(
		  iClk             : in std_logic;
        reset            : in std_logic;
        BTN1             : in std_logic; 
		  State_O          : out std_logic_vector(1 downto 0)
		); 
		
end StateMachine;

architecture Behavioral of StateMachine is
		type State_type is (Channel_0, Channel_1, Channel_2, Channel_3); 
		signal CM, next_mode : State_type;
	   signal mode_value: std_logic_vector(1 downto 0);
		
begin
    process(iClk, reset)
    begin
        if reset = '1' then
            CM <= Channel_0;
        elsif rising_edge(iClk) then
            CM <= next_mode;
        end if;
    end process;
	 
	 process(CM, BTN1)
    begin
		next_mode <= CM;
        case CM is
            when Channel_0 =>
                if BTN1 = '1' then
						next_mode <= Channel_1;
					 end if;
				when Channel_1 =>
                if BTN1 = '1' then
						next_mode <= Channel_2;
					 end if;	
				when Channel_2 =>
					 if BTN1 = '1' then
						next_mode <= Channel_3;
					 end if;
					 when Channel_3 =>
					 if BTN1 = '1' then
						next_mode <= Channel_0;
					end if;
            when others =>
                next_mode <= Channel_0;
        end case;
    end process;
	  with CM select
        mode_value <= "00" when Channel_0,
		                "01" when Channel_1,
							 "10" when Channel_2,
                      "11" when Channel_3;
							 State_O <= mode_value;
end Behavioral;
