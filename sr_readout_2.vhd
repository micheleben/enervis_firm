----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:23:12 09/13/2012 
-- Design Name: 
-- Module Name:    sr_readout_2 - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;
use work.enervis_package_S6.all;

entity sr_readout_2 is
	Generic (
	N : positive := 16  --  serial word length 
	);
	port(din, clk, rst,s8b : IN std_logic;
	sync_out : OUT std_logic;
	sync_out_sr : OUT std_logic;
	clk_sh : OUT std_logic;
	number_of_sr_readout_of_line:  OUT std_logic_VECTOR (15 DOWNTO 0);
	data: OUT std_logic_VECTOR (N-1 DOWNTO 0)
	);
end sr_readout_2;

architecture Behavioral of sr_readout_2 is
signal gSYNC_SR: std_logic;
signal gRST_ROW_END: std_logic;
signal gRST_SR_CONTROLLER: std_logic;
signal sync_out_52: std_logic;
signal rst_row_end52: std_logic;
signal actual_value_52: std_logic_vector(15 DOWNTO 0):= "0000000000000000";
signal sync_out_7: std_logic;
signal actual_value_7: std_logic_vector(15 DOWNTO 0):= "0000000000000000";
signal rst_row_end7: std_logic;
signal rst_7: std_logic;
signal rst_7_s8b: std_logic;
signal rst_52: std_logic;
signal rst_52_s8b: std_logic;
begin

sync_out_sr <= gSYNC_SR;
with s8b select
	rst_7_s8b <= 	'1' when '1', -- 16 x 52 corresponds to 8 * row end 104 
						'0' when '0', -- 16 x  7  corresponds to 112 (8 more than 104 )
						'1' when others;
rst_7 <= rst_7_s8b or rst;
						
with s8b select
	rst_52_s8b <= 	'0' when '1', -- 16 x 52 corresponds to 8 * row end 104 
						'1' when '0', -- 16 x  7  corresponds to 112 (8 more than 104 )
						'1' when others;
rst_52 <= rst or rst_52_s8b;  

with s8b select
	sync_out <= 	sync_out_52 when '1', -- 16 x 52 corresponds to 8 * row end 104 
						sync_out_7 when '0', -- 16 x  7  corresponds to 112 (8 more than 104 )
						sync_out_7 when others;

with s8b select
	gRST_ROW_END <= 	rst_row_end52 when '1', 
							rst_row_end7 when '0',
							rst_row_end7 when others;


with s8b select
	number_of_sr_readout_of_line	<= actual_value_52	when '1',
											actual_value_7			when '0',
											actual_value_7			when others;

gRST_SR_CONTROLLER <= gRST_ROW_END or rst;
------------------------------------------------------
SR_controller: test_serial_receiver_4
--SR_controller: test_serial_receiver_3 
	PORT MAP (din=>din, 
				clk=>clk,
				rst=>gRST_SR_CONTROLLER,
				sync_out=>gSYNC_SR,
				clk_sh=> clk_sh,
				data=>data );
------------------------------------------------------				
count_SR_controller52 : counter_fsm52_2
PORT MAP (clk=>clk,
		rst=>rst_52,
		sync_out => sync_out_52, -- (row end)
		---------------------------
		event_to_count =>gSYNC_SR,
		rst_each_event => '1',
		rst_event_generation => rst_row_end52,
		actual_value =>  actual_value_52
);
------------------------------------------------------				
count_SR_controller7 : counter_fsm7_2
PORT MAP (clk=>clk,
		rst=>rst_7,
		sync_out => sync_out_7, -- (row end)
		---------------------------
		event_to_count =>gSYNC_SR,
		rst_each_event => '1',
		rst_event_generation => rst_row_end7,
		actual_value =>  actual_value_7
);


end Behavioral;