----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:12:48 01/15/2013 
-- Design Name: 
-- Module Name:    enervis_bin_pcb0_sp6 - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;
use work.enervis_package_S6.all;

-- opalkelly interface:
use work.FRONTPANEL.all;

entity enervis_bin_pcb0_sp6 is
port(
		-- opalkelly interface:
		 hi_in     : in STD_LOGIC_VECTOR(7 downto 0);
		 hi_out    : out STD_LOGIC_VECTOR(1 downto 0);
		 hi_inout  : inout STD_LOGIC_VECTOR(15 downto 0);
		 --hi_muxsel : out STD_LOGIC;
--		
		gCLK		: in std_logic;
		gRST     : in std_logic;
		button : in std_logic_vector(3 downto 0);
		led: out std_logic_vector (7 downto 0);
		--- phases 
		gQ : in std_logic;
		gVT : out std_logic;
		gRES: out std_logic;
		gVRES_out: out std_logic;
		gRAMP: out std_logic;
		gRAMP_2 : out std_logic;
		gRAMP_DIG_0: out std_logic;
		gRAMP_DIG_1: out std_logic;
		gNEXT_out: out std_logic;
		gRNDEC: out std_logic;
		gUPDATE_out: out std_logic;
		gCLK_SH: out std_logic;
		gRN_out: out std_logic;
		gRC: out std_logic;
		gRSN_BL_out: out std_logic;
		gCLKADC_out : out std_logic;
		gVDD_out : out std_logic;
		gCNT_out: out std_logic;
		gQOSC_in: in std_logic;
		gHOT_in: in std_logic;
		gQS_in: in std_logic;
		---control signals
		gEOF_in: in std_logic;
		
		gS8B_out: out std_logic;
		gMASK_out: out std_logic;
		gS0_out: out std_logic;
		gS1_out: out std_logic;
		gDATA_DOWNLOADING_out: out std_logic;
		gMAXMIN_out: out std_logic
		--deb_DATA_TO_WRITE : out std_logic_vector (15 downto 0);
		--debug_PIPEO_DATA : out std_logic_vector (15 downto 0)
	);
end enervis_bin_pcb0_sp6;

architecture Behavioral of enervis_bin_pcb0_sp6 is




 -----------------------------------------------------------
 -- OPALKELLY INTERFACE
 -----------------------------------------------------------

signal ti_clk : STD_LOGIC;
signal ok1 : STD_LOGIC_VECTOR(30 downto 0);
signal ok2 : STD_LOGIC_VECTOR(16 downto 0);
signal ok2s : STD_LOGIC_VECTOR(17*18-1 downto 0);
-- signal interface between software and firmware:
-- wait phase configuration
signal clk_wait_prepare_readout: std_logic_vector (15 downto 0) := 		"0000000111110100"; -- 500@50MHz (10us)
signal clk_wait_finish_readout: std_logic_vector (15 downto 0) := 		"0000000111110100"; -- 500@50MHz (10us)
signal clk_wait_prepare_integration: std_logic_vector (15 downto 0) := 	"0000000011111010"; -- 250@50MHz (5us)
signal clk_wait_finish_integration: std_logic_vector (15 downto 0) := 	"0000000011111010"; -- 250@50MHz (5us)
signal clk_wait_update_row: std_logic_vector (15 downto 0) := 				"0000000011111010"; -- 250@50MHz (5us)
signal clk_wait_next_row_eof: std_logic_vector (15 downto 0) := 			"0000000011111010"; -- 250@50MHz (5us)
-- pwm configuration
signal sig_pwm_down_cost_duty: std_logic_vector (15 downto 0) := 		"0000000000101101"; --45
signal sig_pwm_down_cost_length: std_logic_vector (15 downto 0) := 	"0000000001000000"; --64
signal sig_pwm_down_end: std_logic_vector (15 downto 0):= 				"0000000000101101"; --45
signal sig_pwm_down_length: std_logic_vector (15 downto 0):= 			"0000000001000000"; --64
signal sig_pwm_down_increment: std_logic_vector (15 downto 0):= 		"0000000000000001"; --1
signal sig_pwm_up_cost_duty: std_logic_vector (15 downto 0) := 		"0000000000111110"; --65
signal sig_pwm_up_cost_length: std_logic_vector (15 downto 0) := 		"0000000011111111"; --255
signal sig_pwm_up_end: std_logic_vector (15 downto 0):= 					"0000000001111100"; --124
signal sig_pwm_up_length: std_logic_vector (15 downto 0):= 				"0000000111111111"; --511
signal sig_pwm_up_increment: std_logic_vector (15 downto 0):= 			"0000000000000001"; --1 
-- clkadc configuration
signal sig_time_conversion_max_11bit: std_logic_vector (15 downto 0):="0000000100101100"; -- 11 bit (2047, 20us)
signal sig_time_point_A_11bit: std_logic_vector (15 downto 0):="0000000001100100";
signal sig_time_point_B_11bit: std_logic_vector (15 downto 0):="0000000001100100";
signal sig_conv_div_A_5bit : std_logic_vector (15 downto 0):="0000000000000011"; --5 bit (max 31)
signal sig_conv_div_B_5bit : std_logic_vector (15 downto 0):="0000000000001010"; --5 bit (max 31)
signal sig_conv_div_C_5bit: std_logic_vector (15 downto 0):="0000000000011111";
-- rstbnl configuration
signal sig_rsnbl_stop_value: std_logic_vector (15 downto 0):= 			"0000110000000000"; --3072 
signal sig_rsnbl_start_value: std_logic_vector (15 downto 0):= 			"0000000000000001"; --3072 

