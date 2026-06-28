library ieee;
use ieee.std_logic_1164.all;
use work.elevator_pkg.all;

entity seg7_decoder is
  port (
    floor : in  std_logic_vector(1 downto 0);
    seg   : out std_logic_vector(6 downto 0);  -- g,f,e,d,c,b,a  (active low)
    an    : out std_logic_vector(7 downto 0)   -- active low; only AN0 on
  );
end entity;

architecture rtl of seg7_decoder is
begin
  an <= "11111110";   -- light AN0 (rightmost) only

  -- seg bits:  g f e d c b a   ('0' = segment lit)
  with floor select seg <=
    "1000001" when FLOOR_U,   -- U : b c d e f       (a,g off)
    "0000110" when FLOOR_E,   -- E : a d e f g       (b,c off)
    "1111001" when FLOOR_1,   -- 1 : b c             (rest off)
    "1111111" when others;    -- blank (all segments off)
end architecture;