library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
----------------------------------------------------------------------
-- модуль генерации видеосигнала от фотоприемника в паралелльном коде
----------------------------------------------------------------------
entity IS_SIM_Paralell is
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
	DATA_IS_pix_ch_1	: out  std_logic_vector (bit_data_imx-1 downto 0);	-- выходной сигнал
	DATA_IS_pix_ch_2	: out  std_logic_vector (bit_data_imx-1 downto 0);	-- выходной сигнал
	DATA_IS_pix_ch_3	: out  std_logic_vector (bit_data_imx-1 downto 0);	-- выходной сигнал
	DATA_IS_pix_ch_4	: out  std_logic_vector (bit_data_imx-1 downto 0)	-- выходной сигнал
		);
end IS_SIM_Paralell;

architecture beh of IS_SIM_Paralell is 
--------------------------------------------------------
--TRS коды от IMX
--------------------------------------------------------
signal TRS_F0_V0_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal TRS_F0_V0_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal TRS_F0_V1_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal TRS_F0_V1_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal TRS_SYNC_3FF		: std_logic_vector (bit_data_imx-1 downto 0);
signal TRS_SYNC_0			: std_logic_vector (bit_data_imx-1 downto 0);

---------------------------------------------------
-- генератор тестовых сигналов
---------------------------------------------------
component PATHERN_GENERATOR is
	port (
		CLK					: in std_logic; 												--	тактовый сигнал данных	
		MAIN_reset			: in std_logic;  												-- MAIN_reset
		ena_clk				: in std_logic;  												-- разрешение по частоте
		qout_clk				: in std_logic_vector (bit_pix-1 downto 0); 			--	счетчик пикселей
		qout_V				: in std_logic_vector (bit_strok-1 downto 0);		--	счетчик строк
		mode_generator		: in std_logic_vector (7 downto 0); 					--	задание режима
		data_in				: in std_logic_vector (bit_data_imx-1 downto 0) ;	--	входной сигнал
		data_out				: out std_logic_vector (bit_data_imx-1 downto 0) 	--	выходной сигнал							--сигнал валидных данных	
			);	
end component;
signal data_generator_out	: std_logic_vector (bit_data_imx-1 downto 0);
--------------------------------------------------------

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
signal stroka_IS				: std_logic:='0';
signal kadr_IS					: std_logic:='0';
signal qout_clk_IS			: std_logic_vector (bit_pix-1 downto 0):=(Others => '0'); 
signal qout_clk_IS_ch		: std_logic_vector (bit_pix-1 downto 0):=(Others => '0'); 



signal qout_frame_IS			: std_logic_vector (bit_frame-1 downto 0):=(Others => '0');
signal qout_V_IS				: std_logic_vector (bit_strok-1 downto 0):=(Others => '0');
signal ena_clk_x_q_IS		: std_logic_vector (3 downto 0):=(Others => '0');
-------------------------------------------------------------------------------

signal ena_clk_in				: std_logic;
signal PixPerLine				: integer range 0 to 2**bit_pix-1;
signal HsyncShift				: integer range 0 to 2**bit_pix-1;
signal ActivePixPerLine		: integer range 0 to 2**bit_pix-1;
signal VALID_DATA				: std_logic;
signal data_imx_video		: std_logic_vector (bit_data_imx-1 downto 0);
signal video_gen_ch_1		: std_logic_vector (bit_data_imx-1 downto 0);
signal video_gen_ch_2		: std_logic_vector (bit_data_imx-1 downto 0);
signal video_gen_ch_3		: std_logic_vector (bit_data_imx-1 downto 0);
signal video_gen_ch_4		: std_logic_vector (bit_data_imx-1 downto 0);
signal data_imx_anc			: std_logic_vector (bit_data_imx-1 downto 0);
signal DATA_IMX_in			: std_logic_vector (bit_data_imx-1 downto 0);
signal mode_sync_gen			: std_logic_vector (7 downto 0);

type pix_byf is array (0 to 7) of std_logic_vector (bit_data_imx-1 downto 0)	;
signal DATA_q : pix_byf := (others => (others => '0'));
begin

----------------------------------------------------------------------
---модуль генерации пикселей/строк/кадров  для интерфейса
----------------------------------------------------------------------
gen_pix_str_frame_Inteface: gen_pix_str_frame    	             
generic map (
	EKD_2200_1250p50.PixPerLine,
	EKD_2200_1250p50.LinePerFrame
	) 
port map (
			-----in---------
	CLK				=> CLK,	
	reset				=> MAIN_reset ,
	MAIN_ENABLE		=> MAIN_ENABLE,
	mode_sync_gen 	=> mode_sync_gen_IS ,
			------ out------
	ena_clk_x_q		=> ena_clk_x_q_IS,
	qout_clk			=> qout_clk_IS,
	stroka			=> stroka_IS,
	qout_v			=> qout_V_IS,
	kadr				=> kadr_IS,
	qout_frame		=> qout_frame_IS
	);	
