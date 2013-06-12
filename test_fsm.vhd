----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:19:49 07/17/2012 
-- Design Name: 
-- Module Name:    test_fsm - Behavioral 
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

entity test_fsm is
	PORT (
			clk: in std_logic;
			rst: in std_logic;
			------------------------- conf -------
			general_conf: in std_logic_vector(15 downto 0);
			-------------------------sync out-----
			rst_SR: out std_logic;
			rst_PREPARE_INTEGRATION: out std_logic;
			rst_PWM_UP: out std_logic;
			rst_AFTER_INTEGRATION: out std_logic;
			rst_PREPARE_READOUT: out std_logic;
			rst_RESET_RN: out std_logic;
			rst_PWM_DOWN: out std_logic;
			rst_GENERATE_CLKADC_RESNBL: out std_logic;
			rst_FINISH_READOUT: out std_logic;
			rst_UPDATE_ROW: out std_logic;
			rst_NEXT_ROW_EOF: out std_logic;
			rst_PWM_COST: out std_logic;
			rst_PWM_DOWN_COST: out std_logic;
			-------------------------sync in-----
			end_SR: in std_logic;
			end_PREPARE_INTEGRATION: in std_logic;
			end_PWM_UP: in std_logic;
			end_AFTER_INTEGRATION: in std_logic;
			end_PREPARE_READOUT: in std_logic;
			end_RESET_RN: in std_logic;
			end_PWM_DOWN: in std_logic;
			end_FINISH_READOUT: in std_logic;
			end_UPDATE_ROW: in std_logic;
			end_NEXT_ROW_EOF: in std_logic;
			--end_EOF: in std_logic;
			------------------------------
			--- phases
			RES: out std_logic;
			VRES: out std_logic;
			RAMP_DIG : out std_logic;
			NEXT_ROW: out std_logic;
			RNDEC: out std_logic;
			UPDATE: out std_logic;
			RN: out std_logic;
			RC: out std_logic;
			EOF: out std_logic;
			--- control signals
			MASK: out std_logic;
			S8B: out std_logic;
			S0: out std_logic;
			S1: out std_logic;
			DATA_DOWNLOADING: out std_logic;
			MAXMIN: out std_logic;
			CNT: out std_logic
			);
end test_fsm;

architecture Behavioral of test_fsm is
	----------------------------------------
	--- Main FSM ---------------------------
	----------------------------------------
	type state is (reset, prepare_integration, integration, after_integration,
						prepare_readout, reset_RN, ramp_row, finish_readout, update_row,
						read_out_row, next_row_eof,general_conf_state);
	signal pr_state, nx_state: state;
	-----------------------------------------
	signal async_rst_SR: std_logic ;
	signal async_rst_PREPARE_INTEGRATION: std_logic ;
	signal async_rst_PWM_UP: std_logic ;
	signal async_rst_AFTER_INTEGRATION: std_logic ;
	signal async_rst_PREPARE_READOUT: std_logic ;
	signal async_rst_RESET_RN : std_logic ;
	signal async_rst_PWM_DOWN: std_logic ;
	signal async_rst_GENERATE_CLKADC_RESNBL: std_logic ;
	signal async_rst_FINISH_READOUT: std_logic ;
	signal async_rst_UPDATE_ROW: std_logic ;
	signal async_rst_NEXT_ROW_EOF: std_logic ;
	signal async_rst_PWM_COST: std_logic ;
	signal async_rst_PWM_DOWN_COST: std_logic ;
	--------------------------------
	signal mux_the_input :std_logic := '0'; 
	--- control signals that needed to be muxed 
	signal mux_S8B :std_logic; 
	signal mux_MASK :std_logic;
	signal mux_S0 :std_logic;
	signal mux_S1 :std_logic;
	signal mux_CNT :std_logic;
	signal mux_DATA_DOWNLOADING :std_logic;
	signal mux_MAXMIN_in :std_logic;
	signal mux_MAXMIN_auto_in :std_logic;
	signal mux_UPDATE_fix_in :std_logic;
	--- sync version of muxed control signals
	signal sync_mux_S8B :std_logic := '1'; 
	signal sync_mux_MASK :std_logic := '0';
	signal sync_mux_S0 :std_logic := '1';
	signal sync_mux_S1 :std_logic := '1';
	signal sync_mux_CNT :std_logic := '1';
	signal sync_mux_DATA_DOWNLOADING :std_logic := '0';
	signal sync_mux_MAXMIN_in :std_logic := '1';
	signal sync_mux_MAXMIN_auto_in :std_logic := '0';
	signal sync_mux_UPDATE_fix_in :std_logic := '0';
	--- control phases from fsm combinatorial logic
	signal async_UPDATE_fsm: std_logic;
	signal async_RES: std_logic;
	signal async_VRES: std_logic;	
	signal async_NEXT_ROW: std_logic;
	signal async_RAMP_DIG: std_logic;
	signal async_RNDEC: std_logic;
	signal async_RN: std_logic;
	signal async_RC: std_logic;
	signal async_EOF: std_logic;
	--- more combinatorial logic on phases and control signals
	signal async_UPDATE_comb: std_logic;
	signal async_MAXMIN_comb: std_logic; 
	--- sync more combinatorial logic on phases and control signals
	signal sync_UPDATE_comb: std_logic := '0';
	signal sync_MAXMIN_comb: std_logic := '0'; 
	--- memorise the input
	signal S8B_in :std_logic; 
	signal MASK_in :std_logic;
	signal MAXMIN_in :std_logic;
	signal MAXMIN_auto_in :std_logic;
	signal S0_in :std_logic;
	signal S1_in :std_logic;
	signal DATA_DOWNLOADING_in :std_logic;
	signal CNT_in :std_logic;
	signal UPDATE_fix_in:std_logic;
	----------------------------------
	--- MAXMIN fsm -------------------
	----------------------------------
	type state_MM is (Max_start, Max_wait, Min_start, Min_wait);
	signal pr_state_MM, nx_state_MM: state_MM;
	----------------------------------
	signal async_MAXMIN_MM_fsm :std_logic;
	
