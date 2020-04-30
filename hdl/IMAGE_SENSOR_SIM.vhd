library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;

entity IMAGE_SENSOR_SIM is
------------------------------------модуль управления ФП-----------------------------------------------------
port (
------------------------------------входные сигналы-----------------------------------------------------
	CLK					: in std_logic;  								-- тактовый 
	mode_IMAGE_SENSOR	: in std_logic_vector (7 downto 0):=x"00";  			-- изменение режимов
	mode_generator		: in std_logic_vector (7 downto 0); 			--задание режима
------------------------------------выходные сигналы-----------------------------------------------------
	SYNC_V				: out std_logic; 								-- синхронизация
	SYNC_H				: out std_logic; 								-- синхронизация
	XVS_Imx_Sim			: out std_logic; 								-- синхронизация
	XHS_Imx_Sim			: out std_logic; 								-- синхронизация
	DATA_IMX_OUT		: out  std_logic_vector (bit_data_imx-1 downto 0); 			-- выходной сигнал
	IMX_DDR_VIDEO		: out std_logic;			
	IMX_DDR_CLK_5		: out std_logic;			
	IMX_DDR_CLK			: out std_logic			
		);
end IMAGE_SENSOR_SIM;

architecture beh of IMAGE_SENSOR_SIM is 

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
component IS_SIM_Paralell is
------------------------------------модуль управления ФП---------------------
port (
------------------------------------входные сигналы--------------------------
	CLK					: in std_logic;  								-- тактовый 
	MAIN_reset			: in std_logic;  								-- MAIN_reset
	MAIN_ENABLE			: in std_logic;  								-- MAIN_ENABLE
	mode_IMAGE_SENSOR	: in std_logic_vector (7 downto 0):=x"00";  			-- изменение режимов
	mode_generator		: in std_logic_vector (7 downto 0); 			--задание режима
	-- n_strok				: in std_logic_vector (bit_strok-1 downto 0);	-- изменение режимов
	-- n_pix_IS			: in std_logic_vector (bit_pix-1 downto 0);		-- изменение режимов
	-- START_STR			: in std_logic_vector (bit_strok-1 downto 0);	-- изменение режимов
	-- START_PIX			: in std_logic_vector (bit_pix-1 downto 0);		-- изменение режимов
	-- active_pix			: in std_logic_vector (bit_pix-1 downto 0);		-- изменение режимов
	-- active_lin			: in std_logic_vector (bit_strok-1 downto 0);	-- изменение режимов
------------------------------------выходные сигналы------------------------
	ena_clk_x2			: out std_logic; 								-- синхронизация
	ena_clk_x4			: out std_logic; 								-- синхронизация
	ena_clk_x8			: out std_logic; 								-- синхронизация
	ena_clk_x16			: out std_logic; 								-- синхронизация
	qout_V_out			: out std_logic_vector (bit_strok-1 downto 0);	-- 
	qout_clk_IS_out		: out std_logic_vector (bit_pix-1 downto 0 );	-- 
	SYNC_V				: out std_logic; 								-- синхронизация
	SYNC_H				: out std_logic; 								-- синхронизация
	XVS_Imx_Sim			: out std_logic; 								-- синхронизация
	XHS_Imx_Sim			: out std_logic; 								-- синхронизация
	DATA_IMX_OUT		: out  std_logic_vector (bit_data_imx-1 downto 0) 			-- выходной сигнал
		);
end component;
signal ena_clk_x2_in		: std_logic;
signal ena_clk_x4_in		: std_logic;
signal ena_clk_x8_in		: std_logic;
signal ena_clk_x16_in		: std_logic;
signal qout_clk_IS			: std_logic_vector (bit_pix-1 downto 0);
signal qout_V				: std_logic_vector (bit_strok-1 downto 0);
signal DATA_IMX_OUT_in		: std_logic_vector (bit_data_imx-1 downto 0);

