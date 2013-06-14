----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:57:41 07/20/2012 
-- Design Name: 
-- Module Name:    test_memory_controller - Behavioral 
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
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;
use work.enervis_package_S6.all;
entity test_memory_controller_2 is
	
	port(
		clk: in std_logic;
		rst: in std_logic;
		--------------------
		number_of_sr_readout_of_line: in std_logic_vector (15 downto 0);
		number_of_line_read: in std_logic_vector (15 downto 0);
		--------------------
		sync_end_of_SR: in std_logic;
		sync_end_of_line: in std_logic;
		sync_end_of_frame: in std_logic;
		--------------------
		data: in std_logic_vector (15 downto 0);
		s8b : in std_logic;
		
		clk_read_ram: in std_logic;
		
		pipeO_data: out std_logic_vector (15 downto 0);
		pipeO_data_1: out std_logic_vector (15 downto 0);
		pipeO_data_2: out std_logic_vector (15 downto 0);
		pipeO_data_3: out std_logic_vector (15 downto 0);
		pipeO_data_4: out std_logic_vector (15 downto 0);
		pipeO_data_5: out std_logic_vector (15 downto 0);
		pipeO_data_6: out std_logic_vector (15 downto 0);
		
		pipeO_count: in std_logic_vector (31 downto 0);
		
		actual_ram_address: out std_logic_vector (15 downto 0);
		actual_ram_block: out std_logic_vector (15 downto 0);
		
		select_ram_block_to_read:  in std_logic_vector (15 downto 0);
		data_to_write: out std_logic_vector (15 downto 0)
		
	);
end test_memory_controller_2;

architecture Behavioral of test_memory_controller_2 is

-- fsm frame:
type frame is (frame1RE,frame1FE,frame2RE,frame2FE);
signal present_frame, next_frame: frame;

signal register_frame1 : std_logic;
signal register_frame2 : std_logic;

-- fsm ram:
type ram_block is (ram1RE,ram2RE,ram3RE,ram4RE,ram5RE,ram6RE,ram1FE,ram2FE,ram3FE,ram4FE,ram5FE,ram6FE);
signal present_ram_block, next_ram_block: ram_block;
signal change_ram_block: std_logic;

signal limit_to_reach: std_logic_vector (1 downto 0); -- 00 = 1024
																		--	01 = 728					
																		-- 10 = 288	
signal change_ram_block1024: std_logic;
signal change_ram_block728: std_logic;
signal change_ram_block288: std_logic;	

signal ramI_address: std_logic_vector (9 downto 0);
signal ram6I_address: std_logic_vector (9 downto 0);																	

signal ramI_address1024: std_logic_vector (15 downto 0);
signal ramI_address728: std_logic_vector (15 downto 0);
signal ramI_address288: std_logic_vector (15 downto 0);

signal rst_count_ram_address1024: std_logic; 
signal rst_count_ram_address728: std_logic; 
signal rst_count_ram_address288: std_logic; 

signal rst_count_ram_address1024_limit: std_logic; 
signal rst_count_ram_address728_limit: std_logic; 
signal rst_count_ram_address288_limit: std_logic; 
																		
signal register_ram1 : std_logic;
signal register_ram2 : std_logic;
signal register_ram3 : std_logic;
signal register_ram4 : std_logic;
signal register_ram5 : std_logic;
signal register_ram6 : std_logic;

constant ram_dimension : integer := 1024;
constant last_block_last_address : integer := 288;
signal max_address : integer range 0 to ram_dimension;


-- write syncronization:
signal enable_ram1_frame1 : std_logic;
signal enable_ram1_frame2 : std_logic;

signal enable_ram2_frame1 : std_logic;
signal enable_ram2_frame2 : std_logic;

signal enable_ram3_frame1 : std_logic;
signal enable_ram3_frame2 : std_logic;

signal enable_ram4_frame1 : std_logic;
signal enable_ram4_frame2 : std_logic;

signal enable_ram5_frame1 : std_logic;
signal enable_ram5_frame2 : std_logic;

signal enable_ram6_frame1 : std_logic;
signal enable_ram6_frame2 : std_logic;
signal enable_ram6 : std_logic;

signal clk_write_ram : std_logic;

signal data_sync: std_logic_vector (15 downto 0);

