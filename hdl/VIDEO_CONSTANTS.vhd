library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package   VIDEO_CONSTANTS	is

constant bit_data_CSI		: integer :=8;		--разрядность данных CSI	
constant bit_data_imx		: integer :=12;	--разрядность данных IMX	
constant bit_data_SMPTE		: integer :=10;	--разрядность данных SMPTE	
constant bit_frame			: integer :=8;		--бит на счетчик кадров 		
constant bit_pix				: integer :=13;	--разрядность счетчика пикселей		
constant bit_strok			: integer :=16;	--разрядность счетчика строк		
constant N_channel_imx		: integer :=4;		--	количесвтво каналов по LVDS 1 / 2 / 4
---------------------------------------------------------------------------------
constant mode_IMAGE_SENSOR	: std_logic_vector (7 downto 0) :=x"03";		
-- mode_IMAGE_SENSOR (3 downto 0) = 0 CSI - 1 линия
-- mode_IMAGE_SENSOR (3 downto 0) = 1 LVDS - 1 линия
-- mode_IMAGE_SENSOR (3 downto 0) = 2 LVDS - 2 линия
-- mode_IMAGE_SENSOR (3 downto 0) = 3 LVDS - 4 линия
-- разрядность данный определяется bit_data_imx 12 / 10 / 8 bit

-- mode_IMAGE_SENSOR (7 downto 4) = 0 B/W
-- mode_IMAGE_SENSOR (7 downto 4) = 1 COLOR
---------------------------------------------------------------------------------
constant mode_sync_gen_IS			: std_logic_vector (7 downto 0) :=x"00";		
constant mode_sync_gen_Inteface	: std_logic_vector (7 downto 0) :=x"00";		
-- 0 - без понижения частоты
-- 1 - работа с частотой /2
-- 2 - работа с частотой /4
-- 3 - работа с частотой /8
---------------------------------------------------------------------------------
constant mode_generator_IS			: std_logic_vector (7 downto 0) :=x"00";		
constant mode_generator_Inteface	: std_logic_vector (7 downto 0) :=x"00";		

-- mode_generator определяет тип данных для передачи
-- младшие 4 бита отвечаю за тип сигнала, старшие за кастомизацию
-- 	[7..4]						[3..0]
-- 	сдвиг разрядов				0 градационный клин по горизонтали
-- 	сдвиг разрядов				1 градационный клин по вертикали
-- 	none							2 шумоподобный сигнал на основе полинома SMPTE
-- 	размер клеток				3 шахматное поле
-- 	интенсиыность полос		4 цветные полосы (color bar)
-- 	none							5 сигнал из файла
-- 	none							F сигнал входной транзитов на выход
--------------------------------------------------------------




---------------------------------------------------------------------------------
-- синхро слова CSI в загаловке строки
-- для разного разрешения и битности выходной шины нужно изменить dataID / word count / ECC
---------------------------------------------------------------------------------
constant CSI_sync_code_1	: std_logic_vector (bit_data_CSI-1 downto 0) :=	x"B8" ; -- НЕпоняно что это от IMX. в CSI спецификации этого нет
constant CSI_sync_code_2	: std_logic_vector (bit_data_CSI-1 downto 0) :=	x"2B" ; -- dataIDRAW10 bit
constant CSI_sync_code_3	: std_logic_vector (bit_data_CSI-1 downto 0) :=	x"1C" ; -- x"071c" - 1820 8bit word
constant CSI_sync_code_4	: std_logic_vector (bit_data_CSI-1 downto 0) :=	x"07" ; -- x"071c" - 1456 10bit word
constant CSI_sync_code_5	: std_logic_vector (bit_data_CSI-1 downto 0) :=	x"00" ; -- ECC
---------------------------------------------------------------------------------


type VideoStandartType is record
	PixPerLine,
	ActivePixPerLine,
	InActivePixPerLine,
	HsyncWidth,
	HsyncWidthGapLeft,
	HsyncWidthGapRight,
	HsyncShift,
	LinePerFrame,
	ActiveLine,
	InActiveLine,
	VsyncWidth,
	VsyncShift	:integer;
end record;
							
							------------------------------------------
							---HIGH RESOLUTION-----1.5 Gbit/s-74.5MHz-
							------------------------------------------
