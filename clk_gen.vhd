library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_gen is
	port(
		clk 		: in std_logic; -- 50 MHz frequency (20 ns period)
		data_in 	: in std_logic_vector(7 downto 0);
		clk_out	: out std_logic
	);
end clk_gen;

architecture arch of clk_gen is

	signal freq_out	: integer; -- Frequency of clk_out
	signal clk_cnt		: integer := 0;
	signal divisor		: integer;
	constant freq_in	: integer := 50000000; -- Frequency of input clk

	begin
	
	-- Clock enable with variable frequency output
	process(clk, data_in)
	begin
	if data_in = X"FF" then
		freq_out <= 1500;
		divisor <= 33332;
	else
		freq_out <= (4 * to_integer(unsigned(data_in))) + 500;
		divisor <= freq_in / freq_out - 1;
	end if;
	
	if rising_edge(clk) then
      if (divisor = 1) then
		   clk_out <= '1';
			elsif (clk_cnt = divisor-1) then
				clk_cnt <= 0;
				clk_out <= '1';
			else
				clk_cnt <= clk_cnt + 1;
				clk_out <= '0';
			end if;
	end if;
	end process;

end arch;