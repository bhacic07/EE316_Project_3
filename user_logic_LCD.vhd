library IEEE;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity i2c_user is
    Port (
    addr  : in std_LOGIC_VECTOR(6 downto 0);
 --state  : in std_lOGIC_VECTOR(1 downto 0);
    iData : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    sda   : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl   : INOUT  STD_LOGIC;                   --serial clock output of i2c bus
    clk   : in std_logic;
    reset  : in std_logic;
    data_output  : out std_LOGIC_VECTOR(7 downto 0)
          );
end i2c_user;

architecture Structural of i2c_user is
           
TYPE state_type IS(start, write_data, read_data); --needed states
signal state      : state_type;                   --state machine
signal reset_n    : STD_LOGIC;                    --active low reset
signal ena        : STD_LOGIC;                    --latch in data
signal data       : STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write
signal wdata : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal busy       : STD_LOGIC;                    --indicates transaction in
signal counter   : Integer := 16383; --delay time when a new data transaction occurs
signal byteSel    : integer range 0 to 12:= 0;

signal address    : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal rw : STD_LOGIC;
signal oldBusy    : STD_LOGIC;

signal data_read  : STD_LOGIC_VECTOR(7 downto 0);



COMPONENT i2c_master is
    GENERIC(
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
--data  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
           
           end component;

BEGIN

 

process(byteSel, iData)
 begin
    case byteSel is
       when 0  => data <= iData;
       when 1  => data <= iData;
--       when 2  => data <= X"76";      
--       when 3  => data <= X"7A";
--       when 4  => data <= X"FF";
--       when 5  => data <= X"77";
--       when 6  => data <= X"00";
--       when 7  => data <= X"79";
--       when 8  => data <= X"00";      
--       when 9  => data <= X"0"&iData(15 downto 12);
--       when 10 => data <= X"0"&iData(11 downto 8);
--       when 11 => data <= X"0"&iData(7  downto 4);
--       when 12 => data <= X"0"&iData(3  downto 0);
       when others => data <= X"76";
   end case;
end process;

     
Inst_i2c_master: i2c_master
GENERIC map(
input_clk => 50_000_000, bus_clk => 90_000 )
port map(
clk => clk,
    reset_n => reset_n,
    ena => ena,
    addr => addr,
    rw => rw,
    data_wr => data,
    busy => busy,
    data_rd => data_read,
    ack_error => open,
    sda => sda,
    scl => scl
);
 
       
process(clk)
begin  
if(clk'event and clk = '1') then
  case state is
 
when start =>
rw <= '0';
if counter /= 0 then
reset_n <= '0';
ena <= '0';
state <= start;
counter <= counter - 1;
else
reset_n <= '1';
ena <= '1';
state <= write_data;
end if;


when write_data =>
rw <= '0';
oldBusy <= busy;
wdata <= iData;
if busy = '0' and oldBusy /= busy then
if byteSel /= 1 then
byteSel <= byteSel + 1;
state <= write_data;
else
byteSel <= 0;
state <= read_data;
end if;
end if;


   when read_data =>
rw <= '1';
ena <= '1';
if wdata /= idata then
state <= start;
else
state <= read_data;
data_output <= data_read;
end if;

when others => null;
 
end case;
 
end if;  
  end process;                
           end Structural;