begin
	----------------------------------
	--- MAIN fsm 	-------------------
	----------------------------------
	
	main_fsm_seq: process(clk,rst)
	begin
		if (rst='1') then
			pr_state <= reset;
		elsif (clk'EVENT AND clk='1') THEN
			pr_state <= nx_state;
		end if;
	end process main_fsm_seq;
	
	
	main_fsm_comb: process(pr_state,end_PREPARE_INTEGRATION,end_PWM_UP,end_AFTER_INTEGRATION,
				end_PREPARE_READOUT,end_RESET_RN,end_PWM_DOWN,end_FINISH_READOUT,
				end_SR,end_UPDATE_ROW,end_NEXT_ROW_EOF)--,end_EOF)	
	begin
		case pr_state is
			when reset=>
				nx_state <= general_conf_state;
				-------------------------
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '1';
				async_rst_PWM_DOWN_COST <='1';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN <= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '0';	
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '1';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '1';
				async_EOF <= '0';
				---------------------------
			
			when general_conf_state=>
				--- wait here if we are downloading data
				if DATA_DOWNLOADING_in ='1' then
					nx_state <= general_conf_state;
				else
					nx_state <= prepare_integration;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='0';
				async_rst_PREPARE_INTEGRATION <= '0';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN <= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				-----------------------------
				-- mux the new configuration --
				-----------------------------
				mux_the_input <= '1';
				--------------------------
				async_RES<= '1';
				async_VRES<= '0';	
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '1';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '1';
				async_EOF <= '0';
				---------------------------
			
			when prepare_integration=>
				if end_PREPARE_INTEGRATION ='1' then
					nx_state <= integration;
				else
					nx_state <= prepare_integration;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='0';
				async_rst_PREPARE_INTEGRATION <= '0';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN <= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '0';	
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '1';
				async_RNDEC<= '0';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '1';
				async_EOF <= '0';
				---------------------------
			
			when integration =>
				if end_PWM_UP ='1' then
					nx_state <= after_integration;
				else
					nx_state <= integration;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '1';
				async_rst_PWM_DOWN_COST <='0';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '0';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN<= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '0';
				async_VRES<= '0';			
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '1';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '1';
				async_EOF <= '0';
				---------------------------
			
			when after_integration =>
				if end_AFTER_INTEGRATION ='1' then
					nx_state <= prepare_readout;
				else
					nx_state <= after_integration;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='0';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '0';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN<= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '0';
				async_VRES<= '1';			
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '1';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '1';
				async_EOF <= '0';
				---------------------------
			
			when prepare_readout =>
				if end_PREPARE_READOUT ='1' then
					nx_state <= reset_RN;
				else
					nx_state <= prepare_readout;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='0';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '0';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN<= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '1';			
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '1';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '1';
				async_EOF <= '0';
				---------------------------
			
			when reset_RN =>
				if end_RESET_RN ='1' then
					nx_state <= ramp_row;
				else
					nx_state <= reset_RN;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='0';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '0';
				async_rst_PWM_DOWN<= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '1';			
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '1';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '0';
				async_RC<= '1';
				async_EOF <= '0';
				---------------------------
			
			when 	ramp_row =>
				if end_PWM_DOWN ='1' then
					nx_state <= finish_readout;
				else
					nx_state <= ramp_row;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='1';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN<= '0';
				async_rst_GENERATE_CLKADC_RESNBL <= '0';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '1';			
				async_NEXT_ROW<= '1';
				async_RAMP_DIG <= '0';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';			
				async_RN<= '1';
				async_RC<= '0';
				async_EOF <= '0';
				---------------------------
			
		when finish_readout =>
				if end_FINISH_READOUT ='1' then
					nx_state <= update_row;
				else
					nx_state <= finish_readout;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='1';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN<= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '0';
				async_rst_FINISH_READOUT <= '0';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '1';			
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '0';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '0';
				async_EOF <= '0';
				---------------------------
			
			when 	update_row =>
				if end_UPDATE_ROW ='1' then
					nx_state <= read_out_row;
				else
					nx_state <= update_row;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='1';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN<= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '0';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '1';			
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '0';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '1';
				async_RN<= '1';
				async_RC<= '0';
				async_EOF <= '0';
				---------------------------	
			
			when 	read_out_row =>
				if end_SR ='1' then
					nx_state <= next_row_eof;
				else
					nx_state <= read_out_row;
				end if;
				async_rst_SR<= '0';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='1';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN<= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '1';			
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '0';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '1';
				async_EOF <= '0';
				---------------------------
				
			when 	next_row_eof =>
				if end_NEXT_ROW_EOF ='1' then
					nx_state <= prepare_readout;