constant CEA_1920_1080p30 :	VideoStandartType:=	(	PixPerLine			=>	2200,
													ActivePixPerLine	=>	1920,	
													InActivePixPerLine	=>	280,	
													HsyncWidth			=>	44,	
													HsyncWidthGapLeft	=>	148,	
													HsyncWidthGapRight	=>	88,	
													HsyncShift			=>	10,
													LinePerFrame		=>	1125,
													ActiveLine			=>	1080,
													InActiveLine		=>	45,
													VsyncWidth			=>	5,	
													VsyncShift			=>	5);	

constant CEA_1920_1080p25 :	VideoStandartType:=	(	PixPerLine			=>	2640,
													ActivePixPerLine	=>	1920,	
													InActivePixPerLine	=>	720,	
													HsyncWidth			=>	44,	
													HsyncWidthGapLeft	=>	148,	
													HsyncWidthGapRight	=>	528,	
													HsyncShift			=>	0,
													LinePerFrame		=>	1125,
													ActiveLine			=>	1080,
													InActiveLine		=>	45,
													VsyncWidth			=>	5,	
													VsyncShift			=>	0);	

constant CEA_1280_720p50 :	VideoStandartType:=	(	PixPerLine			=>	1980,
													ActivePixPerLine	=>	1280,	
													InActivePixPerLine	=>	700,	
													HsyncWidth			=>	40,	
													HsyncWidthGapLeft	=>	440,	
													HsyncWidthGapRight	=>	220,	
													HsyncShift			=>	0,
													LinePerFrame		=>	750,
													ActiveLine			=>	720,
													InActiveLine		=>	30,
													VsyncWidth			=>	5,	
													VsyncShift			=>	0);	

constant CEA_1280_720p60 :	VideoStandartType:=	(	PixPerLine			=>	1650,
													ActivePixPerLine	=>	1280,	
													InActivePixPerLine	=>	370,	
													HsyncWidth			=>	40,	
													HsyncWidthGapLeft	=>	110,	
													HsyncWidthGapRight	=>	220,	
													HsyncShift			=>	0,
													LinePerFrame		=>	750,
													ActiveLine			=>	720,
													InActiveLine		=>	30,
													VsyncWidth			=>	5,	
													VsyncShift			=>	0);	

constant CEA_1280_720p25 :	VideoStandartType:=	(	PixPerLine			=>	3960,
													ActivePixPerLine	=>	1280,	
													InActivePixPerLine	=>	2680,	
													HsyncWidth			=>	40,	
													HsyncWidthGapLeft	=>	2680,	
													HsyncWidthGapRight	=>	220,	
													HsyncShift			=>	0,
													LinePerFrame		=>	750,
													ActiveLine			=>	720,
													InActiveLine		=>	30,
													VsyncWidth			=>	5,	
													VsyncShift			=>	0);	

constant CEA_1280_720p30 :	VideoStandartType:=	(	PixPerLine			=>	3300,
													ActivePixPerLine	=>	1280,	
													InActivePixPerLine	=>	2020,	
													HsyncWidth			=>	40,	
													HsyncWidthGapLeft	=>	1760,	
													HsyncWidthGapRight	=>	220,	
													HsyncShift			=>	0,
													LinePerFrame		=>	750,
													ActiveLine			=>	720,
													InActiveLine		=>	30,
													VsyncWidth			=>	5,	
													VsyncShift			=>	0);	

							------------------------------------------
							---HIGH RESOLUTION-----3 Gbit/s-148.5MHz--
							------------------------------------------
constant CEA_1920_1080p60 :	VideoStandartType:=	(	PixPerLine			=>	2200,
													ActivePixPerLine	=>	1920,	
													InActivePixPerLine	=>	280,	
													HsyncWidth			=>	44,	
													HsyncWidthGapLeft	=>	148,	
													HsyncWidthGapRight	=>	88,	
													HsyncShift			=>	0,
													LinePerFrame		=>	1125,
													ActiveLine			=>	1080,
													InActiveLine		=>	45,
													VsyncWidth			=>	5,	
													VsyncShift			=>	0);	

