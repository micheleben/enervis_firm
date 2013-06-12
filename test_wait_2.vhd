----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:16:37 08/28/2012 
-- Design Name: 
-- Module Name:    test_wait_2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_wait_2 is
Generic (
		N : positive := 4095  --  2^12= 4096 
		-- 250 clock cicle @ 50 MHz = 5us	"000011111010"
		-- 500 clock cicle @ 50 MHz = 10us	000111110100
		-- 1000 clock cicle @ 50 MHz = 20us	001111101000
		-- 1250 clock cicle @ 50 MHz = 25us 010011100010
		-- 1500 clock cicle @ 50 MHz = 30us 010111011100
		);
port 
	(
		clk		: in std_logic;
		rst		: in std_logic;
		wait_value_12bit : in std_logic_vector (11 downto 0);
		sync_out : out std_logic
	);
end test_wait_2;

architecture Behavioral of test_wait_2 is
signal wait_period : integer range 0 to N;

begin
process (clk)
	--variable to count the clock pulse
	variable count : integer range 0 to N;
	begin
	if (clk'EVENT AND clk='1') then
		if (rst='1') THEN
			count:=0;
			sync_out <= '0';
			wait_period <= conv_integer(unsigned(wait_value_12bit));  
		else
		    --increasing the count for each clock cycle	
			count:= count+1;
			if (count = wait_period) then
				sync_out <= '1';
				count:=0;
			end if;
		end if;
	end if;		
	end process;
end Behavioral;