--general conf (S8B, Mask, MaxMin,  ...) 
signal sig_general_conf: std_logic_vector (15 downto 0):= 			"0000000000111101";   
-- default word = "0000000000111101";
-- S8B <= general_conf(0); -- 1 (0:hot pixel mode, 1:8 bit mode) 
-- MASK<= general_conf(1); -- 0 (0: Mask disable, 1: Mask enable)
-- MAXMIN<= general_conf(2); -- 1 (0: Min, 1: Max)
-- S0 <= general_conf(3); -- 1
-- S1 <= general_conf(4); -- 1  													
-- CNT<= general_conf(5); -- 1 (0: clkadc from fpga 1:internal oscillator)
-- UPDATE_FIX_IN <= general_conf(6); -- 0 (0 update signal driven by fsm, 1: fixed high) 
-- DATA_DOWNLOADING <= general_conf(7); -- 0	(goes to 1 when pipe readout)
-- MAXMIN_auto_in <= general_conf(8); -- 0 (0:select from software 1:driven by fsm)


--*reading* interface with the memory controller (there is a doubled signals declaration: signals that
--are declared in the memory controller are also declared here. The two signals are then attached
--togheter and became the same signal when processed by the syntetizer. This weird think is done
--in order to avoid to write more code when the code will be ported to another interface..)
-- gCLK_READ_RAM is attached to ti_clk
signal sig_gPIPEO_READ: std_logic;
signal sig_gPIPEO_READ_1: std_logic;
signal sig_gPIPEO_READ_2: std_logic;
signal sig_gPIPEO_READ_3: std_logic;
signal sig_gPIPEO_READ_4: std_logic;
signal sig_gPIPEO_READ_5: std_logic;
signal sig_gPIPEO_READ_6: std_logic;

signal sig_gPIPEO_DATA: std_logic_VECTOR (15 DOWNTO 0);
signal sig_gPIPEO_DATA_1: std_logic_VECTOR (15 DOWNTO 0);
signal sig_gPIPEO_DATA_2: std_logic_VECTOR (15 DOWNTO 0);
signal sig_gPIPEO_DATA_3: std_logic_VECTOR (15 DOWNTO 0);
signal sig_gPIPEO_DATA_4: std_logic_VECTOR (15 DOWNTO 0);
signal sig_gPIPEO_DATA_5: std_logic_VECTOR (15 DOWNTO 0);
signal sig_gPIPEO_DATA_6: std_logic_VECTOR (15 DOWNTO 0);

signal sig_gPIPEO_COUNT: std_logic_VECTOR (31 DOWNTO 0);
signal sig_gACTUAL_RAM_ADDRESS: std_logic_VECTOR (15 DOWNTO 0);
signal sig_gACTUAL_RAM_BLOCK: std_logic_VECTOR (15 DOWNTO 0); 
signal sig_gSELECT_RAM_BLOCK_TO_READ: std_logic_vector (15 downto 0):= 	"0000000000000001";
--this two signals comes from the old reading interface of opalkelly , can be used to reset the counters of the 
--reading interface from the vhdl (not really useful)
signal count_reset: std_logic ;
signal trig_ram0read: std_logic ;
signal ep40trig : STD_LOGIC_VECTOR(15 downto 0);-- ep40 trigger
-----------------------------------------------------------
-- SIGNALs for FSM
-----------------------------------------------------------
signal gRAMP_DIG : std_logic;
signal gNEXT : std_logic;
signal gRN : std_logic;
signal gEOF :std_logic;
signal gVRES :std_logic;
--controls
signal gMAXMIN :std_logic;
signal gMASK :std_logic;
signal gS0 :std_logic;
signal gS1 :std_logic;
signal gCNT :std_logic;
signal gDATA_DOWNLOADING: std_logic;
signal gUPDATE: std_logic;
 -----------------------------------------------------------
 -- PWM DOWN & FSM
 -----------------------------------------------------------
signal gRST_PWM_DOWN : std_logic;
signal gSYNC_PWM_DOWN : std_logic;
signal gEND_PWM_DOWN : std_logic;

signal gRAMP_PWM_DOWN: std_logic;
 -----------------------------------------------------------
 -- PWM DOWN COST & FSM
 -----------------------------------------------------------
signal gRST_PWM_DOWN_COST : std_logic;
signal gRAMP_DC : std_logic;
 -----------------------------------------------------------
 -- CLKADC + RESNBL & FSM
 -----------------------------------------------------------
signal gCLKADC: std_logic;
signal gRST_GENERATE_CLKADC_RESNBL: std_logic;
signal gRESNBL: std_logic;
 -----------------------------------------------------------
 -- PWM UP & FSM
 -----------------------------------------------------------
signal gRST_PWM_UP : std_logic;
signal gSYNC_PWM_UP : std_logic;
signal gEND_PWM_UP : std_logic;
signal gRAMP_PWM_UP : std_logic;
 -----------------------------------------------------------
 -- PWM COST & FSM
 -----------------------------------------------------------
