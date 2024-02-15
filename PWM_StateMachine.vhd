library ieee;
use ieee.std_logic_1164.all;

entity PWM_StateMachine is
    Port (
        iClk             : in std_logic;
        reset            : in std_logic;
        KEY3             : in std_logic;
        state            : in std_logic_vector (2 downto  0);
        pwm_mode       : out std_logic_vector (1 downto  0)
    );
end PWM_StateMachine;

architecture Behavioral of PWM_StateMachine is
    type State_type is (sixty, one_twenty, one_thousand) ;
    signal CM, next_mode : State_type;
	 signal mode_value: std_logic_vector(1 downto 0);


    begin
    -- State transition logic
    process(iClk, reset)
    begin
        if reset = '1' then
            CM <= sixty;
        elsif rising_edge(iClk) then
            CM <= next_mode;
        end if;
    end process;

    -- Next state logic
    process(CM, KEY3)
    begin
		next_mode <= CM;
        case CM is
            when sixty =>
                if KEY3 = '1' then
						next_mode <= one_twenty;
					 end if;
				when one_twenty =>
                if KEY3 = '1' then
						next_mode <= one_thousand;
					 end if;	
				when one_thousand =>
					 if KEY3 = '1' then
						next_mode <= sixty;
					 end if;
            when others =>
                next_mode <= sixty;
        end case;
    end process;

    with CM select
        mode_value <= "01" when sixty,
							 "10" when one_twenty,
                      "11" when one_thousand;
							 pwm_mode <= mode_value;
end Behavioral;
