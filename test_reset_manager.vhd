----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:41:23 07/20/2012 
-- Design Name: 
-- Module Name:    test_reset_manager - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_reset_manager is
    Port ( clk: in STD_LOGIC;
			  global_reset : in  STD_LOGIC;
           EOF_reset : in  STD_LOGIC;
           rst_fsm : out  STD_LOGIC;
           rst_line_counter : out  STD_LOGIC;
           rst_memory_manager : out  STD_LOGIC);
end test_reset_manager;

architecture Behavioral of test_reset_manager is

begin

process (global_reset,clk)
begin
		if (global_reset='1') THEN
			rst_fsm <= '1';
			rst_line_counter <= '1';
			rst_memory_manager <= '1';
		elsif (clk'EVENT AND clk='1') then
			rst_memory_manager <= '0';
			if (EOF_reset = '1') then
				rst_fsm <='1';
				rst_line_counter <= '1';
			else
				rst_fsm <='0';
				rst_line_counter <= '0';
			end if;
		end if;
end process;

end Behavioral;