------------------------------------------------------------
-- генератор тестовых сигналов
------------------------------------------------------------
PATHERN_GENERATOR_q: PATHERN_GENERATOR                    
port map (
			--IN
	CLK				=>	CLK,	
	MAIN_reset		=>	MAIN_reset ,
	ena_clk			=>	MAIN_ENABLE,		
	qout_clk			=>	qout_clk_IS,		
	qout_V			=>	qout_V_IS,
	mode_generator	=>	mode_generator,
	data_in			=>	qout_clk_IS(bit_data_imx-1 downto 0),
			--OUT
	data_out			=>	data_generator_out 
		);
------------------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	DATA_q(0) <= data_generator_out;
	for i in 0 to 6 loop
		DATA_q(i+1) <= DATA_q(i);
	end loop;
end if;
end process;

Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		video_gen_ch_1	<=	DATA_q(3);
		video_gen_ch_2	<=	DATA_q(2);
		video_gen_ch_3	<=	DATA_q(1);
		video_gen_ch_4	<=	DATA_q(0);
	end if;
end if;
end process;

Process(CLK)
begin
if rising_edge(CLK) then
	case  mode_IMAGE_SENSOR (3 downto 0)	is
		when x"0"	=>	mode_sync_gen	<=x"00";	-- CSI - 1 линия
		when x"1"	=>	mode_sync_gen	<=x"00";	-- LVDS - 1 линия
		when x"2"	=>	mode_sync_gen	<=x"01";	-- LVDS - 2 линия
		when x"3"	=>	mode_sync_gen	<=x"02";	-- LVDS - 4 линия
		WHEN others	=>	mode_sync_gen	<=x"00";	-- CSI - 1 линия		
		END case;	
	end if;
end process;
-------------------------------------------------------------------------------------------
---определение количество пикселей по строке в зависимости от количестов линий передачи
-------------------------------------------------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	
	case  mode_sync_gen (3 downto 0)	is
		when x"0"	=>			-- 1 линия / количество пикселей и другие параметры по строке не меняются
			ena_clk_in			<= '1';	
			qout_clk_IS_ch		<= qout_clk_IS;	
			PixPerLine			<=	EKD_2200_1250p50.PixPerLine;
			HsyncShift			<=	EKD_2200_1250p50.HsyncShift;
			ActivePixPerLine	<=	EKD_2200_1250p50.ActivePixPerLine;
		when x"1"	=>		-- 2 линии / параметры деляется на 2
			ena_clk_in			<= ena_clk_x_q_IS(0);		
			qout_clk_IS_ch		<= qout_clk_IS  srl 1;	
			PixPerLine			<=	EKD_2200_1250p50.PixPerLine /2;
			HsyncShift			<=	EKD_2200_1250p50.HsyncShift /2;
			ActivePixPerLine	<=	EKD_2200_1250p50.ActivePixPerLine /2;			
		when x"2"	=>		-- 4 линии / параметры деляется на 4		
			ena_clk_in			<= ena_clk_x_q_IS(1);		
			qout_clk_IS_ch		<= qout_clk_IS  srl 2;	
			PixPerLine			<=	EKD_2200_1250p50.PixPerLine /4;
			HsyncShift			<=	EKD_2200_1250p50.HsyncShift /4;
			ActivePixPerLine	<=	EKD_2200_1250p50.ActivePixPerLine /4;
		when x"3"	=>		-- 8 линии / параметры деляется на 8
			ena_clk_in			<= ena_clk_x_q_IS(2);		
			qout_clk_IS_ch		<= qout_clk_IS  srl 3;	
			PixPerLine			<=	EKD_2200_1250p50.PixPerLine /8;
			HsyncShift			<=	EKD_2200_1250p50.HsyncShift /8;
			ActivePixPerLine	<=	EKD_2200_1250p50.ActivePixPerLine /8;
		WHEN others	=>			
			ena_clk_in			<= '1';		
			qout_clk_IS_ch		<= qout_clk_IS;	
			PixPerLine			<=	EKD_2200_1250p50.PixPerLine;
			HsyncShift			<=	EKD_2200_1250p50.HsyncShift;
			ActivePixPerLine	<=	EKD_2200_1250p50.ActivePixPerLine;
		END case;	
	end if;
end process;
------------------------------------------------------------

