library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_register is
   port(
		clk			: in std_logic;
		load			: in std_logic; -- enable
		x_in			: in std_logic_vector(7 downto 0);
		y_out			: out std_logic_vector(7 downto 0)
   );
end pwm_register;

architecture arch of pwm_register is

	begin
		
	process(clk)
	begin
		if rising_edge(clk) then
			if load = '1' then
				y_out <= x_in;
			end if;
		end if;
	end process;

end arch;