--					if end_EOF = '1' then
--						nx_state <= reset;
--					else
--						nx_state <= prepare_readout;
--					end if;	
				else
					nx_state <= next_row_eof;
				end if;
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '0';
				async_rst_PWM_DOWN_COST <='0';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN<= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '0';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '1';			
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '1';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '1';
				async_EOF <= '1';
				---------------------------	
			
			when others =>
				nx_state <= reset;
				-------------------------
				async_rst_SR<= '1';
				async_rst_PWM_COST<= '1';
				async_rst_PWM_DOWN_COST <='1';
				async_rst_PREPARE_INTEGRATION <= '1';
				async_rst_PWM_UP<= '1';
				async_rst_AFTER_INTEGRATION<= '1';
				async_rst_PREPARE_READOUT <= '1';
				async_rst_RESET_RN <= '1';
				async_rst_PWM_DOWN <= '1';
				async_rst_GENERATE_CLKADC_RESNBL <= '1';
				async_rst_FINISH_READOUT <= '1';
				async_rst_UPDATE_ROW <= '1';
				async_rst_NEXT_ROW_EOF <= '1';
				--------------------------
				mux_the_input <= '0';
				--------------------------
				async_RES<= '1';
				async_VRES<= '0';	
				async_NEXT_ROW<= '0';
				async_RAMP_DIG <= '1';
				async_RNDEC<= '1';
				async_UPDATE_fsm<= '0';
				async_RN<= '1';
				async_RC<= '1';
				async_EOF <= '0';
				---------------------------
				
		end case;
	end process main_fsm_comb;
	
	----------------------------------
	--- MAXMIN fsm -------------------
	----------------------------------
	MM_fsm_seq: process(clk)
	begin
		if (clk'EVENT AND clk='1') THEN
--			if (rst='1') then
--				pr_state_MM <= Min_wait;
--			else	
				pr_state_MM <= nx_state_MM;
--			end if;	
		end if;
	end process MM_fsm_seq;
	
	MM_fsm_comb: process(pr_state_MM,mux_the_input)
	begin
		case pr_state_MM is
			when Max_start=>
				if mux_the_input = '1' then
					nx_state_MM <= Max_start;
				else
					nx_state_MM <= Max_wait;
				end if;
				async_MAXMIN_MM_fsm <= '1';
				--------------------------
				
			when Max_wait=>
				if mux_the_input = '0' then
					nx_state_MM <= Max_wait;
				else
					nx_state_MM <= Min_start;
				end if;
				async_MAXMIN_MM_fsm <= '1';
				--------------------------
				
			when Min_start=>
				if mux_the_input = '1' then
					nx_state_MM <= Min_start;
				else
					nx_state_MM <= Min_wait;
				end if;
				async_MAXMIN_MM_fsm <= '0';
				---------------------------
				
			when Min_wait=>
				if mux_the_input = '0' then
					nx_state_MM <= Min_wait;
				else
					nx_state_MM <= Max_start;
				end if;
				async_MAXMIN_MM_fsm <= '0';
				--------------------------
				
			when others =>
				nx_state_MM <= Min_wait;
				async_MAXMIN_MM_fsm <= '0';
				---------------------------		
		end case;	
	end process MM_fsm_comb;
	
	-------------------------------------------------------------------------
	--- see muxed signal svg scheme 
	-------------------------------------------------------------------------
	lets_sync_mux_in: process(clk)
	begin
		if (clk'EVENT AND clk='1') THEN
			if (rst = '1') then
				S8B_in <= '1'; -- 1 = 8 bit mode 
				MASK_in<= '0';
				MAXMIN_in<= '1';
				MAXMIN_auto_in <= '0';
				S0_in <= '1';
				S1_in <= '1';
				CNT_in <= '1';
				UPDATE_fix_in <= '0';
				DATA_DOWNLOADING_in <= '0';
			else
				--- copy the content of general conf in corresponding input signal
				S8B_in <= general_conf(0); -- 1 = 8 bit mode 
				MASK_in<= general_conf(1);
				MAXMIN_in<= general_conf(2);
				MAXMIN_auto_in <= general_conf(8);
				S0_in <= general_conf(3);
				S1_in <= general_conf(4);
				CNT_in <= general_conf(5);
				UPDATE_fix_in <= general_conf(6);
				DATA_DOWNLOADING_in <= general_conf(7);
			end if;
		end if;
	end process lets_sync_mux_in;
	
	lets_mux_the_input: process(mux_the_input,S8B_in,MASK_in,S0_in,S1_in,MAXMIN_in,MAXMIN_auto_in,CNT_in,UPDATE_fix_in,DATA_DOWNLOADING_in)	
	begin
		if (mux_the_input = '1') then
			mux_S8B  <= S8B_in; 
			mux_MASK <= MASK_in;
			mux_MAXMIN_in <= MAXMIN_in;
			mux_MAXMIN_auto_in <= MAXMIN_auto_in;
			mux_S0 <= S0_in;
			mux_S1 <= S1_in;
			mux_CNT <= CNT_in;
			mux_UPDATE_fix_in <= UPDATE_fix_in;
			mux_DATA_DOWNLOADING <= DATA_DOWNLOADING_in;		
		else
			--keep the flip-flopped output values
			mux_S8B  <= sync_mux_S8B; 
			mux_MASK <= sync_mux_MASK;
			mux_MAXMIN_in <= sync_mux_MAXMIN_in;
			mux_MAXMIN_auto_in <= sync_mux_MAXMIN_auto_in;
			mux_S0 <= sync_mux_S0;
			mux_S1 <= sync_mux_S1;
			mux_CNT <= sync_mux_CNT;
			mux_UPDATE_fix_in <= sync_mux_UPDATE_fix_in;
			mux_DATA_DOWNLOADING <= sync_mux_DATA_DOWNLOADING;
		end if;
	end process lets_mux_the_input;
	
	lets_sync_mux_out: process(clk)
	begin
		if (clk'EVENT AND clk='1') THEN
			if (rst = '1') then
				sync_mux_S8B <= '1'; 
				sync_mux_MASK <= '0';
				sync_mux_MAXMIN_in <= '1';
				sync_mux_MAXMIN_auto_in <= '0';
				sync_mux_S0 <= '1';
				sync_mux_S1 <= '1';
				sync_mux_CNT <= '1';
				sync_mux_UPDATE_fix_in <= '0';
				sync_mux_DATA_DOWNLOADING <= '0';
			else
				sync_mux_S8B  <= mux_S8B; 
				sync_mux_MASK <= mux_MASK;
				sync_mux_MAXMIN_in <= mux_MAXMIN_in;
				sync_mux_MAXMIN_auto_in <= mux_MAXMIN_auto_in;
				sync_mux_S0 <= mux_S0;
				sync_mux_S1 <= mux_S1;
				sync_mux_CNT <= mux_CNT;
				sync_mux_UPDATE_fix_in <= mux_UPDATE_fix_in;
				sync_mux_DATA_DOWNLOADING <= mux_DATA_DOWNLOADING;
			end if;	
		end if;
	end process lets_sync_mux_out;	
	-- output the sync version of the muxer
	S8B <= sync_mux_S8B;
	MASK <= sync_mux_MASK;
	S0 <= sync_mux_S0;
	S1 <= sync_mux_S1;
	CNT <= sync_mux_CNT;
	DATA_DOWNLOADING <= sync_mux_DATA_DOWNLOADING;
	
	-- more combinatorial logic ---
	async_UPDATE_comb <= mux_UPDATE_fix_in or async_UPDATE_fsm;
	with mux_MAXMIN_auto_in select
		async_MAXMIN_comb <= mux_MAXMIN_in when '0',
									async_MAXMIN_MM_fsm when '1',
									mux_MAXMIN_in when others;
	
	lets_sync_more_comb: process(clk)
	begin
		if (clk'EVENT AND clk='1') THEN
			if (rst = '1') then
				sync_UPDATE_comb <= '0';
				sync_MAXMIN_comb  <= '1';
			else
				sync_UPDATE_comb <= async_UPDATE_comb;
				sync_MAXMIN_comb <= async_MAXMIN_comb;
			end if;	
		end if;
	end process lets_sync_more_comb;
	
	-- output the sync version of more combinatorial
	MAXMIN <= sync_MAXMIN_comb;
	UPDATE <= sync_UPDATE_comb;
	--------------------------------------------------------------------------------
	------  SYNCRONIZE THE ASYNC CONTROL AND PHASES GENERATE BY FSM COMB LOGIC -----
	--------------------------------------------------------------------------------
	ff_sync_control_out: process(clk)
	begin
		if (clk'EVENT AND clk='1') THEN
			if (rst = '1') then
				rst_SR<= '1';
				rst_PREPARE_INTEGRATION<= '1';
				rst_PWM_UP<= '1';
				rst_AFTER_INTEGRATION<= '1';
				rst_PREPARE_READOUT<= '1';
				rst_RESET_RN <= '1';
				rst_PWM_DOWN<= '1';
				rst_GENERATE_CLKADC_RESNBL <='1';
				rst_FINISH_READOUT<= '1';
				rst_UPDATE_ROW<= '1';
				rst_NEXT_ROW_EOF<= '1';
				rst_PWM_COST<= '1';
				rst_PWM_DOWN_COST<= '1';
			else
				--- syncronize the reset signals in the combinatorial part of the fsm ---
				rst_SR<= async_rst_SR;
				rst_PREPARE_INTEGRATION<= async_rst_PREPARE_INTEGRATION;
				rst_PWM_UP<= async_rst_PWM_UP;
				rst_AFTER_INTEGRATION<= async_rst_AFTER_INTEGRATION;
				rst_PREPARE_READOUT<= async_rst_PREPARE_READOUT;
				rst_RESET_RN <= async_rst_RESET_RN;
				rst_PWM_DOWN<= async_rst_PWM_DOWN;
				rst_GENERATE_CLKADC_RESNBL <= async_rst_GENERATE_CLKADC_RESNBL;
				rst_FINISH_READOUT<= async_rst_FINISH_READOUT;
				rst_UPDATE_ROW<= async_rst_UPDATE_ROW;
				rst_NEXT_ROW_EOF<= async_rst_NEXT_ROW_EOF;
				rst_PWM_COST<= async_rst_PWM_COST;
				rst_PWM_DOWN_COST<= async_rst_PWM_DOWN_COST;
			end if;
		end if;
	end process ff_sync_control_out;
	
	ff_sync_phases_out: process(clk)
	begin
		if (clk'EVENT AND clk='1') THEN
			if (rst ='1') then
				RES <= '1';
				VRES <= '0';
				NEXT_ROW <= '0';
				RAMP_DIG <= '1';
				RNDEC <= '1';
				RN <= '1';
				RC <= '1';
				EOF <= '0';
			else
				--- syncronize the phases
				RES <= async_RES;
				VRES <= async_VRES;	
				NEXT_ROW <= async_NEXT_ROW;
				RAMP_DIG <= async_RAMP_DIG;
				RNDEC <= async_RNDEC;
				RN <= async_RN;
				RC <= async_RC;
				EOF <= async_EOF;
			end if;	
		end if;
	end process ff_sync_phases_out;
	 
	
end Behavioral;

