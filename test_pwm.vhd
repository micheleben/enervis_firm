----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:17:55 07/16/2012 
-- Design Name: 
-- Module Name:    test_pwm - Behavioral 
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

library ieee;
use ieee.std_logic_1164.all;

entity test_pwm is
   Generic (
		N : positive := 4095  --  max duty cycle length
		--S : positive := 124; -- start value
		--I : positive := 1 -- incremento
	);
	port 
	(
		clk		: in std_logic;
		rst		: in std_logic;
		sync_out : out std_logic;
		----------------------------
		cost_value_12bit : in std_logic_vector (11 downto 0);
		pwm_period_12bit : in std_logic_vector (11 downto 0);
		duty_increment_12bit : in std_logic_vector (11 downto 0);
		----------------------------
		pwm_out	: out std_logic
	);

end entity;

architecture Behavioral of test_pwm is

signal pwm_period : integer range 0 to N;
signal cost_value : integer range 0 to N;
signal duty_cycle : integer range 0 to N;
signal duty_increment : integer range 0 to N;

begin
process (clk)
	--variable to count the clock pulse
	variable count : integer range 0 to N;
	--variable to change duty cycle of the pulse
	variable var_duty_cycle : integer range 0 to N;
	variable var_duty_increment : integer range 0 to N;

	begin
	   if (clk'EVENT AND clk='1') then
			if (rst='1') THEN
				pwm_period <= conv_integer(unsigned(pwm_period_12bit));
				cost_value <= conv_integer(unsigned(cost_value_12bit));
				duty_cycle <= conv_integer(unsigned(cost_value_12bit));
				duty_increment <= conv_integer(unsigned(duty_increment_12bit));
				var_duty_cycle := cost_value;
				var_duty_increment := duty_increment;
				count:=0;
				sync_out <= '0';
				pwm_out <= '0';
			
			else
				 --increasing the count for each clock cycle	
				count:= count+1;
				
				if (count = duty_cycle) then
					pwm_out <= '0';
				end if;
				
				if (count = pwm_period) then
					pwm_out <= '1';
					count:= 0;
					-- increasing ramp
					var_duty_cycle:= var_duty_cycle + var_duty_increment;  --! need caution
					duty_cycle <= duty_cycle + duty_increment; --! need caution
					if (var_duty_cycle = pwm_period) then
						duty_cycle <= cost_value;
						var_duty_cycle := cost_value;
						sync_out <= '1';
					end if;	
				end if;	
				
			end if;
		end if;
	end process;

end Behavioral;