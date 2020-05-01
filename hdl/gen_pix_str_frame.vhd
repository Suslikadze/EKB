library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
----------------------------------------------------------------------
---модуль генерации пикселей/строк/кадров
----------------------------------------------------------------------
entity gen_pix_str_frame is
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
end gen_pix_str_frame;

architecture beh of gen_pix_str_frame is 
signal ena_clk_in		: std_logic:='0';
signal ena_pix_cnt		: std_logic:='0';
signal ena_str_cnt		: std_logic:='0';
signal ena_kadr_cnt		: std_logic:='0';
signal div_clk_in			: std_logic_vector (7 downto 0);
signal stroka_in			: std_logic:='0';
signal kadr_in				: std_logic:='0';
signal ena_clk_x_q_in	: std_logic_vector (3 downto 0):=(Others => '0');

begin

----------------------------------------------------------------------
--счетчик тактов для формирования сигналов разрешения и деления частоты
----------------------------------------------------------------------
div_clk_q: count_n_modul                    
generic map (8) 
port map (
	clk		=>	CLK,			
	reset		=>	reset ,
	en			=>	MAIN_ENABLE,		
	modul		=>	std_logic_vector(to_unsigned(256,8)) ,
	qout		=>	div_clk_in);
			
Process(CLK)
begin
if rising_edge(CLK) then
	--clk в 2 раза меньше--	
	if div_clk_in( 0)='0' 	then 
		ena_clk_x_q_in(0)	<='1';		ena_clk_x_q(0)	<='1';
	else 
		ena_clk_x_q_in(0)	<='0';		ena_clk_x_q(0)	<='0';
	end if;
	--clk в 4 раза меньше--	
	if div_clk_in(1 downto 0)="00"	then	
		ena_clk_x_q_in(1)	<='1';		ena_clk_x_q(1)	<='1';
	else 	
		ena_clk_x_q_in(1)	<='0';		ena_clk_x_q(1)	<='0';
	end if;
	--clk в 8 раза меньше--	
	if div_clk_in(2 downto 0)="000"		then	
		ena_clk_x_q_in(2)	<='1';		ena_clk_x_q(2)	<='1';
	else 	
		ena_clk_x_q_in(2)	<='0';		ena_clk_x_q(2)	<='0';
	end if;
	--clk в 16 раза меньше--	
	if div_clk_in(3 downto 0)="0000"	then		
		ena_clk_x_q_in(3)	<='1';		ena_clk_x_q(3)	<='1';
	else 	
		ena_clk_x_q_in(3)	<='0';		ena_clk_x_q(3)	<='0';
	end if;
end if;
end process;		
----------------------------------------------------------------------

Process(CLK)
begin
if rising_edge(CLK) then
	case  mode_sync_gen(3 downto 0)	is
		when x"0"	=>	ena_clk_in		<= '1';			
		when x"1"	=>	ena_clk_in		<= ena_clk_x_q_in(0);			
		when x"2"	=>	ena_clk_in		<= ena_clk_x_q_in(1);			
		when x"3"	=>	ena_clk_in		<= ena_clk_x_q_in(2);			
		WHEN others	=>	ena_clk_in		<= '1';			
		END case;	
	end if;
end process;

----------------------------------------------------------------------
--сигналы разрешения для счетчиков
----------------------------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	ena_kadr_cnt	<=	kadr_in and stroka_in  and MAIN_ENABLE	and ena_clk_in;
	ena_pix_cnt		<=	MAIN_ENABLE and ena_clk_in;
	ena_str_cnt 	<=	stroka_in  and MAIN_ENABLE and ena_clk_in;	
end if;
end process;
----------------------------------------------------------------------

----------------------------------------------------------------------
--счетчики пикселей /строк / кадров
----------------------------------------------------------------------

cnt_pix_IS: count_n_modul	--счетчик пикселей по строке--       
generic map (bit_pix) 
port map (
	clk		=>	CLK,			
	reset		=>	reset ,
	en			=>	ena_pix_cnt,		
	modul		=>	std_logic_vector(to_unsigned(PixPerLine, bit_pix))  ,
	qout		=>	qout_clk,
	cout		=>	stroka_in);

cnt_str: count_n_modul     	--счетчик строк по кадру                   
generic map (bit_strok) 
port map (
	clk		=>	CLK,	
	reset		=>	reset ,
	en			=>	ena_str_cnt,
	modul		=>	std_logic_vector(to_unsigned(LinePerFrame, bit_strok))  ,
	qout		=>	qout_V,
	cout		=>	kadr_in);	

cnt_frame: count_n_modul    	--счетчик кадров                    
generic map (bit_frame) 
port map (
	clk		=>	CLK,	
	reset		=>	reset ,
	en			=>	ena_kadr_cnt,
	modul		=>	std_logic_vector(to_unsigned(256, bit_frame))  ,
	qout		=>	qout_frame);	
----------------------------------------------------------------------

----------------------------------------------------------------------
--выходные сигналы
----------------------------------------------------------------------

Process(CLK)
begin
if rising_edge(CLK) then
--выходные сигналы--
	kadr		<= kadr_in;
	stroka	<= stroka_in;
end if;
end process;

end ;

