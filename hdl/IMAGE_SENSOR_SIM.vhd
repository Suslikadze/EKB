library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
---------------------------------------------------------------
-- модель симцуляции цотоприемника
-- выходной сигнал в 3 вариантах паралелльный код / LVDS (1-2-4 линии) / CSI (1 линия)
-- в зависимости от mode_IMAGE_SENSOR (use work.VIDEO_CONSTANTS.all ) можно изменять режим симуляции
-- mode_IMAGE_SENSOR (3 downto 0) = 0 CSI - 1 линия
-- mode_IMAGE_SENSOR (3 downto 0) = 1 LVDS - 1 линия
-- mode_IMAGE_SENSOR (3 downto 0) = 2 LVDS - 2 линия
-- mode_IMAGE_SENSOR (3 downto 0) = 3 LVDS - 4 линия
-- разрядность данный определяется bit_data_imx 12 / 10 / 8 bit

-- mode_IMAGE_SENSOR (7 downto 4) = 0 B/W
-- mode_IMAGE_SENSOR (7 downto 4) = 1 COLOR

-- mode_generator определяет тип данных для передачи
-- младшие 4 бита отвечаю за тип сигнала, старшие за кастомизацию
-- 	[7..4]						[3..0]
-- 	сдвиг разрядов				0 градационный клин по горизонтали
-- 	сдвиг разрядов				1 градационный клин по вертикали
-- 	none							2 шумоподобный сигнал на основе полинома SMPTE
-- 	размер клеток				3 шахматное поле
-- 	интенсиыность полос		4 цветные полосы (color bar)
-- 	none							5 сигнал из файла
--------------------------------------------------------------
--------------------------------------------------------------
-- модель PLL для симуляции фотоприемника
-- для 2200х1250 50p пиксельаня частота (PixFreq)  137.5 МГц
-- для 2200х1125 30p пиксельаня частота (PixFreq)  74.25 МГц
-- для пиксельной частоты > 74.25 Мгц нельзя использвать CSI-2/ LVDS по 1 линии
--       mode                        SerFreq
-- CSI      8 bit       PixFreq*4      = 297 МГц
-- LVDS_1ch 8 bit       PixFreq*4      = 297 МГц
-- LVDS_1ch 10 bit      PixFreq*5      = 371.25 МГц
-- LVDS_1ch 12 bit      PixFreq*6      = 445.5 МГц
-- LVDS_2ch 8 bit       PixFreq*4 /2   = 148.5 МГц
-- LVDS_2ch 10 bit      PixFreq*5 /2   = 185.625 МГц
-- LVDS_2ch 12 bit      PixFreq*6 /2   = 222.75 МГц
-- LVDS_4ch 8 bit       PixFreq*4 /4   = 74.25 МГц
-- LVDS_4ch 10 bit      PixFreq*5 /4   = 92.8125 МГц
-- LVDS_4ch 12 bit      PixFreq*6 /4   = 111.375 МГц
--------------------------------------------------------------

entity IMAGE_SENSOR_SIM is
port (
		--входные сигналы--	
	CLK					: in std_logic;  												-- тактовый 
	mode_generator		: in std_logic_vector (7 downto 0);						-- задание генератора
		--выходные сигналы--	
	XVS_Imx_Sim			: out std_logic; 												-- синхронизация
	XHS_Imx_Sim			: out std_logic; 												-- синхронизация
	DATA_IS_PAR			: out	std_logic_vector (bit_data_imx-1 downto 0);	-- выходной сигнал
	DATA_IS_LVDS_ch_1	: out	std_logic; 												-- выходной сигнал в канале 1
	DATA_IS_LVDS_ch_2	: out	std_logic; 												-- выходной сигнал в канале 2
	DATA_IS_LVDS_ch_3	: out	std_logic; 												-- выходной сигнал в канале 3
	DATA_IS_LVDS_ch_4	: out	std_logic; 												-- выходной сигнал в канале 4
	DATA_IS_CSI			: out	std_logic; 												-- выходной сигнал CSI
	CLK_DDR				: out std_logic		
		);
end IMAGE_SENSOR_SIM;

architecture beh of IMAGE_SENSOR_SIM is 

----------------------------------------------------------------------
-- PLL_SIM_IS entity declaration
----------------------------------------------------------------------
component PLL_SIM_IS is
port( POWERDOWN : in    std_logic;
		CLKA      : in    std_logic;
		LOCK      : out   std_logic;
		GLA       : out   std_logic
		);
end component;
----------------------------------------------------------------------
-- PLL_SIM_IS entity declaration
----------------------------------------------------------------------
component PLL_SIM_IS_1 is
	port( POWERDOWN : in    std_logic;
			CLKA      : in    std_logic;
			LOCK      : out   std_logic;
			GLA       : out   std_logic
			);
	end component;
	
	signal PLL_POWERDOWN_N	: std_logic;			
	signal CLK_IS_pix			: std_logic;			
	signal CLK_IS_DDR			: std_logic;			
	signal locked_pll_0		: std_logic;
	signal locked_pll_1		: std_logic;
	signal MAIN_ENABLE		: std_logic;
	signal MAIN_reset			: std_logic;
	signal locked_pll_q		: std_logic_vector(31 downto 0);
	
----------------------------------------------------------------------

