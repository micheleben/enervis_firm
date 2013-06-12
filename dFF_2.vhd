----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:08:09 08/29/2012 
-- Design Name: 
-- Module Name:    dFF_2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- This block simul the work of a flip flop 
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

entity dFF_2 is
    Port ( d : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  clk_sh : in std_logic;
           rst : in  STD_LOGIC;
           q : out  STD_LOGIC);
end dFF_2;

architecture Behavioral of dFF_2 is

begin

	process (clk)
	begin
		IF (clk'EVENT and clk='1') then
			if (rst='1') then
				q <= '0';
			elsif (clk_sh ='1') then
				q <= d;
			end if;
		end if;	
	end process;
end Behavioral;