------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
component IS_SIM_serial_DDR is
------------------------------------модуль управления ФП---------------------------
port (
------------------------------------входные сигналы--------------------------------
	CLK_fast			: in std_logic;  								-- тактовый 
	MAIN_reset			: in std_logic;  								-- MAIN_reset
	MAIN_ENABLE			: in std_logic;  								-- MAIN_ENABLE
	mode_IMAGE_SENSOR	: in std_logic_vector (7 downto 0):=x"00";		-- изменение режимов
	DATA_IMX_OUT		: in std_logic_vector (bit_data_CSI-1 downto 0);		-- выходной сигнал

------------------------------------выходные сигналы--------------------------------
	IMX_DDR_VIDEO		: out std_logic; 								-- синхронизация
	IMX_DDR_CLK_4		: out std_logic; 								-- синхронизация
	IMX_DDR_CLK			: out std_logic 								-- синхронизация
		);
end component;

signal IMX_DDR_CLK_4			: std_logic;			


------------------------------------------------------------------------------------

----------------------------------------------------------------------
-- Sensor_PLL_2 entity declaration
----------------------------------------------------------------------
component Sensor_PLL_2 is
    -- Port list
    port(
        -- Inputs
        CLK0            : in  std_logic;
        PLL_ARST_N      : in  std_logic;
        PLL_BYPASS_N    : in  std_logic;
        PLL_POWERDOWN_N : in  std_logic;
        -- Outputs
        GL0             : out std_logic;
        LOCK            : out std_logic
        );
end component;
signal Sensor_PLL_2_CLK_1		: std_logic;			
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Sensor_PLL_2 entity declaration
----------------------------------------------------------------------
component Sensor_PLL_1 is
    -- Port list
    port(
        -- Inputs
        CLK0            : in  std_logic;
        PLL_ARST_N      : in  std_logic;
        PLL_BYPASS_N    : in  std_logic;
        PLL_POWERDOWN_N : in  std_logic;
        -- Outputs
        GL0             : out std_logic;
        GL1             : out std_logic;
        LOCK            : out std_logic
        );
end component;

signal PLL_ARST_N			: std_logic;			
signal PLL_BYPASS_N			: std_logic;			
signal PLL_POWERDOWN_N		: std_logic;			
signal Sensor_PLL_1_CLK_1	: std_logic;			
signal Sensor_PLL_1_CLK_2	: std_logic;			
signal locked_pll					: std_logic;
signal MAIN_ENABLE					: std_logic;
signal MAIN_reset					: std_logic;
----------------------------------------------------------------------


component BION_Paralell is
	------------------------------------модуль управления ФП-----------------------------------------------------
	port (
	------------------------------------входные сигналы-----------------------------------------------------
		CLK					: in std_logic;  								-- тактовый 
		MAIN_reset			: in std_logic;  								-- MAIN_reset
		MAIN_ENABLE			: in std_logic;  								-- MAIN_ENABLE
		qout_clk_IS			: in std_logic_vector (bit_pix-1 downto 0); 	-- счетчик пикселей
		qout_v				: in std_logic_vector (bit_strok-1 downto 0); -- счетчик строк
		ena_clk_x2			: in std_logic; 								--   /2
		ena_clk_x4			: in std_logic; 								--   /4
		DATA_IN     		: in  std_logic_vector (bit_data_CSI-1 downto 0); 			-- выходной сигна
		mode_IMAGE_SENSOR	: in std_logic_vector (7 downto 0):=x"00";  			-- изменение режимов
		mode_generator		: in std_logic_vector (7 downto 0); 			--задание режима
		------------------------------------выходные сигналы-----------------------------------------------------
	
		DATA_IMX_OUT		: out  std_logic_vector (bit_data_CSI-1 downto 0) 			-- выходной сигнал
			);
	end component;
	signal DATA_bion_sync    	: std_logic_vector (bit_data_CSI-1 downto 0);

