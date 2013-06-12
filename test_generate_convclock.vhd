----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:49:54 09/27/2012 
-- Design Name: 
-- Module Name:    test_generate_convclock - Behavioral 
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

entity test_generate_convclock is
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
end test_generate_convclock;

architecture Behavioral of test_generate_convclock is

type state is ( A,B,C) ;
signal pr_state ,nx_state : state;
signal time_conversion_max : integer range 0 to N := 300;
signal time_point_A : integer range 0 to N := 100;
signal time_point_B : integer range 0 to N := 100;
signal time_wait: integer range 0 to N := 100; 

signal conv_div_A : integer range 0 to M := 10;
signal conv_div_B : integer range 0 to M := 20;
signal conv_div_C : integer range 0 to M := 30;
signal conv_div : integer range 0 to M := 10;

signal convclk : std_logic := '1';
signal max_time_reached : std_logic := '0';

begin

check_time: process(clk) is
		variable watch : integer range 0 to N;
	begin
	if (clk'EVENT AND clk='1') then
		if (rst='1') THEN
			watch:=0;
			max_time_reached <= '0';
			time_conversion_max <= conv_integer(unsigned(time_conversion_max_11bit));
		else	
			watch := watch + 1;
			if (watch = time_conversion_max) then 
				max_time_reached <= '1';
			end if; 
		end if;
	end if;
end process check_time;

with max_time_reached select
	convclk_out <= convclk when '0',
						'0' when '1',
						'0' when others;


clk_div: process(clk) is
	--generate convclk
		variable div : integer range 0 to M;
	begin
	if (clk'EVENT AND clk='1') then
		if (rst='1') THEN
			div:=0;
			conv_div_A <= conv_integer(unsigned(conv_div_A_5bit));
			conv_div_B <= conv_integer(unsigned(conv_div_B_5bit));
			conv_div_C <= conv_integer(unsigned(conv_div_C_5bit));
		else
			if (conv_div > 0) then
				div := div + 1;
				if (div = conv_div) then
					div := 0;
					convclk <= not convclk;
				end if;
			else
				convclk <= '0';
			end if;
		end if;
	end if;
end process clk_div;


fsm_seq: process(clk) is
		variable count : integer range 0 to N;
	begin
	if (clk'EVENT AND clk='1') then
		if (rst='1') THEN
			count:=0;
			pr_state <= A ;
			time_point_A<= conv_integer(unsigned(time_point_A_11bit));
			time_point_B<= conv_integer(unsigned(time_point_B_11bit));
		else
			count:= count+1;
			if (count = time_wait) then
				pr_state <= nx_state;
				count:=0;
			end if;	
		end if;
	end if;
end process fsm_seq;

fsm_comb: process(pr_state) is
	begin
	case pr_state is
			when A=>
				time_wait <= time_point_A;
				conv_div <= conv_div_A;
				nx_state <= B;
			when B=>
				time_wait <= time_point_B;
				conv_div <= conv_div_B;
				nx_state <= C;
			when C=>
				conv_div <= conv_div_C;
				nx_state <= A;
			when others =>
				conv_div <= conv_div_A;
				nx_state <= A;
	end case;	
				
end process fsm_comb;	

end Behavioral;
