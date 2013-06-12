----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:37:57 08/28/2012 
-- Design Name: 
-- Module Name:    test_pwm_down_2 - Behavioral 
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

entity test_pwm_down_2 is
 Generic (
		N : positive := 255  --  duty cycle length	
	);
	port 
	(
		clk		: in std_logic;
		rst		: in std_logic;
		sync_out : out std_logic;
		----------------------------
		cost_value_8bit : in std_logic_vector (7 downto 0);
		pwm_period_8bit : in std_logic_vector (7 downto 0);
		duty_decrement_8bit : in std_logic_vector (7 downto 0);
		----------------------------
		pwm_out	: out std_logic
	);
end test_pwm_down_2;

architecture Behavioral of test_pwm_down_2 is

signal pwm_period : integer range 0 to N;
signal cost_value : integer range 0 to N;
signal duty_cycle : integer range 0 to N;
signal duty_decrement : integer range 0 to N;

begin

process (clk)

	--variable to count the clock pulse
	variable count : integer range 0 to N;
	variable var_duty_cycle : integer range 0 to N;
	variable var_duty_decrement : integer range 0 to N;
	variable flag : std_logic;
	
	begin
		if (clk'EVENT AND clk='1') then
			if (rst='1') THEN
				pwm_period <= conv_integer(unsigned(pwm_period_8bit));
				cost_value <= conv_integer(unsigned(cost_value_8bit));
				duty_cycle <= conv_integer(unsigned(cost_value_8bit));
				duty_decrement <= conv_integer(unsigned(duty_decrement_8bit));
				var_duty_cycle := cost_value;
				var_duty_decrement := duty_decrement;
				count:=0;
				flag :='1';
				sync_out <= '0';
				pwm_out <= '0';
			else
				--increasing the count for each clock cycle	
				count:= count+1;
				--setting output to logic 1 when count reach duty cycle value and the first time 
				if (flag = '1') then
					flag := '0';
					pwm_out <= '1';
				elsif (count = duty_cycle) then
					pwm_out <= '0';
				end if;
				--setting output to logic 0 when count reach 50000
				--output stays at logic 0 @ 50000,0 <= count <= duty_cycle
				if (count = pwm_period) then
					pwm_out <= '1';
					count:= 0;
					-- decreasing ramp
					var_duty_cycle := var_duty_cycle - var_duty_decrement; --! need caution
					duty_cycle <= duty_cycle - duty_decrement; --! need caution
					if (var_duty_cycle = 0) then
						duty_cycle <= cost_value;
						var_duty_cycle := cost_value;
						flag := '1';
						sync_out <= '1';
					end if;
				end if;		
			end if;	
			
		end if;
		
	end process;

end Behavioral;

