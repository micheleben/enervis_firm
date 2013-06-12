--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package enervis_package_S6 is

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--



COMPONENT test_fsm IS
	  
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
			CNT: out  std_logic;
			DATA_DOWNLOADING: out std_logic;
			MAXMIN: out std_logic
			);
	END COMPONENT;
--------------------------------------------------
	COMPONENT dFF_2 is
	
   Port ( d : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  clk_sh : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           q : out  STD_LOGIC
			  );
	end COMPONENT;	
--------------------------------------------------------
	COMPONENT test_serial_receiver_4 IS
	   Generic (
			N : positive := 16  --  serial word length 
		);
		PORT (
			clk: IN std_logic;
			rst: IN std_logic;
			sync_out : OUT std_logic;
			------------------------------
			din: IN std_logic;
			clk_sh : OUT std_logic;
			data: OUT std_logic_vector (N-1 DOWNTO 0)
			);
	END COMPONENT;	
-----------------------------------------------------	
	COMPONENT counter_fsm52_2 is
	port 
	(
		clk		: in std_logic;
		rst	   : in std_logic;
		sync_out : out std_logic;
		---------------------------
		event_to_count : in std_logic;
		rst_each_event : in std_logic;
		rst_event_generation : out std_logic;
		actual_value : out std_logic_vector(15 downto 0)	
	);
	END COMPONENT;	
-----------------------------------------------------	
	
	COMPONENT counter_fsm7_2 is
	port 
	(
		clk		: in std_logic;
		rst	   : in std_logic;
		sync_out : out std_logic;
		---------------------------
		event_to_count : in std_logic;
		rst_each_event : in std_logic;
		rst_event_generation : out std_logic;
		actual_value : out std_logic_vector(15 downto 0)	
	);
	END COMPONENT;	
-----------------------------------------------------	
	COMPONENT counter_fsm104_2 is
	port 
	(
		clk		: in std_logic;
		rst	   : in std_logic;
		sync_out : out std_logic;
		---------------------------
		event_to_count : in std_logic;
		rst_each_event : in std_logic;
		rst_event_generation : out std_logic;
		actual_value : out std_logic_vector(15 downto 0)	
	);
	END COMPONENT;	
