library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
   port(
		clk 	: in std_logic;
		a 		: in std_logic_vector(7 downto 0); -- 8-bit data from counter (PWM)
		b 		: in std_logic_vector(7 downto 0); -- 8-bit data from SRAM
		c 		: out std_logic -- 1 when a and b are equal, 0 otherwise
   );
end comparator;

architecture arch of comparator is

	begin
	
	process(clk)
	begin
		if rising_edge(clk) then
			if a = b then
				c <= '1';
			else
				c <= '0';
			end if;
		end if;
	end process;

end arch;