begin
PLL_ARST_N		<=	'1';
PLL_BYPASS_N	<=	'1';
PLL_POWERDOWN_N	<=	'1';
Sensor_PLL_1_q: Sensor_PLL_1                   
port map (
        -- Inputs
	CLK0				=>CLK,
	PLL_ARST_N			=>PLL_ARST_N,	
	PLL_BYPASS_N		=>PLL_BYPASS_N,	
	PLL_POWERDOWN_N		=>PLL_POWERDOWN_N,	
        -- Outputs
	GL0		 	  		=>Sensor_PLL_1_CLK_1,	--297 MHz
	GL1		 	  		=>Sensor_PLL_1_CLK_2,	--297 MHz 
	LOCK	        	=>locked_pll
);	

Sensor_PLL_2_q: Sensor_PLL_2                   
port map (
        -- Inputs
	CLK0				=>CLK,
	PLL_ARST_N			=>PLL_ARST_N,	
	PLL_BYPASS_N		=>PLL_BYPASS_N,	
	PLL_POWERDOWN_N		=>PLL_POWERDOWN_N,	
        -- Outputs
	GL0		 	  		=>Sensor_PLL_2_CLK_1	--74.25 MHz
);	

MAIN_reset	<=	not locked_pll;
MAIN_ENABLE	<=	locked_pll;
 
 
------------------------------------симулятор паралелльных данных----------------------------------------------------
IS_SIM_Paralell_q: IS_SIM_Paralell                   
port map (
						------входные сигналы-----------
			CLK					=>	Sensor_PLL_2_CLK_1,			
			MAIN_reset			=>	MAIN_reset ,
			MAIN_ENABLE			=>	MAIN_ENABLE  ,		
			mode_IMAGE_SENSOR	=> 	mode_IMAGE_SENSOR,
			mode_generator		=> 	mode_generator,
						------выходные сигналы-----------
			ena_clk_x2			=>	ena_clk_x2_in,
			ena_clk_x4			=>	ena_clk_x4_in,
			ena_clk_x8			=>	ena_clk_x8_in,
			ena_clk_x16			=>	ena_clk_x16_in,
			qout_V_out			=>	qout_V,
			qout_clk_IS_out		=>	qout_clk_IS,
			SYNC_V				=>	SYNC_V,
			SYNC_H				=>	SYNC_H,
			XVS_Imx_Sim			=>	XVS_Imx_Sim,
			XHS_Imx_Sim			=>	XHS_Imx_Sim,
			DATA_IMX_OUT		=>	DATA_IMX_OUT_in
			);	
			


BION_Paralell_q: BION_Paralell    
port map (
	---------In------------
	CLK					=>	Sensor_PLL_2_CLK_1,
	MAIN_reset			=>	MAIN_reset,
	MAIN_ENABLE			=>	MAIN_ENABLE,
	qout_clk_IS			=>	qout_clk_IS,
	qout_v				=>	qout_v,
	ena_clk_x2			=>	ena_clk_x2_in,
	ena_clk_x4			=>	ena_clk_x4_in,
	DATA_IN				=>	qout_clk_IS(7 downto 0) ,
	mode_IMAGE_SENSOR	=>	mode_IMAGE_SENSOR,
	mode_generator		=> 	mode_generator,
	---------out------------
	DATA_IMX_OUT		=>	DATA_bion_sync
	);		
------------------------




------------------------------------симулятор паралелльных данных-----------------
IS_SIM_serial_DDR_q: IS_SIM_serial_DDR                   
port map (
						------входные сигналы-----------
			CLK_fast			=>	Sensor_PLL_1_CLK_1,			
			MAIN_reset			=>	MAIN_reset ,
			MAIN_ENABLE			=>	MAIN_ENABLE  ,		
			mode_IMAGE_SENSOR	=> 	mode_IMAGE_SENSOR,
			DATA_IMX_OUT		=>	DATA_bion_sync,
						------выходные сигналы-----------
			IMX_DDR_VIDEO		=>	IMX_DDR_VIDEO,
			-- IMX_DDR_CLK_4		=>	IMX_DDR_CLK_4,
			IMX_DDR_CLK			=>	IMX_DDR_CLK
			);	

DATA_IMX_OUT	<=DATA_IMX_OUT_in;
IMX_DDR_CLK_5	<=Sensor_PLL_1_CLK_2;
end ;