signal gRST_PWM_COST : std_logic;
signal gRAMP_PWM_COST : std_logic;
 -----------------------------------------------------------
 -- PREPARE INTEGRATION  & FSM
 -----------------------------------------------------------
signal gRST_PREPARE_INTEGRATION : std_logic;
signal gSYNC_PREPARE_INTEGRATION : std_logic;
signal gEND_PREPARE_INTEGRATION : std_logic;
 -----------------------------------------------------------
 -- AFTER INTEGRATION  & FSM
 -----------------------------------------------------------
signal gRST_AFTER_INTEGRATION : std_logic;
signal gSYNC_AFTER_INTEGRATION : std_logic;
signal gEND_AFTER_INTEGRATION : std_logic;

 -----------------------------------------------------------
 -- PREPARE READOUT  & FSM
 -----------------------------------------------------------
signal gRST_PREPARE_READOUT : std_logic;
signal gSYNC_PREPARE_READOUT : std_logic;
signal gEND_PREPARE_READOUT : std_logic;
 -----------------------------------------------------------
 -- RESET RN  & FSM
 -----------------------------------------------------------
signal gRST_RESET_RN : std_logic;
signal gSYNC_RESET_RN : std_logic;
signal gEND_RESET_RN : std_logic;
 -----------------------------------------------------------
 -- FINISH READOUT  & FSM
 -----------------------------------------------------------
signal gRST_FINISH_READOUT : std_logic;
signal gSYNC_FINISH_READOUT : std_logic;
signal gEND_FINISH_READOUT : std_logic;
 -----------------------------------------------------------
 -- UPDATE ROW  & FSM
 -----------------------------------------------------------
signal gRST_UPDATE_ROW : std_logic;
signal gSYNC_UPDATE_ROW : std_logic;
signal gEND_UPDATE_ROW : std_logic;
 -----------------------------------------------------------
 -- NEXT ROW EOF & FSM
 -----------------------------------------------------------
signal gRST_NEXT_ROW_EOF : std_logic;
signal gSYNC_NEXT_ROW_EOF : std_logic;
signal gEND_NEXT_ROW_EOF : std_logic; 


 
 -----------------------------------------------------------
 -- DEBOUNCER 
 -----------------------------------------------------------
--signal gRST : std_logic;
signal gRST_DB : std_logic;
signal gBUTTON :std_logic_vector(3 downto 0);
signal deb_button_neg :std_logic_vector(3 downto 0);
 -----------------------------------------------------------
 -- MEMORY MANAGER 
 -----------------------------------------------------------

signal gCLK_READ_RAM: std_logic; 

signal gPIPEO_DATA: std_logic_VECTOR (15 DOWNTO 0);
signal gPIPEO_DATA_1: std_logic_VECTOR (15 DOWNTO 0);
signal gPIPEO_DATA_2: std_logic_VECTOR (15 DOWNTO 0);
signal gPIPEO_DATA_3: std_logic_VECTOR (15 DOWNTO 0);
signal gPIPEO_DATA_4: std_logic_VECTOR (15 DOWNTO 0);
signal gPIPEO_DATA_5: std_logic_VECTOR (15 DOWNTO 0);
signal gPIPEO_DATA_6: std_logic_VECTOR (15 DOWNTO 0);

signal gPIPEO_COUNT: std_logic_VECTOR (31 DOWNTO 0);
signal gACTUAL_RAM_ADDRESS: std_logic_VECTOR (15 DOWNTO 0);
signal gACTUAL_RAM_BLOCK: std_logic_VECTOR (15 DOWNTO 0); 

signal gSELECT_RAM_BLOCK_TO_READ: std_logic_vector (15 downto 0);
 ---------------------------------------------------------
 --- HIGH LEVEL COMPONENTS (NOT DECLARED IN LIBRARY) -----
 ---------------------------------------------------------
 -----------------------------------------------------------
 -- SERIAL RECEIVER:
 -----------------------------------------------------------
 -- interface with the FSM :
signal gS8B : std_logic;  
signal gRST_SR_READOUT: std_logic;
signal gSYNC_SR_READOUT:   std_logic;
signal gEND_SR_READOUT:   std_logic;
 -------------------------------------------------------------------
 -- interface with MEMORY CONTROLLER :
signal gDATA:  std_logic_vector (15 DOWNTO 0);
 
signal gNUMBER_OF_SR_ROUT_OF_LINE: std_logic_vector (15 DOWNTO 0);
signal gNUMBER_OF_LINE_READ: std_logic_vector (15 DOWNTO 0);
 
signal gSYNC_END_OF_FRAME: std_logic;
signal gSYNC_SR: std_logic;
-- interface with the 104 missing dFlip-flop
signal gQ_FF: std_logic;
signal gCLK_SH_FF: std_logic;

  -------------------------------------------------------------------
 COMPONENT sr_readout_2 is
	Generic (
	N : positive := 16  --  serial word length 
	);
	port(din, clk, rst,s8b: IN std_logic;
	sync_out : OUT std_logic;
	sync_out_sr : OUT std_logic;
	clk_sh : OUT std_logic;
	number_of_sr_readout_of_line:  OUT std_logic_VECTOR (15 DOWNTO 0);
	data: OUT std_logic_VECTOR (N-1 DOWNTO 0)
	);
 END COMPONENT;
 -----------------------------------------------------------
 --########################################################-
 -----------------------------------------------------------
 -- RESET MANAGER 
 -----------------------------------------------------------
 signal gEOF_RESET: std_logic;
 signal gRST_FSM,gRST_LINE_COUNTER,gRST_MEMORY_MANAGER: std_logic;