----------------------------------------------------------------------
-- модуль генерации видеосигнала от фотоприемника в паралелльном коде
----------------------------------------------------------------------
component IS_SIM_Paralell is
port (
		--входные сигналы--	
	CLK					: in std_logic;  												-- тактовый 
	MAIN_reset			: in std_logic;  												-- MAIN_reset
	MAIN_ENABLE			: in std_logic;  												-- MAIN_ENABLE
	mode_generator		: in std_logic_vector (7 downto 0);						--задание режима
		--выходные сигналы--	
	qout_V_out			: out std_logic_vector (bit_strok-1 downto 0);		-- 
	qout_clk_out		: out std_logic_vector (bit_pix-1 downto 0 );		-- 
	XVS_Imx_Sim			: out std_logic; 												-- синхронизация
	XHS_Imx_Sim			: out std_logic; 												-- синхронизация
	DATA_IS_pix			: out  std_logic_vector (bit_data_imx-1 downto 0)	-- выходной сигнал
		);
end component;

signal qout_clk_IS		: std_logic_vector (bit_pix-1 downto 0);
signal qout_V_IS			: std_logic_vector (bit_strok-1 downto 0);
signal DATA_IS_pix		: std_logic_vector (bit_data_imx-1 downto 0);
--------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------
-- component IS_SIM_serial_DDR is
-- ------------------------------------модуль управления ФП---------------------------
-- port (
-- ------------------------------------входные сигналы--------------------------------
-- 	CLK_fast			: in std_logic;  								-- тактовый 
-- 	MAIN_reset			: in std_logic;  								-- MAIN_reset
-- 	MAIN_ENABLE			: in std_logic;  								-- MAIN_ENABLE
-- 	mode_IMAGE_SENSOR	: in std_logic_vector (7 downto 0):=x"00";		-- изменение режимов
-- 	DATA_IMX_OUT		: in std_logic_vector (bit_data_CSI-1 downto 0);		-- выходной сигнал

-- ------------------------------------выходные сигналы--------------------------------
-- 	IMX_DDR_VIDEO		: out std_logic; 								-- синхронизация
-- 	IMX_DDR_CLK_4		: out std_logic; 								-- синхронизация
-- 	IMX_DDR_CLK			: out std_logic 								-- синхронизация
-- 		);
-- end component;
-- ------------------------------------------------------------------------------------


begin

PLL_POWERDOWN_N	<=	'1';
PLL_SIM_IS_q0: PLL_SIM_IS                   
port map (
	-- Inputs
	POWERDOWN	=> PLL_POWERDOWN_N,
	CLKA			=> CLK,				--74.25 МГц
	-- Outputs 
	GLA			=> CLK_IS_pix,		--137.5 МГц
	LOCK			=> locked_pll_0
);	
PLL_SIM_IS_q1: PLL_SIM_IS_1                   
port map (
	-- Inputs
	POWERDOWN	=> PLL_POWERDOWN_N,
	CLKA			=> CLK,				--74.25 МГц
	-- Outputs 
	GLA			=> CLK_IS_DDR, 	--206.25 МГц	// в режиме LVDS 4 ch 12 bit
	LOCK			=> locked_pll_1
);	

process (CLK)
begin
if  rising_edge(CLK) then
	locked_pll_q(0) <= locked_pll_0 or locked_pll_1;
	for i in 0 to 30 loop
		locked_pll_q(i+1) <= locked_pll_q(i);
	end loop;
	MAIN_reset	<=	not 	locked_pll_q(31);
	MAIN_ENABLE	<=	locked_pll_q(31);
end if;
end process;

------------------------------------симулятор паралелльных данных----------------------------------------------------
IS_SIM_Paralell_q: IS_SIM_Paralell                   
port map (
						------входные сигналы-----------
			CLK					=>	CLK_IS_pix,			
			MAIN_reset			=>	MAIN_reset ,
			MAIN_ENABLE			=>	MAIN_ENABLE  ,		
			mode_generator		=>	mode_generator,
						------выходные сигналы-----------
			-- qout_V_out		=>	ena_clk_x2_in,
			-- qout_clk_out	=>	ena_clk_x4_in,
			-- XVS_Imx_Sim		=>	ena_clk_x8_in,
			-- XHS_Imx_Sim		=>	ena_clk_x16_in,
			DATA_IS_pix		=>	DATA_IS_PAR
			);	


-- ------------------------------------симулятор паралелльных данных-----------------
-- IS_SIM_serial_DDR_q: IS_SIM_serial_DDR                   
-- port map (
-- 						------входные сигналы-----------
-- 			CLK_fast			=>	Sensor_PLL_1_CLK_1,			
-- 			MAIN_reset			=>	MAIN_reset ,
-- 			MAIN_ENABLE			=>	MAIN_ENABLE  ,		
-- 			mode_IMAGE_SENSOR	=> 	mode_IMAGE_SENSOR,
-- 			DATA_IMX_OUT		=>	DATA_bion_sync,
-- 						------выходные сигналы-----------
-- 			IMX_DDR_VIDEO		=>	IMX_DDR_VIDEO,
-- 			-- IMX_DDR_CLK_4		=>	IMX_DDR_CLK_4,
-- 			IMX_DDR_CLK			=>	IMX_DDR_CLK
-- 			);	

-- DATA_IS_PAR	<=DATA_IMX_OUT_in;
-- IMX_DDR_CLK_5	<=Sensor_PLL_1_CLK_2;
end ;
