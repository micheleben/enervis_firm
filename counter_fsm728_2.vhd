----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:55:34 09/14/2012 
-- Design Name: 
-- Module Name:    counter_fsm728_2 - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter_fsm728_2 is
Generic (
		N : positive := 728  
	
	);

port
	(
		clk	: in std_logic;
		rst	: in std_logic;
		sync_out : out std_logic; -- limit_reached
		---------------------------
		event_to_count : in std_logic;
		rst_each_event : in std_logic;
		rst_event_generation : out std_logic;
		actual_value : out std_logic_vector(15 downto 0)
	);
end counter_fsm728_2;

architecture Behavioral of counter_fsm728_2 is
TYPE states IS  ( wait1 ,count_now, wait0 );
signal pr_state, nxt_state : states;
signal load: std_logic;

SIGNAL async_rst_event_generation: std_logic := '0';
SIGNAL sync_sync_out: std_logic := '0';
SIGNAL sync_rst_event_generation: std_logic := '0';
 
begin
with rst_each_event select
	rst_event_generation <=	sync_rst_event_generation	when '1',
									sync_sync_out					when others;

sync_out <= sync_sync_out;


process (clk)
variable count: integer range  0 to N;
	begin
	if (clk'EVENT and clk='1') then
		if (rst='1') then
			pr_state <= wait1;
			count := 0;
			sync_sync_out <= '0';
			sync_rst_event_generation <= '0';
		else
			if load = '1' then
				if count = 0 then
					sync_sync_out <= '0';
				end if;
				count := count +1;
				if count = N then
					count := 0;
					sync_sync_out <= '1';
				end if;		
			end if;
			actual_value <= std_logic_vector(to_unsigned(count, 16)); 
			sync_rst_event_generation <= async_rst_event_generation;
			pr_state <= nxt_state;
		end if;
	end if;
end process;

process (pr_state,event_to_count)
	begin
		
		case pr_state is
		when wait1 => 
			if event_to_count = '1' then
				nxt_state <= count_now;
			else 
				nxt_state <= wait1;
			end if;
			load <= '0';
			async_rst_event_generation <= '0';
				
		when count_now =>
			load <= '1';
			nxt_state <= wait0;
			async_rst_event_generation <= '1';
		
		when wait0 =>
			if event_to_count = '0' then
				nxt_state <= wait1;
			else 
				nxt_state <= wait0;
			end if;
			load <= '0';
			async_rst_event_generation <= '1';
		end case;
	
	end process;
end Behavioral;