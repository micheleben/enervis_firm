----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:01:12 08/22/2012 
-- Design Name: 
-- Module Name:    test_serial_receiver_2 - Behavioral 
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

entity test_serial_receiver_4 is
Generic (
	N : positive := 16  --  serial word length 
	);
		  
port ( 
	din, clk, rst: IN std_logic;
	sync_out : OUT std_logic;
	clk_sh : OUT std_logic;
	data: OUT std_logic_VECTOR (N-1 DOWNTO 0)
	);
end test_serial_receiver_4;

architecture Behavioral of test_serial_receiver_4 is
begin
 PROCESS (clk)
	VARIABLE pos: INTEGER RANGE 0 TO N;
	VARIABLE rise_clk_sh: std_logic;
	VARIABLE watch_dog: std_logic;
	variable count: integer range 0 to 4;
	
	BEGIN
	IF (clk'EVENT AND clk='1') THEN
		IF (rst='1') THEN
			pos:= N;
			count:= 0;
			rise_clk_sh := '0';
			watch_dog :='0';
			sync_out <= '0';
			--data <= (data'RANGE => '0');
			clk_sh <= '0';
		ELSE
			count:= count +1;
			if (count = 4) then
				if (watch_dog ='0') then
					rise_clk_sh := not(rise_clk_sh);
					clk_sh <= rise_clk_sh;
					if (rise_clk_sh = '0') then
					-- first the MSB, last the LSB
						pos := pos-1;
						data(pos) <= din; 
					end if;
					if (pos = 0) then
						sync_out <= '1';
						watch_dog := '1';
					end if;
				end if;
				count:= 0;
			end if;
		END IF;
	END IF;
 END PROCESS;
end Behavioral;