--------------------------------------------------------
	
	COMPONENT test_memory_controller_2 is
	port
	(
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
		--------------------
		s8b : in std_logic;
		
		clk_read_ram: in std_logic;
		pipeO_data : out std_logic_vector (15 downto 0);
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
	END COMPONENT;
-----------------------------------------------------	
	COMPONENT counter_fsm1024_2 is
	port 
	(
		clk		: in std_logic;
		rst	   : in std_logic;
		sync_out : out std_logic;
		---------------------------
		event_to_count : in std_logic;
		rst_each_event : in std_logic;
		rst_event_generation : out std_logic;
		actual_value : out std_logic_vector(15 downto 0)	
	);
	END COMPONENT;	
-----------------------------------------------------	
	COMPONENT counter_fsm728_2 is
	port 
	(
		clk		: in std_logic;
		rst	   : in std_logic;
		sync_out : out std_logic;
		---------------------------
		event_to_count : in std_logic;
		rst_each_event : in std_logic;
		rst_event_generation : out std_logic;
		actual_value : out std_logic_vector(15 downto 0)	
	);
	END COMPONENT;	
-----------------------------------------------------	
	COMPONENT counter_fsm288_2 is
	port 
	(
		clk		: in std_logic;
		rst	   : in std_logic;
		sync_out : out std_logic;
		---------------------------
		event_to_count : in std_logic;
		rst_each_event : in std_logic;
		rst_event_generation : out std_logic;
		actual_value : out std_logic_vector(15 downto 0)	
	);
	END COMPONENT;	
-----------------------------------------------------	
	COMPONENT test_pwm is
	port 
	(
		clk		: in std_logic;
		rst	   : in std_logic;
		sync_out : out std_logic;
		----------------------------
		cost_value_12bit : in std_logic_vector (11 downto 0);
		pwm_period_12bit : in std_logic_vector (11 downto 0);
		duty_increment_12bit : in std_logic_vector (11 downto 0);
		----------------------------
		pwm_out	: out std_logic
	);
	END COMPONENT;
-----------------------------------------------------
COMPONENT test_pwm_cost_2 is
	port 
		(
		clk		: in std_logic;
		rst		: in std_logic;
		----------------------------
		cost_value_8bit : in std_logic_vector (7 downto 0);
		pwm_period_8bit : in std_logic_vector (7 downto 0);
		----------------------------
		pwm_out	: out std_logic
	);
	END COMPONENT;	
----------------------------------------------------
COMPONENT test_pwm_down_cost_2 is
	port 
	(
		clk		: in std_logic;
		rst		: in std_logic;
		cost_value_8bit : in std_logic_vector (7 downto 0);
		pwm_period_8bit : in std_logic_vector (7 downto 0);
		-------------------------
		pwm_out	: out std_logic
	);
	END COMPONENT;	
-----------------------------------------------------
COMPONENT test_pwm_down_2 is
	port 
	(
		clk		: in std_logic;
		rst	   : in std_logic;
		sync_out : out std_logic;
		----------------------------
		cost_value_8bit : in std_logic_vector (7 downto 0);
		pwm_period_8bit : in std_logic_vector (7 downto 0);
		duty_decrement_8bit : in std_logic_vector (7 downto 0);
		----------------------------
	
		pwm_out	: out std_logic
	);
	END COMPONENT;	
	
	
----------------------------------------------------
COMPONENT test_generate_convclock is
	Generic (
		N : positive := 2047;  --  2^11 = 2048
		M : positive := 31
	);	
	port 
	(
		clk		: in std_logic;
		rst		: in std_logic;
		time_conversion_max_11bit : in std_logic_vector (10 downto 0); -- 11 bit (2047, 20us)
		time_point_A_11bit : in std_logic_vector (10 downto 0);
		time_point_B_11bit : in std_logic_vector (10 downto 0);
		--three zone A, B, C
		conv_div_A_5bit : in std_logic_vector (4 downto 0); --5 bit (max 31)
		conv_div_B_5bit : in std_logic_vector (4 downto 0); --5 bit (max 31)
		conv_div_C_5bit : in std_logic_vector (4 downto 0); --5 bit (max 31)
		convclk_out : out std_logic
		);
	END COMPONENT;	
-----------------------------------------------------

	COMPONENT test_wait_16bit is

	port 
		(
			clk		: in std_logic;
			rst		: in std_logic;
			start_value_16bit : in std_logic_vector (15 downto 0);
			stop_value_16bit : in std_logic_vector (15 downto 0);
			sync_out : out std_logic
		);
	END COMPONENT;	
-------------------------------------------------------	
	COMPONENT test_wait_2 is
	port 
	(
		clk		: in std_logic;
		rst	   : in std_logic;
		wait_value_12bit : in std_logic_vector (11 downto 0);
		sync_out : out std_logic
	);
	END COMPONENT;	
--------------------------------------------------------

	COMPONENT grp_debouncer is
	Generic (   
		  N : positive := 4;                                                      -- input bus width
		  CNT_VAL : positive := 10000);                                           -- clock counts for debounce period
	Port (  
		  clk_i : in std_logic := 'X';                                            -- system clock
		  data_i : in std_logic_vector (N-1 downto 0) := (others => 'X');         -- noisy input data
		  data_o : out std_logic_vector (N-1 downto 0);                           -- registered stable output data
		  strb_o : out std_logic                                                  -- strobe for new data available
	 );                      
	END COMPONENT;
--------------------------------------------------------
	
end enervis_package_S6;

package body enervis_package_S6 is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>; 
end enervis_package_S6;
