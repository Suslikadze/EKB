library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package   VIDEO_CONSTANTS	is

constant bit_data_CSI	: integer :=8;	--разрядность данных CSI	
constant bit_data_imx	: integer :=8;	--разрядность данных IMX	
constant bit_data_SMPTE	: integer :=10;	--разрядность данных SMPTE	
constant bit_frame		: integer :=8;	--бит на счетчик кадров 		
constant bit_pix			: integer :=13;	--разрядность счетчика пикселей		
constant bit_strok		: integer :=16;	--разрядность счетчика строк		
constant mode_work		: integer :=3;	--	1 test // 2 720p50	// 3 1080p25// 4 720p25		

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

component parall_to_serial is
generic 
	(
		bit_data		: integer :=8			--bit na stroki
	);
port(
	dir        : in STD_LOGIC;
	ena        : in STD_LOGIC;
	clk        : in STD_LOGIC;
	data       : in STD_LOGIC_VECTOR(bit_data-1 downto 0);
	load       : in STD_LOGIC;
	shiftout   : out STD_LOGIC
	);
end component;
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

constant EKD_ADV7343_PAL :	VideoStandartType:=	(	PixPerLine			=>	236,
													ActivePixPerLine	=>	153,	
													InActivePixPerLine	=>	35,	
													HsyncWidth			=>	10,	
													HsyncWidthGapLeft	=>	15,	
													HsyncWidthGapRight	=>	15,	
													HsyncShift			=>	5,
													LinePerFrame		=>	62,
													ActiveLine			=>	57,
													InActiveLine		=>	5,
													VsyncWidth			=>	1,	
													VsyncShift			=>	1);	

constant EKD_2200_1250p50 :	VideoStandartType:=	(	PixPerLine			=>	275,
													ActivePixPerLine	=>	153,	
													InActivePixPerLine	=>	66,	
													HsyncWidth			=>	10,	
													HsyncWidthGapLeft	=>	15,	
													HsyncWidthGapRight	=>	15,	
													HsyncShift			=>	5,
													LinePerFrame		=>	124,
													ActiveLine			=>	115,
													InActiveLine		=>	10,
													VsyncWidth			=>	1,	
													VsyncShift			=>	1);	


end package ;
