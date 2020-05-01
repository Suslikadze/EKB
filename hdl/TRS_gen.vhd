library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
----------------------------------------------------------------------------------
---модуль генерации TRS кодов для синхронизации видео согласно рекомендациям ITU-R
----------------------------------------------------------------------------------
entity TRS_gen is
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
end TRS_gen;

architecture beh of TRS_gen is 

begin

Process(CLK)
begin
if rising_edge(CLK) then   

   if bit_data = 14	then
      TRS_F0_V0_H0	<=	x"80" & "000000" ;		
      TRS_F0_V0_H1	<=	x"9D" & "000000" ;		
      TRS_F0_V1_H0	<=	x"AB" & "000000" ;		
      TRS_F0_V1_H1	<=	x"B6" & "000000" ;		
      TRS_F1_V0_H0	<=	x"C7" & "000000" ;		
      TRS_F1_V0_H1	<=	x"DA" & "000000" ;		
      TRS_F1_V1_H0	<=	x"EC" & "000000" ;		
      TRS_F1_V1_H1	<=	x"F1" & "000000" ;		
      TRS_SYNC_3FF	<=	x"FF" & "111111" ;		
      TRS_SYNC_0		<=	x"00" & "000000" ;
   elsif  bit_data = 12	then	
      TRS_F0_V0_H0	<=	x"80" & "0000" ;		
      TRS_F0_V0_H1	<=	x"9D" & "0000" ;		
      TRS_F0_V1_H0	<=	x"AB" & "0000" ;		
      TRS_F0_V1_H1	<=	x"B6" & "0000" ;		
      TRS_F1_V0_H0	<=	x"C7" & "0000" ;		
      TRS_F1_V0_H1	<=	x"DA" & "0000" ;		
      TRS_F1_V1_H0	<=	x"EC" & "0000" ;		
      TRS_F1_V1_H1	<=	x"F1" & "0000" ;		
      TRS_SYNC_3FF	<=	x"FF" & "1111" ;		
      TRS_SYNC_0		<=	x"00" & "0000" ;
   elsif  bit_data = 10	then	
      TRS_F0_V0_H0	<=	x"80" & "00" ;		
      TRS_F0_V0_H1	<=	x"9D" & "00" ;		
      TRS_F0_V1_H0	<=	x"AB" & "00" ;		
      TRS_F0_V1_H1	<=	x"B6" & "00" ;		
      TRS_F1_V0_H0	<=	x"C7" & "00" ;		
      TRS_F1_V0_H1	<=	x"DA" & "00" ;		
      TRS_F1_V1_H0	<=	x"EC" & "00" ;		
      TRS_F1_V1_H1	<=	x"F1" & "00" ;		
      TRS_SYNC_3FF	<=	x"FF" & "11" ;		
      TRS_SYNC_0		<=	x"00" & "00" ;
   elsif  bit_data = 8	then	
      TRS_F0_V0_H0	<=	x"80" ;		
      TRS_F0_V0_H1	<=	x"9D" ;		
      TRS_F0_V1_H0	<=	x"AB" ;		
      TRS_F0_V1_H1	<=	x"B6" ;		
      TRS_F1_V0_H0	<=	x"C7" ;		
      TRS_F1_V0_H1	<=	x"DA" ;		
      TRS_F1_V1_H0	<=	x"EC" ;		
      TRS_F1_V1_H1	<=	x"F1" ;		
      TRS_SYNC_3FF	<=	x"FF" ;		
      TRS_SYNC_0		<=	x"00" ;
   end if;
end if;
end process;

end ;

