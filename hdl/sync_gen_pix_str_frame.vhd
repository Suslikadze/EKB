library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
----------------------------------------------------------------------
---модуль синхрогенератора
----------------------------------------------------------------------
entity sync_gen_pix_str_frame is
port (
	------------------------------------входные сигналы-----------------------
	CLK						: in std_logic;  											-- тактовый от гнератора
	reset						: in std_logic;  											-- сброс
	MAIN_ENABLE				: in std_logic;  											-- разрешение работы
	------------------------------------выходные сигналы----------------------
	CLK_1_out				: out std_logic; 											-- тактовый с частотой 1
	CLK_2_out				: out std_logic; 											-- тактовый с частотой 2
	CLK_3_out				: out std_logic; 											-- тактовый с частотой 3
	CLK_4_out				: out std_logic; 											-- тактовый с частотой 4
	Lock_PLL_1				: out std_logic; 											-- 
	Lock_PLL_2				: out std_logic; 											-- 
	ena_clk_x_q_IS			: out std_logic_vector (3 downto 0); 				-- разрешение частоты /2 /4 /8/ 16
	qout_clk_IS				: out std_logic_vector (bit_pix-1 downto 0);		-- счетчик пикселей
	stroka_IS				: out std_logic; 	 										-- переполенение счетчика по строке
	qout_v_IS				: out std_logic_vector (bit_strok-1 downto 0); 	-- счетчик строк
	kadr_IS					: out std_logic; 	 										-- переполенени счетчика по строке	
	qout_frame_IS			: out std_logic_vector (bit_frame-1 downto 0); 	-- счетчик кадров
	ena_clk_x_q_Inteface	: out std_logic_vector (3 downto 0); 				-- разрешение частоты /2 /4 /8/ 16
	qout_clk_Inteface		: out std_logic_vector (bit_pix-1 downto 0); 	-- счетчик пикселей
	stroka_Inteface		: out std_logic; 	 										-- переполенение счетчика по строке
	qout_v_Inteface		: out std_logic_vector (bit_strok-1 downto 0); 	-- счетчик строк
	kadr_Inteface			: out std_logic; 	 										-- переполенени счетчика по строке	
	qout_frame_Inteface	: out std_logic_vector (bit_frame-1 downto 0) 	-- счетчик кадров
		);
end sync_gen_pix_str_frame;

architecture beh of sync_gen_pix_str_frame is 

----------------------------------------------------------------------
-- PLL_0 entity declaration
----------------------------------------------------------------------
component PLL_0 is
port( 
	POWERDOWN 	: in    std_logic;
	CLKA      	: in    std_logic;
	LOCK      	: out   std_logic;
	GLA       	: out   std_logic;
	GLB       	: out   std_logic
	);
end component;
signal CLK_1_1				: std_logic;
signal CLK_1_2				: std_logic;
signal CLK_1_3				: std_logic;
signal locked_pll_1		: std_logic;
signal MAIN_reset			: std_logic;
signal PLL_POWERDOWN_N	: std_logic;
----------------------------------------------------------------------
-- PLL_1 entity declaration
----------------------------------------------------------------------
component PLL_1 is
port( 
	POWERDOWN 	: in    std_logic;
	CLKA      	: in    std_logic;
	LOCK      	: out   std_logic;
	GLA       	: out   std_logic;
	GLB       	: out   std_logic
	);

end component;
signal CLK_2_1				: std_logic;
signal CLK_2_2				: std_logic;
signal CLK_2_3				: std_logic;
signal locked_pll_2		: std_logic;
----------------------------------------------------------------------

