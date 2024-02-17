LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY user_logic_LCD IS
  GENERIC (
    CONSTANT cnt_max : integer := 208333/2
  );
  PORT(
    clk       : in     STD_LOGIC;                     
    reset     : in     STD_LOGIC;
    data_in   : in     STD_LOGIC_VECTOR(15 DOWNTO 0); 
    addr_in   : in     STD_LOGIC_VECTOR(7 DOWNTO 0);  
    selectPWM : in     STD_LOGIC_VECTOR(1 DOWNTO 0);  
    selectMode: in     STD_LOGIC_VECTOR(1 DOWNTO 0);  
    data_out  : out    STD_LOGIC_VECTOR(7 DOWNTO 0);  
    RS        : out    STD_LOGIC;
    EN        : out    STD_LOGIC
  );                  
END user_logic_LCD;

ARCHITECTURE behavorial OF user_logic_LCD IS
  TYPE LCD_FirstLine is array(0 to 3) of std_logic_vector(127 downto 0);
  signal first_line : LCD_FirstLine := (others => (others => '0'));
  TYPE LCD_SecondLine is array(0 to 3) of std_logic_vector(127 downto 0);
  signal second_line : LCD_SecondLine := (others => (others => '0'));
  signal LCD_addr     : std_logic_vector(15 downto 0);
  signal LCD_data     : std_logic_vector(31 downto 0);
  signal LCD_PWM_Freq : std_logic_vector(31 downto 0);
  TYPE state_type IS (start, enable, repeat);
  signal state      : state_type;
  signal data       : STD_LOGIC_VECTOR(8 DOWNTO 0);
  signal clk_cnt    : integer range 0 to cnt_max;
  signal clk_en     : STD_LOGIC;
  signal count       : unsigned(27 DOWNTO 0) := X"000000F";
  signal byteSel    : integer range 0 to 42 := 0;
  signal RS_sig     : std_logic;
  signal EN_sig     : std_logic;

BEGIN
  
  LCD_addr(15 downto  8) <= x"3" & addr_in(7 downto 4) 
  when addr_in(7 downto 4) < x"A" else
  x"41" when addr_in(7 downto 4) = x"A" else
  x"42" when addr_in(7 downto 4) = x"B" else  
  x"43" when addr_in(7 downto 4) = x"C" else  
  x"44" when addr_in(7 downto 4) = x"D" else  
  x"45" when addr_in(7 downto 4) = x"E" else
  x"46" when addr_in(7 downto 4) = x"F" else
 (others => '0');                                      
  LCD_addr(7  downto  0) <= x"3" & addr_in(3 downto 0) 
  when addr_in(3 downto 0) < x"A" else
  x"41" when addr_in(3 downto 0) = x"A" else
  x"42" when addr_in(3 downto 0) = x"B" else  
  x"43" when addr_in(3 downto 0) = x"C" else  
  x"44" when addr_in(3 downto 0) = x"D" else  
  x"45" when addr_in(3 downto 0) = x"E" else
  x"46" when addr_in(3 downto 0) = x"F" else
 (others => '0');  
 LCD_data(31 downto 24) <= x"3" & data_in(15 downto 12) 
 when data_in(15 downto 12) < x"A" else
 x"41" when data_in(15 downto 12) = x"A" else
 x"42" when data_in(15 downto 12) = x"B" else  
 x"43" when data_in(15 downto 12) = x"C" else  
 x"44" when data_in(15 downto 12) = x"D" else  
 x"45" when data_in(15 downto 12) = x"E" else
 x"46" when data_in(15 downto 12) = x"F" else
 (others => '0');  
LCD_data(23 downto 16) <= x"3" & data_in(11 downto 8) 
 when data_in(11 downto 8) < x"A" else
 x"41" when data_in(11 downto 8) = x"A" else
 x"42" when data_in(11 downto 8) = x"B" else  
 x"43" when data_in(11 downto 8) = x"C" else  
 x"44" when data_in(11 downto 8) = x"D" else  
 x"45" when data_in(11 downto 8) = x"E" else
 x"46" when data_in(11 downto 8) = x"F" else
 (others => '0');
LCD_data(15 downto  8) <= x"3" & data_in(7 downto 4) 
when data_in(7 downto 4) < x"A" else
x"41" when data_in(7 downto 4) = x"A" else
x"42" when data_in(7 downto 4) = x"B" else  
x"43" when data_in(7 downto 4) = x"C" else  
x"44" when data_in(7 downto 4) = x"D" else  
x"45" when data_in(7 downto 4) = x"E" else
x"46" when data_in(7 downto 4) = x"F" else  
(others => '0');
LCD_data(7  downto  0) <= x"3" & data_in(3 downto 0) 
when data_in(3 downto 0) < x"A" else
x"41" when data_in(3 downto 0) = x"A" else
x"42" when data_in(3 downto 0) = x"B" else  
x"43" when data_in(3 downto 0) = x"C" else  
x"44" when data_in(3 downto 0) = x"D" else  
x"45" when data_in(3 downto 0) = x"E" else
x"46" when data_in(3 downto 0) = x"F" else  
(others => '0');
LCD_PWM_Freq <= x"20203630" when selectPWM = "00" else -- --60
                x"20313230" when selectPWM = "01" else -- -120
                x"31303030" when selectPWM = "10" else -- 1000
                (others => '0');

