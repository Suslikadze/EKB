library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;

entity IS_SIM_serial_DDR is
------------------------------------модуль управления ФП-----------------------------------------------------
port (
------------------------------------входные сигналы-----------------------------------------------------
	CLK_fast			: in std_logic;  								-- тактовый 
	MAIN_reset			: in std_logic;  								-- MAIN_reset
	MAIN_ENABLE			: in std_logic;  								-- MAIN_ENABLE
	mode_IMAGE_SENSOR	: in std_logic_vector (7 downto 0):=x"00";		-- изменение режимов
	DATA_IMX_OUT		: in std_logic_vector (bit_data_CSI-1 downto 0);		-- выходной сигнал

------------------------------------выходные сигналы-----------------------------------------------------
	IMX_DDR_VIDEO		: out std_logic; 								-- синхронизация
	IMX_DDR_CLK_4		: out std_logic; 								-- синхронизация
	IMX_DDR_CLK			: out std_logic 								-- синхронизация
		);
end IS_SIM_serial_DDR;

architecture beh of IS_SIM_serial_DDR is 

----------------------------------счетчик -----------------------
component count_n_modul
generic (n		: integer);
port (
		clk,
		reset,
		en			:	in std_logic;
		modul		: 	in std_logic_vector (n-1 downto 0);
		qout		: 	out std_logic_vector (n-1 downto 0);
		cout		:	out std_logic);
end component;

signal IMX_DDR_VIDEO_in		: std_logic;
signal IMX_DDR_CLK_in		: std_logic;

-------------------------------------------------------------------------------
component parall_to_serial is
generic (	bit_data		: integer :=8);			--bit na stroki
port(
dir        : in STD_LOGIC;
ena        : in STD_LOGIC;
	clk        : in STD_LOGIC;
	data       : in STD_LOGIC_VECTOR(bit_data_CSI-1 downto 0);
	load       : in STD_LOGIC;
	shiftout   : out STD_LOGIC
	);
end component;
signal load_ddr_video_imx	: std_logic;
signal q_load_ddr_video_imx	: std_logic_vector (7 downto 0);
-------------------------------------------------------------------------------
signal ena_CLK_fast	: std_logic;
signal ena_CLK_fast_x2_in	: std_logic;
signal ena_CLK_fast_x4_in	: std_logic;
signal ena_CLK_fast_x8_in	: std_logic;
signal ena_CLK_fast_x16_in	: std_logic;
signal div_CLK_fast_in	: std_logic_vector (7 downto 0);
signal IMX_DDR_VIDEO_in_b	: std_logic_vector (3 downto 0);


begin

------------------------------------------------------------------------------
----------------------------------DDR interface-------------------------------
------------------------------------------------------------------------------
ena_CLK_fast	<= '1';
------------------------------------счетчик тактов для формирования сигналов разрешения-----------------------------------------------------
div_CLK_fast_q: count_n_modul                    
generic map (8) 
port map (
			clk			=>	CLK_fast,			
			reset		=>	MAIN_reset ,
			en			=>	MAIN_ENABLE,		
			modul		=> 	std_logic_vector(to_unsigned(256,8)) ,
			qout		=>	div_CLK_fast_in);
			
Process(CLK_fast)
begin
if rising_edge(CLK_fast) then
---------------------------------------clk в 2 раза меньше---------------------------------------
	if div_CLK_fast_in( 0)='0' 			
		then 	 ena_CLK_fast_x2_in<='1';
		else 	 ena_CLK_fast_x2_in<='0';
	end if;
---------------------------------------clk в 4 раза меньше---------------------------------------
	if div_CLK_fast_in(1 downto 0)="00"		
		then 	ena_CLK_fast_x4_in<='1';
		else  	ena_CLK_fast_x4_in<='0';
	end if;
---------------------------------------clk в 8 раза меньше---------------------------------------
	if div_CLK_fast_in(2 downto 0)="000"		
		then 	ena_CLK_fast_x8_in<='1';
		else	ena_CLK_fast_x8_in<='0';
	end if;
---------------------------------------clk в 16 раза меньше---------------------------------------
	if div_CLK_fast_in(3 downto 0)="0000"		
		then	ena_CLK_fast_x16_in<='1';
		else	ena_CLK_fast_x16_in<='0';
	end if;
end if;
end process;		
----------------------------------------------------------------------------------------------------

------------------------------------load_ddr_video_imx------------------------
load_ddr_video_imx_q: count_n_modul                   
generic map (8) 
port map (
			clk			=>	CLK_fast,	
			reset		=>	MAIN_reset ,
			en			=>	ena_CLK_fast,
			modul		=>	std_logic_vector(to_unsigned(bit_data_CSI,8)) ,
			qout		=>	q_load_ddr_video_imx,	
			cout		=>	load_ddr_video_imx);	

parall_to_serial_imx: parall_to_serial                    
generic map (bit_data_CSI) 
port map (
			dir			=>	'0',		
			ena			=>	ena_CLK_fast,
			clk			=>	CLK_fast,			
			data		=>	DATA_IMX_OUT ,
			load		=>	load_ddr_video_imx,		
			shiftout	=> 	IMX_DDR_VIDEO_in );

----------------------------------------------------------------------------------------------------
IMX_DDR_VIDEO <=IMX_DDR_VIDEO_in;

Process(CLK_fast)
begin
if falling_edge(CLK_fast) then
	IMX_DDR_CLK		<=    q_load_ddr_video_imx(0);
	IMX_DDR_CLK_4	<=    q_load_ddr_video_imx(2);
end if;
end process;

end ;
