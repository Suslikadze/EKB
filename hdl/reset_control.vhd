library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;

entity  reset_control is
------------------------------------модуль приема данных IMX-----------------------------------------------------
port (
	CLK_in          : in std_logic;  									
	Reset_main      : in std_logic;  									
	Lock_PLL_1      : in std_logic;  									
	Lock_PLL_2      : in std_logic;  									
	Lock_PLL_3      : in std_logic;  									
	Lock_PLL_4      : in std_logic;  									
    Sync_x          : in std_logic;  									
    XHS_imx		    : in std_logic;  									
	XVS_imx		    : in std_logic;  									
	Enable_main	    : out std_logic;  									
	reset_1		    : out std_logic;  									
	reset_2		    : out std_logic;  									
	reset_3		    : out std_logic;  									
	reset_4		    : out std_logic
		);
end reset_control;


architecture beh of reset_control is 
signal Enable_main_in   : std_logic;
signal sync_V_imx       : std_logic;
signal cnt_V_imx        : integer range 0 to 15;
signal Enable_main_in_q : std_logic_vector(31 downto 0);


begin

Enable_main_in  <=  Lock_PLL_1 and Lock_PLL_2 and Lock_PLL_3 and Lock_PLL_4;   --work when ALL PLL LOCK
-- reset_1         <=not  Lock_PLL_1 or sync_V_imx;
reset_1         <=not  Enable_main_in_q(31);
reset_2         <=not  Enable_main_in_q(31);
reset_3         <=not  Lock_PLL_3;
reset_4         <=not  Lock_PLL_4;
Enable_main     <=  Enable_main_in_q(31);

process (XHS_imx)
begin
if rising_edge(XHS_imx) then
    if Enable_main_in='0'   then
        sync_V_imx  <='1';
    elsif   cnt_V_imx>=1   then
        sync_V_imx  <='0';
    end if ;
end if;
end process;

process (XHS_imx)
begin
if rising_edge(XHS_imx) then
    if Enable_main_in='0'   then
        cnt_V_imx   <=0;
    elsif   XVS_imx='0'and sync_V_imx='1'   then
        cnt_V_imx   <=cnt_V_imx+1;
    end if ;
end if;
end process;

process (CLK_in)
begin
    if  rising_edge(CLK_in) then
        for i in 0 to 30 loop
            Enable_main_in_q(i+1) <= Enable_main_in_q(i);
        end loop;
        Enable_main_in_q(0) <= Enable_main_in;
    end if;
end process;

end ;