-- read selection:
--two different data output depending on the value of s8b
signal pipeO_data_s8b_0 : std_logic_vector (15 downto 0);
signal pipeO_data_s8b_1 : std_logic_vector (15 downto 0);
--connect the data output of the proper ram block
signal pipeO_data_ram1_frame1 : std_logic_vector (15 downto 0);
signal pipeO_data_ram2_frame1 : std_logic_vector (15 downto 0);
signal pipeO_data_ram3_frame1 : std_logic_vector (15 downto 0);
signal pipeO_data_ram4_frame1 : std_logic_vector (15 downto 0);
signal pipeO_data_ram5_frame1 : std_logic_vector (15 downto 0);
--signal pipeO_data_ram6_frame1 : std_logic_vector (15 downto 0);

signal pipeO_data_ram1_frame2 : std_logic_vector (15 downto 0);
signal pipeO_data_ram2_frame2 : std_logic_vector (15 downto 0);
signal pipeO_data_ram3_frame2 : std_logic_vector (15 downto 0);
signal pipeO_data_ram4_frame2 : std_logic_vector (15 downto 0);
signal pipeO_data_ram5_frame2 : std_logic_vector (15 downto 0);
--signal pipeO_data_ram6_frame2 : std_logic_vector (15 downto 0);
signal pipeO_data_ram6 : std_logic_vector (15 downto 0);
 