---------------------------------------------------
---модуль генерации TRS кодов для IMX
---------------------------------------------------
TRS_gen_q: TRS_gen                    
generic map (bit_data_imx) 
port map (
	CLK				=>	CLK,		
   TRS_SYNC_3FF   => TRS_SYNC_3FF,
   TRS_SYNC_0     => TRS_SYNC_0  ,
   TRS_F0_V0_H0   => TRS_F0_V0_H0,
   TRS_F0_V0_H1   => TRS_F0_V0_H1,
   TRS_F0_V1_H0   => TRS_F0_V1_H0,
   TRS_F0_V1_H1   => TRS_F0_V1_H1
	);
------------------------------------------------------------
-- вставка синхро кодов TRS к передаваемую последовательность
------------------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		data_imx_anc	<=std_logic_vector(to_unsigned(3,bit_data_imx));
		data_imx_video	<=data_generator_out(bit_data_imx-1 downto 0);
		if (to_integer(unsigned (qout_V_IS)) >= EKD_2200_1250p50.VsyncShift)	and (to_integer(unsigned (qout_V_IS)) < EKD_2200_1250p50.VsyncShift + EKD_2200_1250p50.ActiveLine ) then
			if		to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift - 1																								then	DATA_IMX_in <= TRS_F0_V0_H0;			VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift - 2																								then	DATA_IMX_in <= TRS_SYNC_0;				VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift - 3																								then	DATA_IMX_in <= TRS_SYNC_0;				VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift - 4																								then	DATA_IMX_in <= TRS_SYNC_3FF;			VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift + ActivePixPerLine - 1																		then	DATA_IMX_in <= TRS_SYNC_3FF;			VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift + ActivePixPerLine - 2																		then	DATA_IMX_in <= TRS_SYNC_0;				VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift + ActivePixPerLine - 3																		then	DATA_IMX_in <= TRS_SYNC_0;				VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift + ActivePixPerLine - 4																		then	DATA_IMX_in <= TRS_F0_V0_H1;			VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	>= HsyncShift and to_integer(unsigned (qout_clk_IS_ch)) < HsyncShift + ActivePixPerLine	then	DATA_IMX_in <= data_imx_video;		VALID_DATA<='1';
			else																																												DATA_IMX_in <= data_imx_anc;			VALID_DATA<='0';
		end if;
			else	
			if 	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift - 1																								then 	DATA_IMX_in <= TRS_F0_V1_H0;			VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift - 2																								then 	DATA_IMX_in <= TRS_SYNC_0;				VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift - 3																								then 	DATA_IMX_in <= TRS_SYNC_0;				VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift - 4																								then 	DATA_IMX_in <= TRS_SYNC_3FF;			VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift + ActivePixPerLine - 1																		then 	DATA_IMX_in <= TRS_SYNC_3FF;			VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift + ActivePixPerLine - 2																		then 	DATA_IMX_in <= TRS_SYNC_0;				VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift + ActivePixPerLine - 3																		then 	DATA_IMX_in <= TRS_SYNC_0;				VALID_DATA<='0';
			elsif	to_integer(unsigned (qout_clk_IS_ch))	= HsyncShift + ActivePixPerLine - 4																		then 	DATA_IMX_in <= TRS_F0_V1_H1;			VALID_DATA<='0';
			else																																	 											DATA_IMX_in <= data_imx_anc;			VALID_DATA<='0';
			end if;
		end if;
	end if;
end if;
end process;
------------------------------------------------------------
-- формирование синхросигналов
------------------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		if 		(to_integer(unsigned (qout_V_IS))	<=	EKD_2200_1250p50.VsyncWidth)	
			then	XVS_Imx_Sim	<='0';
			else	XVS_Imx_Sim	<='1';
		end if;
		if 		(to_integer(unsigned (qout_clk_IS_ch))	<=	EKD_2200_1250p50.HsyncWidth)
			then	XHS_Imx_Sim	<='0';
			else	XHS_Imx_Sim	<='1';
		end if;
	end if;
end if;
end process;
 

------------------------------------------------------------
-- выходные сигналы
------------------------------------------------------------

Process(CLK)
begin
if rising_edge(CLK) then
	qout_V_out	 		<= qout_V_IS;
	qout_clk_out		<= qout_clk_IS_ch;

	if ena_clk_in='1'		then
		if  VALID_DATA='1'	then
			DATA_IS_pix_ch_1	<=	video_gen_ch_1;
			DATA_IS_pix_ch_2	<=	video_gen_ch_2;
			DATA_IS_pix_ch_3	<=	video_gen_ch_3;
			DATA_IS_pix_ch_4	<=	video_gen_ch_4;
		else
			DATA_IS_pix_ch_1	<=	DATA_IMX_in;
			DATA_IS_pix_ch_2	<=	DATA_IMX_in;
			DATA_IS_pix_ch_3	<=	DATA_IMX_in;
			DATA_IS_pix_ch_4	<=	DATA_IMX_in;
		end if;
	end if;
end if;
end process;


	

end ;
