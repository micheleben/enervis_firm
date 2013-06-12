----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:53:28 08/28/2012 
-- Design Name: 
-- Module Name:    test_pwm_down_cost_2 - Behavioral 
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

entity test_pwm_down_cost_2 is
Generic (
		N : positive := 255  
		--  duty cycle max length (2^8 = 256)
		-- 64 "01000000" -- 45 "00101101"
		-- 
	);
	port 
	(
		clk		: in std_logic;
		rst		: in std_logic;
		cost_value_8bit : in std_logic_vector (7 downto 0);
		pwm_period_8bit : in std_logic_vector (7 downto 0);	
		-------------------------
		pwm_out	: out std_logic
	);
end test_pwm_down_cost_2;


architecture Behavioral of test_pwm_down_cost_2 is

signal pwm_period : integer range 0 to N;
signal duty_cycle : integer range 0 to N;

begin
process (clk)
	--variable to count the clock pulse
	variable count : integer range 0 to N;
	
	begin
		if (clk'EVENT AND clk='1') then
			if (rst='1') THEN
				count:=0;
				pwm_out <= '0';
				pwm_period <= conv_integer(unsigned(pwm_period_8bit));
				duty_cycle <= conv_integer(unsigned(cost_value_8bit));
			else
				 --increasing the count for each clock cycle	
				count:= count-1;
				--setting output to logic 1 when count reach duty cycle value
				--output stays at logic 1 @ duty_cycle <= count <=50000
				if (count >= duty_cycle) then
					pwm_out <= '0';
				else
					pwm_out <= '1';
				end if;
				--setting output to logic 0 when count reach 50000
				--output stays at logic 0 @ 50000,0 <= count <= duty_cycle
				if (count = 0) then
					count:= pwm_period;
				end if;	
			end if;
		end if;
	end process;
end Behavioral;