----------------------------------------------------------------------
---модуль генерации пикселей/строк/кадров
----------------------------------------------------------------------
component gen_pix_str_frame is
	generic  (
		PixPerLine		: integer;
		LinePerFrame	: integer
		);
	port (
	------------------------------------входные сигналы-----------------------
		CLK				: in std_logic;  											-- тактовый от гнератора
		reset				: in std_logic;  											-- сброс
		MAIN_ENABLE		: in std_logic;  											-- разрешение работы
		mode_sync_gen	: in std_logic_vector (7 downto 0);             -- режим работы
		------------------------------------выходные сигналы----------------------
		ena_clk_x_q		: out	std_logic_vector (3 downto 0); 				-- разрешение частоты /2 /4 /8/ 16
		qout_clk	    	: out	std_logic_vector (bit_pix-1 downto 0); 	-- счетчик пикселей
		stroka			: out std_logic; 	 										-- переполенение счетчика по строке
		qout_v			: out	std_logic_vector (bit_strok-1 downto 0); 	-- счетчик строк
		kadr				: out std_logic; 	 										-- переполенени счетчика по строке	
		qout_frame		: out	std_logic_vector (bit_frame-1 downto 0) 	-- счетчик кадров
			);
end component;

----------------------------------------------------------------------

begin

MAIN_reset	<= reset;

----------------------------------------------------------------------
--PLL с необходимыми чатотами
----------------------------------------------------------------------
PLL_POWERDOWN_N	<=	'1';
PLL_0_q: PLL_0                   
port map (
	-- Inputs
	POWERDOWN	=> PLL_POWERDOWN_N,
	CLKA			=> CLK,	
	-- Outputs 
	GLA			=> CLK_1_1,		--137.5 МГц
	GLB			=> CLK_1_2, 	--137.5 МГц
	LOCK			=> locked_pll_1
);	

PLL_1_q: PLL_1                   
port map (
	-- Inputs
	POWERDOWN	=> PLL_POWERDOWN_N,
	CLKA			=> CLK_1_2,	
	-- Outputs 
	GLA			=> CLK_2_1,		--29.5 МГц
	GLB			=> CLK_2_2, 	--29.5 МГц
	LOCK			=> locked_pll_2
);	

----------------------------------------------------------------------

----------------------------------------------------------------------
---модуль генерации пикселей/строк/кадров  для фотоприемника
----------------------------------------------------------------------
gen_pix_str_frame_IS: gen_pix_str_frame    	             
generic map (
	EKD_2200_1250p50.PixPerLine,
	EKD_2200_1250p50.LinePerFrame
	) 
port map (
			-----in---------
	CLK				=> CLK_1_1,	
	reset				=> MAIN_reset ,
	MAIN_ENABLE		=> MAIN_ENABLE,
	mode_sync_gen 	=> mode_sync_gen_IS,
			------ out------
	ena_clk_x_q		=> ena_clk_x_q_IS,
	qout_clk			=> qout_clk_IS,
	stroka			=> stroka_IS,
	qout_v			=> qout_V_IS,
	kadr				=> kadr_IS,
	qout_frame		=> qout_frame_IS
	);	
----------------------------------------------------------------------

----------------------------------------------------------------------
---модуль генерации пикселей/строк/кадров  для интерфейса
----------------------------------------------------------------------
gen_pix_str_frame_Inteface: gen_pix_str_frame    	             
generic map (
	EKD_ADV7343_PAL.PixPerLine,
	EKD_ADV7343_PAL.LinePerFrame
	) 
port map (
			-----in---------
	CLK				=> CLK_2_1,	
	reset				=> MAIN_reset ,
	MAIN_ENABLE		=> MAIN_ENABLE,
	mode_sync_gen 	=> mode_sync_gen_Inteface,
			------ out------
	ena_clk_x_q		=> ena_clk_x_q_Inteface,
	qout_clk			=> qout_clk_Inteface,
	stroka			=> stroka_Inteface,
	qout_v			=> qout_V_Inteface,
	kadr				=> kadr_Inteface,
	qout_frame		=> qout_frame_Inteface
	);	
----------------------------------------------------------------------

----------------------------------------------------------------------
--выходные сигналы
----------------------------------------------------------------------
CLK_1_out	<=	CLK_1_1;
CLK_2_out	<=	CLK_1_2;
CLK_3_out	<=	CLK_2_1;
CLK_4_out	<=	CLK_2_2;
Lock_PLL_1	<=locked_pll_1;
Lock_PLL_2	<=locked_pll_2;
end ;