------------------------------------------------------------
 COMPONENT test_reset_manager is
    Port ( clk: in STD_LOGIC;
			  global_reset : in  STD_LOGIC;
           EOF_reset : in  STD_LOGIC;
           rst_fsm : out  STD_LOGIC;
           rst_line_counter : out  STD_LOGIC;
           rst_memory_manager : out  STD_LOGIC);
 END COMPONENT;
 

----------------------------------------------------------------
--############################################################--
--############################################################--
----------------------------------------------------------------
begin

gVDD_out <= '1';
-----------------------------------------------------
gEND_SR_READOUT <= gSYNC_SR_READOUT and not(gRST_SR_READOUT); 
gEND_PREPARE_INTEGRATION <= gSYNC_PREPARE_INTEGRATION and not(gRST_PREPARE_INTEGRATION);
gEND_PWM_UP <= gSYNC_PWM_UP and not(gRST_PWM_UP);
gEND_AFTER_INTEGRATION <= gSYNC_AFTER_INTEGRATION and not(gRST_AFTER_INTEGRATION);
gEND_PREPARE_READOUT <= gSYNC_PREPARE_READOUT and not(gRST_PREPARE_READOUT);
gEND_PWM_DOWN <= gSYNC_PWM_DOWN and not(gRST_PWM_DOWN);
gEND_FINISH_READOUT <= gSYNC_FINISH_READOUT and not(gRST_FINISH_READOUT);
gEND_UPDATE_ROW <= gSYNC_UPDATE_ROW and not(gRST_UPDATE_ROW);
gEND_NEXT_ROW_EOF <= gSYNC_NEXT_ROW_EOF and not(gRST_NEXT_ROW_EOF);
gEND_RESET_RN <= gSYNC_RESET_RN and not(gRST_RESET_RN);
-----------------------------------------------------
gRAMP <= gRAMP_PWM_DOWN or gRAMP_DC;
gRAMP_2 <= gRAMP_PWM_DOWN or gRAMP_DC;

-- the gVRES_out in the pcb is the not of the old gVRES
gVRES_out <= not gVRES;
-- the ramp stay down after the conversion
--gRAMP_DIG_0 <= gRAMP_DIG;
--gRAMP_DIG_1 <= gRAMP_DIG;
-- the ramp returns up after the conversion
gRAMP_DIG_0 <= gNEXT; --in the board a CMOS inverter is connected to this two signals
gRAMP_DIG_1 <= gNEXT; --in the board a CMOS inverter is connected to this two signals
-- connect the gNEXT to the output
gNEXT_out <= gNEXT;
--
gVT <= gRAMP_PWM_UP or gRAMP_PWM_COST;
gRN_out <= gRN;
gS8B_out <= gS8B;
--gEOF <= gEOF_reset;

reset_manager : test_reset_manager
	PORT MAP (
				clk=>gCLK,
				----------------------
				global_reset => gRST_DB,
				EOF_reset =>gEOF_RESET,
				----------------------
				rst_fsm =>gRST_FSM,
				rst_line_counter =>gRST_LINE_COUNTER,
				rst_memory_manager =>gRST_MEMORY_MANAGER
	);
---------------------------------------------------------------				
fsm : test_fsm
	PORT MAP (
				clk=>gCLK,
				rst=>gRST_FSM,
				--------------------------conf -------
				general_conf => sig_general_conf,
				-------------------------sync out-----
				rst_SR => gRST_SR_READOUT,
				rst_PWM_UP => gRST_PWM_UP,
				rst_PWM_COST => gRST_PWM_COST,
				rst_PWM_DOWN_COST =>gRST_PWM_DOWN_COST,
				rst_PREPARE_INTEGRATION => gRST_PREPARE_INTEGRATION,
				rst_AFTER_INTEGRATION => gRST_AFTER_INTEGRATION,
				rst_PREPARE_READOUT => gRST_PREPARE_READOUT,
				rst_RESET_RN=>gRST_RESET_RN,
				rst_PWM_DOWN => gRST_PWM_DOWN,
				rst_GENERATE_CLKADC_RESNBL => gRST_GENERATE_CLKADC_RESNBL,
				rst_FINISH_READOUT => gRST_FINISH_READOUT,
				rst_UPDATE_ROW=> gRST_UPDATE_ROW,
				rst_NEXT_ROW_EOF=> gRST_NEXT_ROW_EOF,
				-------------------------sync in-----
				end_SR=> gEND_SR_READOUT,
				end_PWM_UP => gEND_PWM_UP,
				end_PREPARE_INTEGRATION => gEND_PREPARE_INTEGRATION,
				end_AFTER_INTEGRATION => gEND_AFTER_INTEGRATION,
				end_PREPARE_READOUT => gEND_PREPARE_READOUT,
				end_RESET_RN => gEND_RESET_RN,
				end_PWM_DOWN => gEND_PWM_DOWN,
				end_FINISH_READOUT => gEND_FINISH_READOUT,
				end_UPDATE_ROW => gEND_UPDATE_ROW,
				end_NEXT_ROW_EOF=> gEND_NEXT_ROW_EOF,
				--end_EOF => gSYNC_END_OF_FRAME,
				--- phases
				RES=> gRES,
				VRES=> gVRES,
				RAMP_DIG => gRAMP_DIG,
				NEXT_ROW=>gNEXT,
				RNDEC=> gRNDEC,
				UPDATE=>gUPDATE,
				RN=>gRN,
				RC=>gRC,
				EOF=>gEOF,
				--- control signals
				S8B=>gS8B,
				MASK=>gMASK,
				S0 =>gS0,
				S1 =>gS1,
				DATA_DOWNLOADING=>gDATA_DOWNLOADING,				
				MAXMIN=>gMAXMIN,
				CNT =>gCNT 
	);
	
