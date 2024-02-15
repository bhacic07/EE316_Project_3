library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RS_latch is
   port(
		clk 	: in std_logic;
		r 		: in std_logic; -- From comparator
		s 		: in std_logic; -- From counter
		q 		: out std_logic
   );
end RS_latch;

architecture arch of RS_latch is

	signal notQ 	: std_logic := '1';
	signal q_sig 	: std_logic := '0';
	signal t1, t2  : std_logic;
	
	begin
	
	t1 <= r nor t2;
   t2 <= s nor t1;
		
	process(clk)
	begin
		if rising_edge(clk) then
		
			if(r = '0' and s = '0') then
				Q <= t1;
            notQ <= t2;
         elsif(r = '0' and s = '1') then
            Q <= '1';
            notQ <= '0';
         elsif(r = '1' and s = '0') then
            Q <= '0';
            notQ <= '1';
         elsif(r = '1' and s = '1') then
            Q <= 'X';
            notQ <= 'X';
         end if;

		end if;
	end process;

end arch;
