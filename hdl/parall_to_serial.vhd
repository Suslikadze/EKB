
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.My_component_pkg.all;

entity parall_to_serial is
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
end parall_to_serial;


architecture piso_arc of parall_to_serial is
begin

    piso : process (clk,load,data) is
    variable temp : std_logic_vector (data'range);
    begin
        if (rising_edge (clk)) then
			if ena='1'	then
				if dir='0'	then
					if (load='1') 
						then temp := data ;
					else
						temp :=  '0' &  temp(bit_data-1 downto 1);
					end if;
					shiftout <= temp(0);
				else
					if (load='1') 
						then temp := data ;
					else
						temp :=   temp(bit_data-2 downto 0) & '0';
					end if;
					shiftout <= temp(bit_data-1);
				end if;
			end if;
		end if;
    end process piso;
end piso_arc;