begin
-----------------------------------------------------------------------
-------- FSM to control the frame where we want to write  -------------
-----------------------------------------------------------------------	
	process (clk)
	--variable to count the clock pulse
	begin
		if (clk'EVENT AND clk='1') then
			if (rst='1') THEN
				present_frame <= frame1RE;
			else
				present_frame <= next_frame;
			end if;
		end if;	
	end process;
	
	process(present_frame,sync_end_of_frame)
	begin
		case present_frame is
			when frame1RE =>
				register_frame1 <='1';
				register_frame2 <='0';
				if sync_end_of_frame ='0' then
					next_frame <= frame1FE;
				else
					next_frame <= frame1RE;
				end if;
			when frame1FE =>
				register_frame1 <='1';
				register_frame2 <='0';
				if sync_end_of_frame ='1' then
					next_frame <= frame2RE;
				else
					next_frame <= frame1FE;
				end if;			
			when frame2RE =>
				register_frame1 <='0';
				register_frame2 <='1';
				if sync_end_of_frame ='0' then
					next_frame <= frame2FE;
				else
					next_frame <= frame2RE;
				end if;	
			when frame2FE =>
				register_frame1 <='0';
				register_frame2 <='1';
				if sync_end_of_frame ='1' then
					next_frame <= frame1RE;
				else
					next_frame <= frame2FE;
				end if;
		end case;
	end process;

-------------------------------------------------------------------------------
-- FSM to control the ram block (and the ram address) where we want to write --
-------------------------------------------------------------------------------	
	count_ram_address1024 : counter_fsm1024_2
	PORT MAP (clk=>clk,
		rst=>rst_count_ram_address1024,
		sync_out => change_ram_block1024, -- (ram 1024 end)
		---------------------------
		event_to_count =>sync_end_of_SR,
		rst_each_event => '0',
		actual_value =>  ramI_address1024
	);
	
	count_ram_address728 : counter_fsm728_2
	PORT MAP (clk=>clk,
		rst=>rst_count_ram_address728,
		sync_out => change_ram_block728, -- (ram 728 end)
		---------------------------
		event_to_count =>sync_end_of_SR,
		rst_each_event => '0',
		actual_value =>  ramI_address728
	);
	
	count_ram_address288 : counter_fsm288_2
	PORT MAP (clk=>clk,
		rst=>rst_count_ram_address288,
		sync_out => change_ram_block288, -- (ram 728 end)
		---------------------------
		event_to_count =>sync_end_of_SR,
		rst_each_event => '0',
		actual_value =>  ramI_address288
	);

-- 00 = 1024
--	01 = 728					
-- 10 = 288
-- 


with limit_to_reach select
	change_ram_block <= 	change_ram_block1024 when "00",
								change_ram_block728 when "01",
								change_ram_block288 when "10",
								change_ram_block1024 when others;
	
with limit_to_reach select
	ramI_address <=	ramI_address1024(9 downto 0) when "00",
							ramI_address728(9 downto 0) when "01",
							ramI_address288(9 downto 0) when "10",
							ramI_address1024(9 downto 0) when others;
							
rst_count_ram_address1024 <= rst_count_ram_address1024_limit or rst;
rst_count_ram_address728 <= rst_count_ram_address728_limit or rst;
rst_count_ram_address288 <= rst_count_ram_address288_limit or rst;

with limit_to_reach select
	rst_count_ram_address1024_limit <=	'0' when "00",
											'1' when others;

with limit_to_reach select
	rst_count_ram_address728_limit <=	'0' when "01",
											'1' when others;

with limit_to_reach select
	rst_count_ram_address288_limit <=	'0' when "10",
											'1' when others;

	
	process (clk)
	begin
		if (clk'EVENT AND clk='1') then
			if (rst='1') THEN
				present_ram_block <= ram1RE;
			else
				present_ram_block <= next_ram_block;
			end if;	
		end if;			
	end process;
	
	process (present_ram_block, change_ram_block, s8b)
	begin
		case present_ram_block is
			when ram1RE =>
				if s8b = '1' then
					limit_to_reach <= "00";
				else
					limit_to_reach <= "01";
				end if;
				register_ram1 <='1';
				register_ram2 <='0';
				register_ram3 <='0';
				register_ram4 <='0';
				register_ram5 <='0';
				register_ram6 <='0';
				if change_ram_block = '0' then
					next_ram_block <= ram1FE;
				else
					next_ram_block <= ram1RE;
				end if;
			when ram1FE =>
				if s8b = '1' then
					limit_to_reach <= "00";
				else
					limit_to_reach <= "10";
				end if;
				register_ram1 <='1';
				register_ram2 <='0';
				register_ram3 <='0';
				register_ram4 <='0';
				register_ram5 <='0';
				register_ram6 <='0';
				if change_ram_block = '1' then
					next_ram_block <= ram2RE;
				else
					next_ram_block <= ram1FE;
				end if;
			when ram2RE =>
				limit_to_reach <= "00";
				register_ram1 <='0';
				register_ram2 <='1';
				register_ram3 <='0';
				register_ram4 <='0';
				register_ram5 <='0';
				register_ram6 <='0';
				if change_ram_block = '0' then
					next_ram_block <= ram2FE;
				else
					next_ram_block <= ram2RE;
				end if;
			when ram2FE =>
				limit_to_reach <= "00";
				register_ram1 <='0';
				register_ram2 <='1';
				register_ram3 <='0';
				register_ram4 <='0';
				register_ram5 <='0';
				register_ram6 <='0';
				if change_ram_block = '1' then
					next_ram_block <= ram3RE;
				else
					next_ram_block <= ram2FE;
				end if;
			when ram3RE =>
				limit_to_reach <= "00";
				register_ram1 <='0';
				register_ram2 <='0';
				register_ram3 <='1';
				register_ram4 <='0';
				register_ram5 <='0';
				register_ram6 <='0';
				if change_ram_block = '0' then
					next_ram_block <= ram3FE;
				else
					next_ram_block <= ram3RE;
				end if;
			when ram3FE =>
				limit_to_reach <= "00";
				register_ram1 <='0';
				register_ram2 <='0';
				register_ram3 <='1';
				register_ram4 <='0';
				register_ram5 <='0';
				register_ram6 <='0';
				if change_ram_block = '1' then
					next_ram_block <= ram4RE;
				else
					next_ram_block <= ram3FE;
				end if;
			when ram4RE =>
				limit_to_reach <= "00";
				register_ram1 <='0';
				register_ram2 <='0';
				register_ram3 <='0';
				register_ram4 <='1';
				register_ram5 <='0';
				register_ram6 <='0';
				if change_ram_block = '0' then
					next_ram_block <= ram4FE;
				else
					next_ram_block <= ram4RE;
				end if;
			when ram4FE =>
				limit_to_reach <= "00";
				register_ram1 <='0';
				register_ram2 <='0';
				register_ram3 <='0';
				register_ram4 <='1';
				register_ram5 <='0';
				register_ram6 <='0';
				if change_ram_block = '1' then
					next_ram_block <= ram5RE;
				else
					next_ram_block <= ram4FE;
				end if;
			when ram5RE =>
				limit_to_reach <= "00";
				register_ram1 <='0';
				register_ram2 <='0';
				register_ram3 <='0';
				register_ram4 <='0';
				register_ram5 <='1';
				register_ram6 <='0';
				if change_ram_block = '0' then
					next_ram_block <= ram5FE;
				else
					next_ram_block <= ram5RE;
				end if;
			when ram5FE =>
				limit_to_reach <= "00";
				register_ram1 <='0';
				register_ram2 <='0';
				register_ram3 <='0';
				register_ram4 <='0';
				register_ram5 <='1';
				register_ram6 <='0';
				if change_ram_block = '1' then
					next_ram_block <= ram6RE;
				else
					next_ram_block <= ram5FE;
				end if;
			when ram6RE =>
				limit_to_reach <= "10";
				register_ram1 <='0';
				register_ram2 <='0';
				register_ram3 <='0';
				register_ram4 <='0';
				register_ram5 <='0';
				register_ram6 <='1';
				if change_ram_block = '0' then
					next_ram_block <= ram6FE;
				else
					next_ram_block <= ram6RE;
				end if;
			when ram6FE =>
				limit_to_reach <= "10";
				register_ram1 <='0';
				register_ram2 <='0';
				register_ram3 <='0';
				register_ram4 <='0';
				register_ram5 <='0';
				register_ram6 <='1';
				if change_ram_block = '1' then
					next_ram_block <= ram1RE;
				else
					next_ram_block <= ram6FE;
				end if;			
		end case;
	end process;
	
					
				
				
-----------------------------------------------------------------------	
----------------------- SYNCRONIZATION --------------------------------
-----------------------------------------------------------------------
	process (clk)
	variable one_pulse : integer range 0 to 1 := 0;
	begin
		if (clk'EVENT AND clk='1') then
			if (rst='1') THEN
				enable_ram1_frame1 <= '0';
				enable_ram2_frame1 <= '0';
				enable_ram3_frame1 <= '0';
				enable_ram4_frame1 <= '0';
				enable_ram5_frame1 <= '0';
				enable_ram6_frame1 <= '0';
				enable_ram1_frame2 <= '0';
				enable_ram2_frame2 <= '0';
				enable_ram3_frame2 <= '0';
				enable_ram4_frame2 <= '0';
				enable_ram5_frame2 <= '0';
				enable_ram6_frame2 <= '0';
				data_sync <= "0000000000000000";
				clk_write_ram <= '0';
			else
				enable_ram1_frame1 <= register_frame1 and register_ram1;
				enable_ram2_frame1 <= register_frame1 and register_ram2;
				enable_ram3_frame1 <= register_frame1 and register_ram3;
				enable_ram4_frame1 <= register_frame1 and register_ram4;
				enable_ram5_frame1 <= register_frame1 and register_ram5;
				enable_ram6_frame1 <= register_frame1 and register_ram6;
				
				enable_ram1_frame2 <= register_frame2 and register_ram1;
				enable_ram2_frame2 <= register_frame2 and register_ram2;
				enable_ram3_frame2 <= register_frame2 and register_ram3;
				enable_ram4_frame2 <= register_frame2 and register_ram4;
				enable_ram5_frame2 <= register_frame2 and register_ram5;
				enable_ram6_frame2 <= register_frame2 and register_ram6;
				--- generate a clock pulse and write the ram ---
				if (sync_end_of_SR = '1') then
					data_sync <= data;
					if one_pulse = 0 then
						clk_write_ram <= '1';
						one_pulse := 1;
					else
						clk_write_ram <= '0';
					end if;		
				else
					one_pulse := 0;
					clk_write_ram <= '0';
				end if;
			end if;
		end if;			
	end process;
	
------------------------------------------------------------
-- output information on write procedure -------------------
actual_ram_address(15 downto 10) <= "000000";
actual_ram_address(9 downto 0) <= ramI_address; 
actual_ram_block(0) <= enable_ram1_frame1;
actual_ram_block(1) <= enable_ram2_frame1;
actual_ram_block(2) <= enable_ram3_frame1;
actual_ram_block(3) <= enable_ram4_frame1;
actual_ram_block(4) <= enable_ram5_frame1;
actual_ram_block(5) <= enable_ram6_frame1;
actual_ram_block(6) <= enable_ram1_frame2;
actual_ram_block(7) <= enable_ram2_frame2;
actual_ram_block(8) <= enable_ram3_frame2;
actual_ram_block(9) <= enable_ram4_frame2;
actual_ram_block(10) <= enable_ram5_frame2;
actual_ram_block(11) <= enable_ram6_frame2;
actual_ram_block(12) <= '0';
actual_ram_block(13) <= '0';
actual_ram_block(14) <= '0';
actual_ram_block(15) <= '0';

data_to_write <= data_sync;	
------------------------------------------------------
-- read selection ------------------------------------
------------------------------------------------------
with s8b select
	pipeO_data <= 	pipeO_data_s8b_0 when '0',
						pipeO_data_s8b_1 when '1',
						"1010101010101010" when others; -- this is useful only for debug	
---case s8b = '0': pipe the non selected ram block -------------
with enable_ram1_frame1 select -- this can be done also with enable_ram1_frame2
	pipeO_data_s8b_0 <= pipeO_data_ram1_frame1 when '0', -- we are writing on the ram1_frame2 (enable_ram1_frame1 ='1')
						pipeO_data_ram1_frame2 when '1',	
						"0101010101010101" when others; -- this is useful only for debug
---case s8b = '1': one pipe multiplexed  on the 12 block -------------
with select_ram_block_to_read select
	pipeO_data_s8b_1 <= 	pipeO_data_ram1_frame1 when "0000000000000001",
							pipeO_data_ram2_frame1 when "0000000000000010",
							pipeO_data_ram3_frame1 when "0000000000000100",
							pipeO_data_ram4_frame1 when "0000000000001000",
							pipeO_data_ram5_frame1 when "0000000000010000",
							--pipeO_data_ram6_frame1 when "0000000000100000",
							pipeO_data_ram1_frame2 when "0000000001000000",
							pipeO_data_ram2_frame2 when "0000000010000000",
							pipeO_data_ram3_frame2 when "0000000100000000",
							pipeO_data_ram4_frame2 when "0000001000000000",
							pipeO_data_ram5_frame2 when "0000010000000000",
							--pipeO_data_ram6_frame2 when "0000100000000000",
							pipeO_data_ram6 when others; 
--- six pipes multiplexed on the 12 blocks ----------------						
--with select_ram_block_to_read select
--	pipeO_data_1 <= 	pipeO_data_ram1_frame1 when "0100000000000000",
--							pipeO_data_ram1_frame2 when "1000000000000000",
--							"0000000000000000" when others;
--with select_ram_block_to_read select
--	pipeO_data_2 <= 	pipeO_data_ram2_frame1 when "0100000000000000",
--							pipeO_data_ram2_frame2 when "1000000000000000",
--							"0000000000000000" when others;
--with select_ram_block_to_read select
--	pipeO_data_3 <= 	pipeO_data_ram3_frame1 when "0100000000000000",
--							pipeO_data_ram3_frame2 when "1000000000000000",
--							"0000000000000000" when others;
--with select_ram_block_to_read select
--	pipeO_data_4 <= 	pipeO_data_ram4_frame1 when "0100000000000000",
--							pipeO_data_ram4_frame2 when "1000000000000000",
--							"0000000000000000" when others;
--with select_ram_block_to_read select
--	pipeO_data_5 <= 	pipeO_data_ram5_frame1 when "0100000000000000",
--							pipeO_data_ram5_frame2 when "1000000000000000",
--							"0000000000000000" when others;
--with select_ram_block_to_read select
--	pipeO_data_6 <= 	pipeO_data_ram6_frame1 when "0100000000000000",
--							pipeO_data_ram6_frame2 when "1000000000000000",
--							"0000000000000000" when others;	

------------------------------------------------------
ram1_frame1 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram1_frame1,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram1_frame1 
	);

ram2_frame1 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram2_frame1,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram2_frame1 
	);	

ram3_frame1 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram3_frame1,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram3_frame1 
	);	

