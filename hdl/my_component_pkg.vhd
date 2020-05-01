library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package   My_component_pkg	is

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

----------------------------------------------------------------------------------
---модуль генерации TRS кодов для синхронизации видео согласно рекомендациям ITU-R
----------------------------------------------------------------------------------
component TRS_gen is
generic  (
	bit_data		: integer
	);
port (
------------------------------------входные сигналы---------------
	CLK				: in std_logic;  	   -- тактовый от гнератора
------------------------------------выходные сигналы-----------
	TRS_SYNC_3FF   : out std_logic_vector (bit_data-1 downto 0);
	TRS_SYNC_0     : out std_logic_vector (bit_data-1 downto 0);
	TRS_F0_V0_H0   : out std_logic_vector (bit_data-1 downto 0);
	TRS_F0_V0_H1   : out std_logic_vector (bit_data-1 downto 0);
	TRS_F0_V1_H0   : out std_logic_vector (bit_data-1 downto 0);
	TRS_F0_V1_H1   : out std_logic_vector (bit_data-1 downto 0);
	TRS_F1_V0_H0   : out std_logic_vector (bit_data-1 downto 0);
	TRS_F1_V0_H1   : out std_logic_vector (bit_data-1 downto 0);
	TRS_F1_V1_H0   : out std_logic_vector (bit_data-1 downto 0);
	TRS_F1_V1_H1   : out std_logic_vector (bit_data-1 downto 0)
	);
end component;

end package ;
