library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;

entity IS_SIM_Paralell is
------------------------------------модуль управления ФП-----------------------------------------------------
port (
------------------------------------входные сигналы-----------------------------------------------------
	CLK					: in std_logic;  								-- тактовый 
	MAIN_reset			: in std_logic;  								-- MAIN_reset
	MAIN_ENABLE			: in std_logic;  								-- MAIN_ENABLE
	mode_IMAGE_SENSOR	: in std_logic_vector (7 downto 0):=x"00";  			-- изменение режимов
	mode_generator		: in std_logic_vector (7 downto 0); 			--задание режима
------------------------------------выходные сигналы-----------------------------------------------------
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
end IS_SIM_Paralell;

architecture beh of IS_SIM_Paralell is 

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
	
signal ena_str_cnt				: std_logic;
signal ena_kadr_cnt				: std_logic;
signal ena_pix_IS_cnt			: std_logic;	
signal ena_pix_total_cnt		: std_logic;	
signal div_clk_in				: std_logic_vector (7 downto 0);
signal stroka_in				: std_logic;
signal kadr_in					: std_logic;
signal ena_clk_x2_in			: std_logic;
signal ena_clk_x4_in			: std_logic;
signal ena_clk_x8_in			: std_logic;
signal ena_clk_x16_in			: std_logic;
signal ena_clk_in				: std_logic;
signal qout_clk_IS				: std_logic_vector (bit_pix-1 downto 0);
signal qout_V					: std_logic_vector (bit_strok-1 downto 0);
signal max_str					: std_logic_vector (bit_strok-1 downto 0);

signal n_pix_IS_in				: std_logic_vector (bit_pix-1 downto 0);
signal START_PIX_in				: std_logic_vector (bit_pix-1 downto 0);
signal active_pix_in			: std_logic_vector (bit_pix-1 downto 0);

	-------------------------------------------------------------------------------
signal SAV_EAV_F0_V0_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F0_V0_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F0_V1_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F0_V1_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F1_V0_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F1_V0_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F1_V1_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F1_V1_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_SYNC_3FF		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_SYNC_0		: std_logic_vector (bit_data_imx-1 downto 0);
signal VALID_DATA			: std_logic;
signal data_imx_video		: std_logic_vector (bit_data_imx-1 downto 0);
signal data_imx_anc			: std_logic_vector (bit_data_imx-1 downto 0);
signal DATA_IMX_OUT_in		: std_logic_vector (bit_data_imx-1 downto 0);
-------------------------------------------------------------------------------
component PATHERN_GENERATOR is
	port (
			CLK						: in std_logic; 								--тактовый сигнал данных	
			MAIN_reset				: in std_logic;  									-- MAIN_reset
			ena_clk					: in std_logic;  									-- MAIN_reset
			qout_clk				: in std_logic_vector (bit_pix-1 downto 0); 	--счетчик пикселей
			qout_V					: in std_logic_vector (bit_strok-1 downto 0); 	--счетчик строк
			mode_generator			: in std_logic_vector (7 downto 0); 			--задание режима
			data_in					: in std_logic_vector (bit_data_imx-1 downto 0) ;			--задание режима
			data_out				: out std_logic_vector (bit_data_imx-1 downto 0) 								--сигнал валидных данных	
				);	
end component;
signal data_generator_out	: std_logic_vector (bit_data_imx-1 downto 0);
-------------------------------------------------------------------------------
signal CSI_sync_code_1		: std_logic_vector (bit_data_imx-1 downto 0);
signal CSI_sync_code_2		: std_logic_vector (bit_data_imx-1 downto 0);
signal CSI_sync_code_3		: std_logic_vector (bit_data_imx-1 downto 0);
signal CSI_sync_code_4		: std_logic_vector (bit_data_imx-1 downto 0);
signal CSI_sync_code_5		: std_logic_vector (bit_data_imx-1 downto 0);

begin
 
----------------------------------сигналы разрешения для счетчиков-----------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	if bit_data_imx=14	then
		SAV_EAV_F0_V0_H0	<=	x"80" & "000000" ;		
		SAV_EAV_F0_V0_H1	<=	x"9D" & "000000" ;		
		SAV_EAV_F0_V1_H0	<=	x"AB" & "000000" ;		
		SAV_EAV_F0_V1_H1	<=	x"B6" & "000000" ;		
		SAV_EAV_SYNC_3FF	<=	x"FF" & "111111" ;		
		SAV_EAV_SYNC_0		<=	x"00" & "000000" ;
	elsif  bit_data_imx=12	then	
		SAV_EAV_F0_V0_H0	<=	x"80" & "0000" ;		
		SAV_EAV_F0_V0_H1	<=	x"9D" & "0000" ;		
		SAV_EAV_F0_V1_H0	<=	x"AB" & "0000" ;		
		SAV_EAV_F0_V1_H1	<=	x"B6" & "0000" ;		
		SAV_EAV_SYNC_3FF	<=	x"FF" & "1111" ;		
		SAV_EAV_SYNC_0		<=	x"00" & "0000" ;
	elsif  bit_data_imx=10	then	
		SAV_EAV_F0_V0_H0	<=	x"80" & "00" ;		
		SAV_EAV_F0_V0_H1	<=	x"9D" & "00" ;		
		SAV_EAV_F0_V1_H0	<=	x"AB" & "00" ;		
		SAV_EAV_F0_V1_H1	<=	x"B6" & "00" ;		
		SAV_EAV_SYNC_3FF	<=	x"FF" & "11" ;		
		SAV_EAV_SYNC_0		<=	x"00" & "00" ;
	elsif  bit_data_imx=8	then	
		SAV_EAV_F0_V0_H0	<=	x"80" ;		
		SAV_EAV_F0_V0_H1	<=	x"9D" ;		
		SAV_EAV_F0_V1_H0	<=	x"AB" ;		
		SAV_EAV_F0_V1_H1	<=	x"B6" ;		
		SAV_EAV_SYNC_3FF	<=	x"FF" ;		
		SAV_EAV_SYNC_0		<=	x"00" ;
	end if;
end if;
end process;


Process(CLK)
begin
if rising_edge(CLK) then
	-- max_str		<=	n_strok ;
	case  mode_IMAGE_SENSOR(3 downto 0)	is
		when x"0"	=>
			n_pix_IS_in		<= std_logic_vector(to_unsigned(BION_960_960p30.PixPerLine, bit_pix)) ;	
			START_PIX_in	<= std_logic_vector(to_unsigned(BION_960_960p30.HsyncShift, bit_pix)) ;	
			active_pix_in	<= std_logic_vector(to_unsigned(BION_960_960p30.ActivePixPerLine, bit_pix)) ;				
			ena_clk_in		<= ena_clk_x2_in;			
		when x"1"	=> 
			n_pix_IS_in		<= std_logic_vector(to_unsigned(BION_960_960p30.PixPerLine, bit_pix)) ;	
			START_PIX_in	<= std_logic_vector(to_unsigned(BION_960_960p30.HsyncShift, bit_pix)) ;	
			active_pix_in	<= std_logic_vector(to_unsigned(BION_960_960p30.ActivePixPerLine, bit_pix)) ;				
			ena_clk_in		<= ena_clk_x2_in;			
		when x"2"	=> 
			n_pix_IS_in		<= std_logic_vector(to_unsigned(BION_960_960p30.PixPerLine, bit_pix)) ;	
			START_PIX_in	<= std_logic_vector(to_unsigned(BION_960_960p30.HsyncShift, bit_pix)) ;	
			active_pix_in	<= std_logic_vector(to_unsigned(BION_960_960p30.ActivePixPerLine, bit_pix)) ;				
			ena_clk_in		<= ena_clk_x2_in;			
		when x"3"	=> 
			n_pix_IS_in		<= std_logic_vector(to_unsigned(BION_960_960p30.PixPerLine, bit_pix)) ;	
			START_PIX_in	<= std_logic_vector(to_unsigned(BION_960_960p30.HsyncShift, bit_pix)) ;	
			active_pix_in	<= std_logic_vector(to_unsigned(BION_960_960p30.ActivePixPerLine, bit_pix)) ;				
			ena_clk_in		<= ena_clk_x2_in;			
		WHEN others	=>  		
			n_pix_IS_in		<= std_logic_vector(to_unsigned(BION_960_960p30.PixPerLine, bit_pix)) ;	
			START_PIX_in	<= std_logic_vector(to_unsigned(BION_960_960p30.HsyncShift, bit_pix)) ;	
			active_pix_in	<= std_logic_vector(to_unsigned(BION_960_960p30.ActivePixPerLine, bit_pix)) ;				
			ena_clk_in		<= ena_clk_x2_in;			
		END case;	
	end if;
end process;

------------------------------------счетчик тактов для формирования сигналов разрешения-----------------------------------------------------
div_clk_q: count_n_modul                    
generic map (8) 
port map (
			clk			=>	CLK,			
			reset		=>	MAIN_reset ,
			en			=>	MAIN_ENABLE,		
			modul		=> 	std_logic_vector(to_unsigned(256,8)) ,
			qout		=>	div_clk_in);
			
Process(CLK)
begin
if rising_edge(CLK) then
---------------------------------------clk в 2 раза меньше---------------------------------------
	if div_clk_in( 0)='0' 			
		then 	 ena_clk_x2_in<='1';
		else 	 ena_clk_x2_in<='0';
	end if;
---------------------------------------clk в 4 раза меньше---------------------------------------
	if div_clk_in(1 downto 0)="00"		
		then 	ena_clk_x4_in<='1';
		else  	ena_clk_x4_in<='0';
	end if;
---------------------------------------clk в 8 раза меньше---------------------------------------
	if div_clk_in(2 downto 0)="000"		
		then 	ena_clk_x8_in<='1';
		else	ena_clk_x8_in<='0';
	end if;
---------------------------------------clk в 16 раза меньше---------------------------------------
	if div_clk_in(3 downto 0)="0000"		
		then	ena_clk_x16_in<='1';
		else	ena_clk_x16_in<='0';
	end if;
end if;
end process;		
----------------------------------------------------------------------------------------------------

------------------------------------сигналы разрешения для счетчиков-----------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	ena_kadr_cnt		<=	MAIN_ENABLE	and	kadr_in	and stroka_in   ;
	ena_pix_total_cnt	<=	MAIN_ENABLE and ena_clk_in;
	ena_pix_IS_cnt		<=	MAIN_ENABLE and ena_clk_in;
	ena_str_cnt			<=	MAIN_ENABLE	and	ena_clk_in	and	stroka_in  	   ;		
end if;
end process;
----------------------------------------------------------------------------------------------------

------------------------------------счетчик пикселей по строке-----------------------------------------------------
cnt_pix_IS: count_n_modul                    
generic map (bit_pix) 
port map (
			clk			=>	CLK,			
			reset		=>	MAIN_reset ,
			en			=>	ena_pix_IS_cnt,		
			modul		=> 	n_pix_IS_in ,
			qout		=>	qout_clk_IS,
			cout		=>	stroka_in);
----------------------------------------------------------------------------------------------------

------------------------------------счетчик строк по кадру-----------------------------------------------------
cnt_str: count_n_modul                   
generic map (bit_strok) 
port map (
			clk			=>	CLK,	
			reset		=>	MAIN_reset ,
			en			=>	ena_str_cnt,
			modul		=> 	std_logic_vector(to_unsigned(BION_960_960p30.LinePerFrame, bit_strok))  ,
			qout		=>	qout_V,
			cout		=>	kadr_in);	
----------------------------------------------------------------------------------------------------


PATHERN_GENERATOR_q: PATHERN_GENERATOR                    
port map (
		CLK				=>	CLK,	
		MAIN_reset		=>	MAIN_reset ,
		ena_clk			=>	ena_clk_in,		
		qout_clk		=>	qout_clk_IS,		
		qout_V			=> 	qout_v,
		mode_generator	=>	mode_generator,
		data_in			=>	qout_clk_IS(bit_data_imx-1 downto 0),
				------�������� �������-----------
		data_out		=>	data_generator_out 
			);



----------------------------------------------------------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		data_imx_anc	<=std_logic_vector(to_unsigned(3,bit_data_imx));
		data_imx_video	<=data_generator_out(bit_data_imx-1 downto 0);
		if 		(to_integer(unsigned (qout_V))	>=	BION_960_960p30.VsyncShift)	and	(to_integer(unsigned (qout_V))	<	BION_960_960p30.VsyncShift +BION_960_960p30.ActiveLine )
			then
				if 		qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-1,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_F0_V0_H0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-2,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-3,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-4,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_SYNC_3FF;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+0,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_SYNC_3FF;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+1,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+2,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+3,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_F0_V0_H1;	VALID_DATA<='0';
				elsif	qout_clk_IS	>=START_PIX_in and qout_clk_IS	<	std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in)),bit_pix))	then DATA_IMX_OUT_in <= data_imx_video;		VALID_DATA<='1';
				else																																								 		 DATA_IMX_OUT_in <= data_imx_anc;		VALID_DATA<='0';
				end if;
			else	
			if 		qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-1,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_F0_V1_H0;	VALID_DATA<='0';
			elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-2,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
			elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-3,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
			elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-4,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_SYNC_3FF;	VALID_DATA<='0';
			elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+0,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_SYNC_3FF;	VALID_DATA<='0';
			elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+1,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
			elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+2,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
			elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+3,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_F0_V1_H1;	VALID_DATA<='0';
			else																																	 									 DATA_IMX_OUT_in <= data_imx_anc;		VALID_DATA<='0';
			end if;
		end if;
	end if;