gDATA_DOWNLOADING_out <= gDATA_DOWNLOADING;
gMAXMIN_out <=	gMAXMIN;
gS0_out <= gS0;
gS1_out <= gS1; 
gMASK_out <= gMASK;
gCNT_out <= gCNT;
gUPDATE_out <=gUPDATE; 
-----------------------------------------------------
missing_flip_flop : dFF_2
	PORT MAP (d=>gQ,
				clk=>gCLK,
				clk_sh=>gCLK_SH_FF,
				rst=>gRST,
				q=>gQ_FF );
------------------------------------------------------				
serial_receiver: sr_readout_2 
	PORT MAP (din=>gQ_FF, 
				clk=>gCLK,
				rst=>gRST_SR_READOUT,
				s8b => gS8B,
				sync_out =>gSYNC_SR_READOUT,
				sync_out_sr =>gSYNC_SR,
				number_of_sr_readout_of_line=> gNUMBER_OF_SR_ROUT_OF_LINE,
				clk_sh=> gCLK_SH_FF,
				data=>gDATA  );
gCLK_SH <= gCLK_SH_FF;				
------------------------------------------------------
--count_line_read : test_counter_2
--PORT MAP (clk=>gCLK,
--		rst=>gRST_LINE_COUNTER,
--		sync_out => gSYNC_END_OF_FRAME, -- (frame end)
--		---------------------------
--		limit => "0000000001101000", --104 
--		event_to_count =>gSYNC_SR_READOUT,
--		rst_each_event => '0',
--		rst_event_generation => gEOF_RESET,
--		actual_value =>  gNUMBER_OF_LINE_READ
--);
------------------------------------------------------
count_line_read : counter_fsm104_2
PORT MAP (clk=>gCLK,
		rst=>gRST_LINE_COUNTER,
		sync_out => gSYNC_END_OF_FRAME, -- (frame end)
		---------------------------
		event_to_count =>gSYNC_SR_READOUT,
		rst_each_event => '0',
		rst_event_generation => gEOF_RESET,
		actual_value =>  gNUMBER_OF_LINE_READ
);

-----------------------------------------------------
memory_controller : test_memory_controller_2
PORT MAP (clk=>gCLK,
		rst=>gRST_MEMORY_MANAGER,
		number_of_sr_readout_of_line => gNUMBER_OF_SR_ROUT_OF_LINE,
		number_of_line_read=> gNUMBER_OF_LINE_READ,
		--------------------
		sync_end_of_SR => gSYNC_SR,
		sync_end_of_line => gSYNC_SR_READOUT,
		sync_end_of_frame => gSYNC_END_OF_FRAME,
		--------------------
		data=> gDATA,
		s8b => gS8B,
		
		clk_read_ram => gCLK_READ_RAM, 
		
		pipeO_data => gPIPEO_DATA,
		pipeO_data_1 => gPIPEO_DATA_1,
		pipeO_data_2 => gPIPEO_DATA_2,
		pipeO_data_3 => gPIPEO_DATA_3,
		pipeO_data_4 => gPIPEO_DATA_4,
		pipeO_data_5 => gPIPEO_DATA_5,
		pipeO_data_6 => gPIPEO_DATA_6,
		
		pipeO_count => gPIPEO_COUNT,
		actual_ram_address => gACTUAL_RAM_ADDRESS,
		actual_ram_block => gACTUAL_RAM_BLOCK,
		select_ram_block_to_read => gSELECT_RAM_BLOCK_TO_READ
		--data_to_write => deb_DATA_TO_WRITE
);	


-----------------------------------------------------			
-- PWM GENERATION ---				
-----------------------------------------------------
pwm_up : test_pwm 
   PORT MAP (
		clk => gCLK,
		rst=>gRST_PWM_UP,
		sync_out => gSYNC_PWM_UP,
		------------------------------------
		cost_value_12bit => sig_pwm_up_end(11 downto 0),
		--cost_value_10bit =>"0001111100", --124
		pwm_period_12bit => sig_pwm_up_length(11 downto 0),
		--pwm_period_10bit =>"0111111111", --511
		duty_increment_12bit => sig_pwm_up_increment(11 downto 0),
		--duty_increment_10bit =>"0000000001", --1
		------------------------------------
		pwm_out =>  gRAMP_PWM_UP);	
------------------------------------------------------
pwm_cost : test_pwm_cost_2 
   PORT MAP (
		clk => gCLK,
		rst=>gRST_PWM_COST,
		----------------------------
		cost_value_8bit => sig_pwm_up_cost_duty(7 downto 0),
		--cost_value_8bit =>  "00111110", --62
		pwm_period_8bit => sig_pwm_up_cost_length(7 downto 0),
		--pwm_period_8bit => "11111111", -- 255
		
		pwm_out => gRAMP_PWM_COST );