first_line(0)  <= x"20" & x"49" & x"6E" & x"69" & x"74" & x"69" & x"61" & x"6C" & x"69" & x"7A" & x"69" & x"6E" & x"67" & x"2E" & x"20" & x"20";  -- Initalizing                                    
first_line(1)  <= x"20" & x"20" & x"20" & x"54" & x"65" & x"73" & x"74" & x"20" & x"4D" & x"6F" & x"64" & x"65" & x"20" & x"20" & x"20" & x"20";  -- Test Mode
first_line(2)  <= x"20" & x"20" & x"20" & x"50" & x"61" & x"75" & x"73" & x"65" & x"20" & x"4D" & x"6F" & x"64" & x"65" & x"20" & x"20" & x"20";  -- Pause Mode
first_line(3)  <= x"20" & x"20" & x"20" & x"20" & x"50" & x"57" & x"4D" & x"20" & x"4D" & x"6F" & x"64" & x"65" & x"20" & x"20" & x"20" & x"20";  -- PWM Mode

second_line(0) <= x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20" & x"20";
second_line(1) <= x"20" & x"20" & x"30" & x"78" & LCD_addr(15 downto 8) & LCD_addr(7 downto 0) & x"20" & x"20" &  x"30" & x"78" & LCD_data(31 downto 24) & LCD_data(23 downto 16) & LCD_data(15 downto 8) & LCD_data(7 downto 0) & x"20" & x"20";
second_line(2) <= x"20" & x"20" & x"30" & x"78" & LCD_addr(15 downto 8) & LCD_addr(7 downto 0) & x"20" & x"20" &  x"30" & x"78" & LCD_data(31 downto 24) & LCD_data(23 downto 16) & LCD_data(15 downto 8) & LCD_data(7 downto 0) & x"20" & x"20";
second_line(3) <= x"20" & x"20" & x"20" & x"20" & LCD_PWM_Freq & x"20" & x"20" & x"48" & x"7A" & x"20" & x"20" & x"20" & x"20";

process(byteSel)
 begin
    case byteSel is
       when 0  => data  <= '0'& X"38"; 
       when 1  => data  <= '0'& X"38";
       when 2  => data  <= '0'& X"38";
       when 3  => data  <= '0'& X"38";
       when 4  => data  <= '0'& X"38";
       when 5  => data  <= '0'& X"38";
       when 6  => data  <= '0'& X"01";
       when 7  => data  <= '0'& X"0C";
       when 8  => data  <= '0'& X"06";
       when 9  => data  <= '0'& X"80"; 
       when 10 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(127 downto 120);
       when 11 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(119 downto 112);
       when 12 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(111 downto 104);
       when 13 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(103 downto  96);
       when 14 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(95  downto  88);
       when 15 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(87  downto  80);
       when 16 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(79  downto  72);
       when 17 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(71  downto  64);
       when 18 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(63  downto  56);
       when 19 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(55  downto  48);
       when 20 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(47  downto  40);
       when 21 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(39  downto  32);
       when 22 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(31  downto  24);
       when 23 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(23  downto  16);
       when 24 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(15  downto   8);
       when 25 => data  <= '1'& first_line(to_integer(unsigned(selectMode)))(7   downto   0);
       when 26 => data  <= '0'& X"C0";--Change address to bottom left of screen--
       when 27 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(127 downto 120);
       when 28 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(119 downto 112);
       when 29 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(111 downto 104);
       when 30 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(103 downto  96);
       when 31 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(95  downto  88);
       when 32 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(87  downto  80);
       when 33 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(79  downto  72);
       when 34 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(71  downto  64);
       when 35 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(63  downto  56);
       when 36 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(55  downto  48);
       when 37 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(47  downto  40);
       when 38 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(39  downto  32);
       when 39 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(31  downto  24);
       when 40 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(23  downto  16);
       when 41 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(15  downto   8);
       when 42 => data  <= '1'& second_line(to_integer(unsigned(selectMode)))(7   downto   0);
       when others => data <= '0'& X"38";
   end case;
end process;


process(clk)
begin
if rising_edge(clk) then
if (clk_cnt = cnt_max) then
clk_cnt <= 0;
clk_en <= '1';
else
clk_cnt <= clk_cnt + 1;
clk_en <= '0';
end if;
end if;
end process;

process(clk_en,reset)
begin  
  if reset = '0' then
    EN_sig   <= '0';
    RS_sig   <= '0';
  elsif rising_edge(clk_en) then
    case state is
    when start =>
        EN_sig <= '0';
        RS_sig <= data(8);
        data_out <= data(7 downto 0);
        state <= enable;
   
    when enable =>
        EN_sig <= '1';
        state <= repeat;
    when repeat =>
        EN_sig <= '0';
        if byteSel < 42 then
            byteSel <= byteSel + 1;
        else
           byteSel <= 9;          
        end if;
        state <= start;
    end case;      
  end if;
end process;

end behavorial;  
