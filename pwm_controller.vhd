library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_controller is
   port(
		clk 		: in std_logic;
		reset 	: in std_logic; -- Active high
		data_in	: in std_logic_vector(7 downto 0);
		pwm 		: out std_logic
   );
end PWM_controller;

architecture arch of PWM_controller is

	signal cnt_out 	: std_logic_vector(7 downto 0);
	signal x				: std_logic;
	signal c				: std_logic;
	signal a				: std_logic_vector(7 downto 0);
	
	begin
	
	inst_comparator : entity work.comparator
		port map(
			clk 	=> clk,
			a 		=> a,
			b 		=> cnt_out,
			c 		=> c
		);
		
	inst_RS_latch : entity work.RS_latch
		port map(
			clk 	=> clk,
			r 		=> c,
			s 		=> x,
			q 		=> pwm
		);
		
	inst_pwm_counter : entity work.pwm_counter
		generic map(N => 8, N1 => 0, N2 => 255)
		port map(
			clk			=> clk,
			reset			=> reset,
			syn_clr		=> '0',
			load			=> '0',
			en				=> '1',
			up				=> '1',
			clk_en 		=> '1',	
			d				=> "00000000",
			max_tick		=> x,
			min_tick		=> open,
			q				=> cnt_out
		);
		
	inst_register : entity work.pwm_register
		port map(
			clk			=> clk,
			load			=> x,
			x_in			=> data_in,
			y_out			=> a
		);

end arch;