------------------------------------------------------		
pwm_down: test_pwm_down_2
	PORT MAP (
		clk => gCLK,
		rst=>gRST_PWM_DOWN,
		sync_out => gSYNC_PWM_DOWN,
		----------------------------
		cost_value_8bit => sig_pwm_down_end(7 downto 0),
		--cost_value_8bit =>  "00101101", -- 45
		pwm_period_8bit => sig_pwm_down_length(7 downto 0),
		--pwm_period_8bit => "01000000", -- 64
		duty_decrement_8bit => sig_pwm_down_increment(7 downto 0),
		--duty_decrement_8bit =>"00000001", --1
		
		pwm_out => gRAMP_PWM_DOWN );
------------------------------------------------------
pwm_down_cost : test_pwm_down_cost_2 
   PORT MAP (
		clk => gCLK,
		rst=>gRST_PWM_DOWN_COST,
		-----------------------------
		cost_value_8bit => sig_pwm_down_cost_duty(7 downto 0),
		--cost_value_8bit =>  "00101101", -- 45
		pwm_period_8bit => sig_pwm_down_cost_length(7 downto 0),
		--pwm_period_8bit => "01000000", -- 64 	
		   
		pwm_out => gRAMP_DC );

-----------------------------------------------------
--- CLKADC GENERATION  ------------------------------
-----------------------------------------------------
generate_clkadc : test_generate_convclock
	PORT MAP (
		clk => gCLK,
		rst => gRST_GENERATE_CLKADC_RESNBL,
		time_conversion_max_11bit => sig_time_conversion_max_11bit(10 downto 0),
--		time_conversion_max_11bit =>	"00100101100", -- 11 bit (2047, 20us)
		time_point_A_11bit => sig_time_point_A_11bit(10 downto 0),
--		time_point_A_11bit =>			"00001100100",
		time_point_B_11bit => sig_time_point_B_11bit(10 downto 0),
--		time_point_B_11bit =>			"00001100100",
		--three zone A, B, C
		conv_div_A_5bit => sig_conv_div_A_5bit(4 downto 0),
--		conv_div_A_5bit =>				"00011", --5 bit (max 31)
		conv_div_B_5bit => sig_conv_div_B_5bit(4 downto 0),
--		conv_div_B_5bit =>				"01010", --5 bit (max 31)
		conv_div_C_5bit => sig_conv_div_C_5bit(4 downto 0),
--		conv_div_C_5bit =>				"11111", --5 bit (max 31)
		convclk_out => gCLKADC
	);
with gCNT select 
		gCLKADC_out <= gCLKADC when '0',
							'0' when '1',
							'0' when others;
							
-----------------------------------------------------
--- RSNBL GENERATION  ------------------------------
-----------------------------------------------------
generate_rsnbl : test_wait_16bit
	PORT MAP (
		clk => gCLK,
		rst => gRST_GENERATE_CLKADC_RESNBL,
		start_value_16bit => sig_rsnbl_start_value, 
		stop_value_16bit => sig_rsnbl_stop_value, 
		sync_out => gRESNBL);	

gRSN_BL_out <=	gRESNBL;	
------------------------------------------------------
--- WAIT INTERVALS, INTER-PHASES ---------------------
------------------------------------------------------
prepare_integration : test_wait_2
	PORT MAP (
		clk => gCLK,
		rst=>gRST_PREPARE_INTEGRATION,
		wait_value_12bit =>clk_wait_prepare_integration(11 downto 0),
		--wait_value_12bit => "000011111010", -- 250@50MHz (5us)
		sync_out => gSYNC_PREPARE_INTEGRATION);
------------------------------------------------------
after_integration : test_wait_2
	PORT MAP (
		clk => gCLK,
		rst=>gRST_AFTER_INTEGRATION,
		wait_value_12bit =>clk_wait_finish_integration(11 downto 0),
		--wait_value_12bit => "000011111010", -- 250@50MHz (5us)
		sync_out => gSYNC_AFTER_INTEGRATION);
------------------------------------------------------
prepare_readout : test_wait_2
	PORT MAP (
		clk => gCLK,
		rst=>gRST_PREPARE_READOUT,
		wait_value_12bit => clk_wait_prepare_readout(11 downto 0), 
		--wait_value_12bit => "001111101000", -- 1000@50MHz (20us)
		sync_out => gSYNC_PREPARE_READOUT);
-------------------------------------------------------
reset_rn : test_wait_2
	PORT MAP (
		clk => gCLK,
		rst=>gRST_RESET_RN,
		--wait_value_12bit => clk_wait_prepare_readout(11 downto 0), 
		wait_value_12bit => "000011111010", -- 1000@50MHz (20us)
		sync_out => gSYNC_RESET_RN);
-------------------------------------------------------
finish_readout : test_wait_2
	PORT MAP (
		clk => gCLK,
		rst=>gRST_FINISH_READOUT,
		wait_value_12bit => clk_wait_finish_readout(11 downto 0),
		--wait_value_12bit => "000111110100", -- 500@50MHz (10us)
		sync_out => gSYNC_FINISH_READOUT);