constant CEA_1920_1080p50 :	VideoStandartType:=	(	PixPerLine			=>	2640,
													ActivePixPerLine	=>	1920,	
													InActivePixPerLine	=>	720,	
													HsyncWidth			=>	44,	
													HsyncWidthGapLeft	=>	148,	
													HsyncWidthGapRight	=>	528,	
													HsyncShift			=>	0,
													LinePerFrame		=>	1125,
													ActiveLine			=>	1080,
													InActiveLine		=>	45,
													VsyncWidth			=>	5,	
													VsyncShift			=>	0);	

							------------------------------------------
							-------------CUSTOM RESOLUTION------------
							------------------------------------------
constant BION_960_960p30 :	VideoStandartType:=	(	PixPerLine			=>	1000,
													ActivePixPerLine	=>	960,	
													InActivePixPerLine	=>	40,	
													HsyncWidth			=>	10,	
													HsyncWidthGapLeft	=>	15,	
													HsyncWidthGapRight	=>	15,	
													HsyncShift			=>	5,
													LinePerFrame		=>	1125,
													ActiveLine			=>	960,
													InActiveLine		=>	65,
													VsyncWidth			=>	5,	
													VsyncShift			=>	5);	


-- constant TEST_960_960p30 :	VideoStandartType:=	(	PixPerLine			=>	220,
-- 													ActivePixPerLine	=>	192,	
-- 													InActivePixPerLine	=>	28,	
-- 													HsyncWidth			=>	4,	
-- 													HsyncWidthGapLeft	=>	14,	
-- 													HsyncWidthGapRight	=>	8,	
-- 													HsyncShift			=>	0,
-- 													LinePerFrame		=>	112,
-- 													ActiveLine			=>	108,
-- 													InActiveLine		=>	4,
-- 													VsyncWidth			=>	1,	
-- 													VsyncShift			=>	0);	

-- constant EKD_ADV7343_PAL :	VideoStandartType:=	(	PixPerLine			=>	1888,
-- 													ActivePixPerLine	=>	1536,	
-- 													InActivePixPerLine	=>	352,	
-- 													HsyncWidth			=>	10,	
-- 													HsyncWidthGapLeft	=>	15,	
-- 													HsyncWidthGapRight	=>	15,	
-- 													HsyncShift			=>	5,
-- 													LinePerFrame		=>	625,
-- 													ActiveLine			=>	575,
-- 													InActiveLine		=>	50,
-- 													VsyncWidth			=>	5,	
-- 													VsyncShift			=>	5);	

-- constant EKD_2200_1250p50 :	VideoStandartType:=	(	PixPerLine			=>	2200,
-- 													ActivePixPerLine	=>	1536,	
-- 													InActivePixPerLine	=>	664,	
-- 													HsyncWidth			=>	10,	
-- 													HsyncWidthGapLeft	=>	15,	
-- 													HsyncWidthGapRight	=>	15,	
-- 													HsyncShift			=>	5,
-- 													LinePerFrame		=>	1250,
-- 													ActiveLine			=>	1150,
-- 													InActiveLine		=>	100,
-- 													VsyncWidth			=>	5,	
-- 													VsyncShift			=>	5);	

constant EKD_ADV7343_PAL :	VideoStandartType:=		(	PixPerLine				=>	944,
																		ActivePixPerLine		=>	768,	
																		InActivePixPerLine	=>	176,	
																		HsyncWidth				=>	10,	
																		HsyncWidthGapLeft		=>	15,	
																		HsyncWidthGapRight	=>	15,	
																		HsyncShift				=>	40,
																		LinePerFrame			=>	16,
																		ActiveLine				=>	10,
																		InActiveLine			=>	6,
																		VsyncWidth				=>	1,	
																		VsyncShift				=>	1);	

constant EKD_2200_1250p50 :	VideoStandartType:= (	PixPerLine				=>	1100,
																		ActivePixPerLine		=>	768,	
																		InActivePixPerLine	=>	332,	
																		HsyncWidth				=>	10,	
																		HsyncWidthGapLeft		=>	15,	
																		HsyncWidthGapRight	=>	15,	
																		HsyncShift				=>	40,
																		LinePerFrame			=>	32,
																		ActiveLine				=>	20,
																		InActiveLine			=>	12,
																		VsyncWidth				=>	1,	
																		VsyncShift				=>	1);	


end package ;
