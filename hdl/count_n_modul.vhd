LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- Параметризируемый N разрядный счетчик
-- qout |0  ||1  ||x  |____________|m-1||0  |....   m - это модуль (modul)
-- cout ___________________________|```|_________   сигнал переполнения

ENTITY count_n_modul IS
  GENERIC (n : INTEGER:=8);
  PORT (
  clk, reset, en : IN std_logic;
  modul : IN std_logic_vector (n - 1 DOWNTO 0);
  qout : OUT std_logic_vector (n - 1 DOWNTO 0);
  cout : OUT std_logic);

END;

ARCHITECTURE beh OF count_n_modul IS
SIGNAL qint : std_logic_vector (n - 1 DOWNTO 0);
BEGIN

PROCESS (clk, reset, en)
BEGIN
IF rising_edge(clk) THEN
  qout <= qint;
  IF reset = '1' THEN
    qint <= (OTHERS => '0');
  ELSIF en = '1' THEN
    IF qint = modul - conv_std_logic_vector(1, n) THEN
      qint <= conv_std_logic_vector(0, n);
    ELSE
      qint <= qint + conv_std_logic_vector(1, n);
    END IF;

  END IF;
END IF;
END PROCESS;

PROCESS (clk, reset, en)
BEGIN
IF rising_edge(clk) THEN
  IF reset = '1'  THEN
    cout <= '0';
  ELSIF en = '1' THEN
    IF qint = modul - conv_std_logic_vector(2, n) THEN
      cout <= '1';
    ELSE
      cout <= '0';
    END IF;
  END IF;
END IF;
END PROCESS;

END;