-------------------------------------------------------
update_row : test_wait_2
	PORT MAP (
		clk => gCLK,
		rst=>gRST_UPDATE_ROW,
		wait_value_12bit =>clk_wait_update_row(11 downto 0),
		--wait_value_12bit => "000011111010", -- 250@50MHz (5us)
		sync_out => gSYNC_UPDATE_ROW);
-------------------------------------------------------
next_row_eof : test_wait_2
	PORT MAP (
		clk => gCLK,
		rst=>gRST_NEXT_ROW_EOF,
		wait_value_12bit =>clk_wait_next_row_eof(11 downto 0),
		--wait_value_12bit => "000011111010", -- 250@50MHz (5us)
		sync_out => gSYNC_NEXT_ROW_EOF);
-------------------------------------------------------
--DEBOUNCER:
-------------------------------------------------------
gBUTTON(0) <= not button(0);
gBUTTON(1) <= not button(1);
gBUTTON(2) <= not button(2);
gBUTTON(3) <= not button(3);

debouncer_push_button: grp_debouncer
PORT MAP (
		  clk_i => gCLK,                    -- system clock
        data_i=> gBUTTON,         -- noisy input data
        data_o => deb_button_neg                -- registered stable output data
        ---strb_o => led(0)
		 );

gRST_DB <= deb_button_neg(3);

--------------------------------------------------------
-- LED
--------------------------------------------------------
--led (7 downto 0)<= not sig_general_conf(7 downto 0);

led(0) <= not gS8B;
led(1) <= not gMASK;
led(2) <= not gMAXMIN;
led(3) <= not gS0;
led(4) <= not gS1;
led(5) <= not gCNT;
led(6) <= '1';
led(7) <= not gDATA_DOWNLOADING;
--------------------------------------------------------
-- OPALKELLY
--------------------------------------------------------
-- interface with memory
--clk and select:
gCLK_READ_RAM <=ti_clk; --clock of port B
gSELECT_RAM_BLOCK_TO_READ <= sig_gSELECT_RAM_BLOCK_TO_READ; --select one of the 12 ram blocks
--data:
sig_gPIPEO_DATA <= gPIPEO_DATA;
--debug_PIPEO_DATA <= gPIPEO_DATA_1;
sig_gPIPEO_DATA_1 <= gPIPEO_DATA_1; --data read from the memory block
sig_gPIPEO_DATA_2 <= gPIPEO_DATA_2; --data read from the memory block
sig_gPIPEO_DATA_3 <= gPIPEO_DATA_3; --data read from the memory block
sig_gPIPEO_DATA_4 <= gPIPEO_DATA_4; --data read from the memory block
sig_gPIPEO_DATA_5 <= gPIPEO_DATA_5; --data read from the memory block
sig_gPIPEO_DATA_6 <= gPIPEO_DATA_6; --data read from the memory block
gPIPEO_COUNT <= sig_gPIPEO_COUNT; --number of address read from the memory block
--info from the *writing interface*:
sig_gACTUAL_RAM_ADDRESS <= gACTUAL_RAM_ADDRESS; -- actual address in *writing*
sig_gACTUAL_RAM_BLOCK <= gACTUAL_RAM_BLOCK; -- actual block in *writing*
-- reading procedure 
	process (ti_clk) begin
		if rising_edge(ti_clk) then
			if (count_reset = '1') then
				sig_gPIPEO_COUNT <= x"00000000";
			else
				if ((trig_ram0read = '1') or (sig_gPIPEO_READ = '1')) then
					sig_gPIPEO_COUNT <= sig_gPIPEO_COUNT + "1";
				end if;
			end if;
		end if;
	end process;	
---- Instantiate the okHost and connect endpoints.
okHI : okHost port map (hi_in=>hi_in, hi_out=>hi_out, hi_inout=>hi_inout,
			 ti_clk=>ti_clk, ok1=>ok1, ok2=>ok2);