end if;
end process;


Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		if 		(to_integer(unsigned (qout_V))	=	BION_960_960p30.VsyncShift)	
			then	XVS_Imx_Sim	<='0';
			else	XVS_Imx_Sim	<='1';
		end if;
	end if;
end if;
end process;
 
 Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		if 		(to_integer(unsigned (qout_clk_IS))	>=to_integer(unsigned (START_PIX_in))	)	and	(to_integer(unsigned (qout_clk_IS))	<	to_integer(unsigned (START_PIX_in)) +5)
			then	XHS_Imx_Sim	<='0';
			else	XHS_Imx_Sim	<='1';
		end if;
	end if;
end if;
end process;

Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		if 		(to_integer(unsigned (qout_V))	=	BION_960_960p30.VsyncShift)	
			then
				if 		qout_clk_IS	= START_PIX_in		
					then	SYNC_V			<=	'1';
					else	SYNC_V			<=	'0';
				end if;
			else	SYNC_V			<=	'0';
		end if;
	end if;
end if;
end process;

 Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		if 		qout_clk_IS	= START_PIX_in			
			then	SYNC_H			<=	'1';
			else	SYNC_H			<=	'0';
		end if;
	end if;
end if;
end process;


----------------------------------------------------------------------------
DATA_IMX_OUT 	<= DATA_IMX_OUT_in;
ena_clk_x2	 	<= ena_clk_x2_in;
ena_clk_x4	 	<= ena_clk_x4_in;
ena_clk_x8	 	<= ena_clk_x8_in;
ena_clk_x16	 	<= ena_clk_x16_in;

qout_V_out	 	<= qout_V;
qout_clk_IS_out	<= qout_clk_IS;

	

end ;