ram4_frame1 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram4_frame1,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram4_frame1 
	);

ram5_frame1 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram5_frame1,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram5_frame1 
	);
-- <14062013 work around ram 6
--ram6_frame1 : RAMB16_S18_S18 port map (
--		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram6_frame1,
--		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
--		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
--		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
--		DOB => pipeO_data_ram6_frame1 
--	);	
-- 14062013 work around ram 6>
ram1_frame2 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram1_frame2,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram1_frame2 
	);	
	
ram2_frame2 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram2_frame2,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram2_frame2 
	);
	
ram3_frame2 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram3_frame2,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram3_frame2 
	);	

ram4_frame2 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram4_frame2,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram4_frame2 
	);	

ram5_frame2 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram5_frame2,
		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram5_frame2 
	);	

-- <14062013 work around ram 6 
--ram6_frame2 : RAMB16_S18_S18 port map (
--		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram6_frame2,
--		ADDRA => ramI_address ,DIA => data_sync, DIPA => "00",
--		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
--		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
--		DOB => pipeO_data_ram6_frame2 
--	);	


enable_ram6 <= enable_ram6_frame1 or enable_ram6_frame2;
ram6I_address <= enable_ram6_frame2 & ramI_address(8 downto 0);

ram6 : RAMB16_S18_S18 port map (
		CLKA => clk_write_ram, SSRA => '0', ENA => '1', WEA => enable_ram6,
		ADDRA => ram6I_address ,DIA => data_sync, DIPA => "00",
		CLKB => clk_read_ram, SSRB => '0', ENB => '1', WEB => '0',
		ADDRB => pipeO_count (9 downto 0) ,DIB => x"0000", DIPB => "00",
		DOB => pipeO_data_ram6 
	);
-- 14062013 work around ram 6>	
end Behavioral;