okWO : okWireOR    generic map (N=>18) port map (ok2=>ok2, ok2s=>ok2s);
--the signals attached to the wait
ep00 : okWireIn    port map (ok1=>ok1, ep_addr=> x"00",ep_dataout => clk_wait_prepare_readout);
ep01 : okWireIn    port map (ok1=>ok1, ep_addr=> x"01",ep_dataout => clk_wait_finish_readout); 
ep02 : okWireIn    port map (ok1=>ok1, ep_addr=> x"02",ep_dataout => clk_wait_prepare_integration);
ep03 : okWireIn    port map (ok1=>ok1, ep_addr=> x"03",ep_dataout => clk_wait_finish_integration); 
ep04 : okWireIn    port map (ok1=>ok1, ep_addr=> x"04",ep_dataout => clk_wait_update_row); 
ep05 : okWireIn    port map (ok1=>ok1, ep_addr=> x"05",ep_dataout => clk_wait_next_row_eof);
--pwm control 
ep06 : okWireIn    port map (ok1=>ok1, ep_addr=> x"06",ep_dataout => sig_pwm_down_cost_duty);
ep07 : okWireIn    port map (ok1=>ok1, ep_addr=> x"07",ep_dataout => sig_pwm_down_cost_length);
ep08 : okWireIn    port map (ok1=>ok1, ep_addr=> x"08",ep_dataout => sig_pwm_down_end);
ep09 : okWireIn    port map (ok1=>ok1, ep_addr=> x"09",ep_dataout => sig_pwm_down_length);
ep0a : okWireIn    port map (ok1=>ok1, ep_addr=> x"0a",ep_dataout => sig_pwm_down_increment);
ep0b : okWireIn    port map (ok1=>ok1, ep_addr=> x"0b",ep_dataout => sig_pwm_up_cost_duty);
ep0c : okWireIn    port map (ok1=>ok1, ep_addr=> x"0c",ep_dataout => sig_pwm_up_cost_length);
ep0d : okWireIn    port map (ok1=>ok1, ep_addr=> x"0d",ep_dataout => sig_pwm_up_end);
ep0e : okWireIn    port map (ok1=>ok1, ep_addr=> x"0e",ep_dataout => sig_pwm_up_length);
ep0f : okWireIn    port map (ok1=>ok1, ep_addr=> x"0f",ep_dataout => sig_pwm_up_increment);
--general conf (S8B, MaxMin, ...)
ep10 : okWireIn    port map (ok1=>ok1, ep_addr=> x"10",ep_dataout => sig_general_conf);
--- clkadc conf
ep12 : okWireIn    port map (ok1=>ok1, ep_addr=> x"12",ep_dataout => sig_time_conversion_max_11bit);
ep13 : okWireIn    port map (ok1=>ok1, ep_addr=> x"13",ep_dataout => sig_time_point_A_11bit);
ep14 : okWireIn    port map (ok1=>ok1, ep_addr=> x"14",ep_dataout => sig_time_point_B_11bit);
ep15 : okWireIn    port map (ok1=>ok1, ep_addr=> x"15",ep_dataout => sig_conv_div_A_5bit);
ep16 : okWireIn    port map (ok1=>ok1, ep_addr=> x"16",ep_dataout => sig_conv_div_B_5bit);
ep17 : okWireIn    port map (ok1=>ok1, ep_addr=> x"17",ep_dataout => sig_conv_div_C_5bit);
-- rsNBL
ep18: okWireIn    port map (ok1=>ok1, ep_addr=> x"18",ep_dataout => sig_rsnbl_start_value); 
ep19: okWireIn    port map (ok1=>ok1, ep_addr=> x"19",ep_dataout => sig_rsnbl_stop_value); 
-- interface with memory
ep11 : okWireIn    port map (ok1=>ok1, ep_addr=> x"11",ep_dataout => sig_gSELECT_RAM_BLOCK_TO_READ);

epA1 : okPipeOut   port map (ok1=>ok1,ok2=>ok2s(18*17-1 downto 17*17 ),ep_addr=>x"A1", ep_read=>sig_gPIPEO_READ,ep_datain=>sig_gPIPEO_DATA);
--epA1 : okPipeOut   port map (ok1=>ok1,ok2=>ok2s(18*17-1 downto 17*17 ),ep_addr=>x"A1", ep_read=>sig_gPIPEO_READ_1,ep_datain=>sig_gPIPEO_DATA_1);
--epA2 : okPipeOut   port map (ok1=>ok1,ok2=>ok2s(17*17-1 downto 16*17 ),ep_addr=>x"A2", ep_read=>sig_gPIPEO_READ_2,ep_datain=>sig_gPIPEO_DATA_2);
--epA3 : okPipeOut   port map (ok1=>ok1,ok2=>ok2s(16*17-1 downto 15*17 ),ep_addr=>x"A3", ep_read=>sig_gPIPEO_READ_3,ep_datain=>sig_gPIPEO_DATA_3);
--epA4 : okPipeOut   port map (ok1=>ok1,ok2=>ok2s(15*17-1 downto 14*17 ),ep_addr=>x"A4", ep_read=>sig_gPIPEO_READ_4,ep_datain=>sig_gPIPEO_DATA_4);
--epA5 : okPipeOut   port map (ok1=>ok1,ok2=>ok2s(14*17-1 downto 13*17 ),ep_addr=>x"A5", ep_read=>sig_gPIPEO_READ_5,ep_datain=>sig_gPIPEO_DATA_5);
--epA6 : okPipeOut   port map (ok1=>ok1,ok2=>ok2s(13*17-1 downto 12*17 ),ep_addr=>x"A6", ep_read=>sig_gPIPEO_READ_6,ep_datain=>sig_gPIPEO_DATA_6);

ep2c : okWireOut   port map (ok1=>ok1, ok2=>ok2s(9*17-1 downto 8*17 ), ep_addr=>x"2c", ep_datain=>sig_gPIPEO_COUNT(15 downto 0));
ep2d : okWireOut   port map (ok1=>ok1, ok2=>ok2s(10*17-1 downto 9*17 ), ep_addr=>x"2d", ep_datain=>sig_gPIPEO_COUNT(31 downto 16));

ep2a : okWireOut   port map (ok1=>ok1, ok2=>ok2s(11*17-1 downto 10*17 ), ep_addr=>x"2a", ep_datain=>sig_gACTUAL_RAM_ADDRESS);
ep2b : okWireOut   port map (ok1=>ok1, ok2=>ok2s(12*17-1 downto 11*17 ), ep_addr=>x"2b", ep_datain=>sig_gACTUAL_RAM_BLOCK);

ep40 : okTriggerIn port map (ok1=>ok1,ep_addr=>x"40",ep_clk=>ti_clk, ep_trigger=>ep40trig);
end Behavioral;

