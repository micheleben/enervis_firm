----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:37:41 10/03/2012 
-- Design Name: 
-- Module Name:    test_wait_16bit - Behavioral 
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

entity test_wait_16bit is
Generic (
		N : positive := 32767  --  2^16= 32768 
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
		start_value_16bit : in std_logic_vector (15 downto 0);
		stop_value_16bit : in std_logic_vector (15 downto 0);
		sync_out : out std_logic
	);
end test_wait_16bit;

architecture Behavioral of test_wait_16bit is
signal start_value : integer range 0 to N;
signal stop_value : integer range 0 to N;
signal watch : std_logic := '0';
begin
process (clk)
	--variable to count the clock pulse
	variable count : integer range 0 to N;
	begin
	if (clk'EVENT AND clk='1') then
		if (rst='1') THEN
			count:=0;
			sync_out <= '0';
			watch <= '0';
			start_value<= conv_integer(unsigned(start_value_16bit));
			stop_value<= conv_integer(unsigned(stop_value_16bit));			
		else
		    --increasing the count for each clock cycle	
			if (watch = '0') then
				count:= count+1;
				if (count = start_value) then
					sync_out <= '1';
				elsif (count = stop_value) then
					sync_out <= '0';
					count:=0;
					watch <= '1';
				end if;
			end if;	
		end if;
	end if;		
	end process;


end Behavioral;

