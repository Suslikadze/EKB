library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
----------------------------------------------------------------------
-- модуль генерации видеосигнала от фотоприемника после сериализатора
----------------------------------------------------------------------
entity IS_SIM_serial_DDR is
generic  (bit_data	: integer);
port (
		--входные сигналы--	
	CLK_fast				: in std_logic;  												-- тактовый 
	MAIN_reset			: in std_logic;  												-- MAIN_reset
	MAIN_ENABLE			: in std_logic;  												-- MAIN_ENABLE
	DATA_IMX_OUT		: in std_logic_vector (bit_data_imx-1 downto 0);	-- входной сигнал
		--выходные сигналы--	
	IMX_DDR_VIDEO		: out std_logic												-- выходной сигнал
		);
end IS_SIM_serial_DDR;

architecture beh of IS_SIM_serial_DDR is 
----------------------------------------------------------------------
---DDR reg ProASIC Microsemi
----------------------------------------------------------------------
component DDR_OUT
port( DR  : in    std_logic := 'U';
		DF  : in    std_logic := 'U';
		CLK : in    std_logic := 'U';
		CLR : in    std_logic := 'U';
		Q   : out   std_logic
	);
end component;
----------------------------------------------------------------------
signal IMX_DDR_VIDEO_in_r	: std_logic;
signal IMX_DDR_VIDEO_in_f	: std_logic;
signal load_ddr_video_imx	: std_logic;
signal ena_CLK_fast			: std_logic;
signal DATA_IMX_OUT_r		: std_logic_vector (bit_data / 2 - 1 downto 0);
signal DATA_IMX_OUT_f		: std_logic_vector (bit_data / 2 - 1 downto 0);
----------------------------------------------------------------------
begin
----------------------------------------------------------------------
---разделение входного слова на четные и нечетные биты в зависимости от разрядности
----------------------------------------------------------------------
Process(CLK_fast)
begin
if rising_edge(CLK_fast) then
	case  bit_data	is
		when 8	=>	
			DATA_IMX_OUT_r	<=DATA_IMX_OUT(6) 	& DATA_IMX_OUT(4) & DATA_IMX_OUT(2) & DATA_IMX_OUT(0);
			DATA_IMX_OUT_f	<=DATA_IMX_OUT(7) 	& DATA_IMX_OUT(5) & DATA_IMX_OUT(3) & DATA_IMX_OUT(1);
		when 10	=>	
			DATA_IMX_OUT_r	<=DATA_IMX_OUT(8) 	& DATA_IMX_OUT(6) & DATA_IMX_OUT(4) & DATA_IMX_OUT(2) & DATA_IMX_OUT(0);
			DATA_IMX_OUT_f	<=DATA_IMX_OUT(9) 	& DATA_IMX_OUT(7) & DATA_IMX_OUT(5) & DATA_IMX_OUT(3) & DATA_IMX_OUT(1);
		when 12	=>	
			DATA_IMX_OUT_r	<=DATA_IMX_OUT(10) 	& DATA_IMX_OUT(8) & DATA_IMX_OUT(6) & DATA_IMX_OUT(4) & DATA_IMX_OUT(2) & DATA_IMX_OUT(0);
			DATA_IMX_OUT_f	<=DATA_IMX_OUT(11) 	& DATA_IMX_OUT(9) & DATA_IMX_OUT(7) & DATA_IMX_OUT(5) & DATA_IMX_OUT(3) & DATA_IMX_OUT(1);
		WHEN others	=>	
			DATA_IMX_OUT_r	<=DATA_IMX_OUT(6) 	& DATA_IMX_OUT(4) & DATA_IMX_OUT(2) & DATA_IMX_OUT(0);
			DATA_IMX_OUT_f	<=DATA_IMX_OUT(7) 	& DATA_IMX_OUT(5) & DATA_IMX_OUT(3) & DATA_IMX_OUT(1);
		END case;	
	end if;
end process;
----------------------------------------------------------------------
---преобразование паралелльного кода в последовательный для четного/нечетного слова
----------------------------------------------------------------------
ena_CLK_fast	<= MAIN_ENABLE;
load_ddr_video_imx_q0: count_n_modul                   
generic map (4) 
port map (
	clk		=>	CLK_fast,	
	reset		=>	MAIN_reset ,
	en			=>	ena_CLK_fast,
	modul		=>	std_logic_vector(to_unsigned(bit_data /2 , 4)) ,
	cout		=>	load_ddr_video_imx);	

parall_to_serial_imx0: parall_to_serial                    
generic map (bit_data / 2) 
port map (
	dir		=>	'0',		
	ena		=>	ena_CLK_fast,
	clk		=>	CLK_fast,			
	data		=>	DATA_IMX_OUT_r ,
	load		=>	load_ddr_video_imx,		
	shiftout	=>	IMX_DDR_VIDEO_in_r );

parall_to_serial_imx1: parall_to_serial                    
generic map (bit_data / 2) 
port map (
	dir		=>	'0',		
	ena		=>	ena_CLK_fast,
	clk		=>	CLK_fast,			
	data		=>	DATA_IMX_OUT_f ,
	load		=>	load_ddr_video_imx,		
	shiftout	=>	IMX_DDR_VIDEO_in_f );
----------------------------------------------------------------------
---DDR в зависимости от типа ПЛИС
----------------------------------------------------------------------
DDR_OUT0: DDR_OUT            --DDR модуль PROASIC3        
port map (
	DR 		=>	IMX_DDR_VIDEO_in_r,		
	DF 		=>	IMX_DDR_VIDEO_in_f,
	CLK		=>	CLK_fast,			
	CLR		=>	'0' ,
	Q  		=>	IMX_DDR_VIDEO	);

end ;
