library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCDTO7SEG is
    port (
        BCD : in  std_logic_vector(3 downto 0);
        SEG : out std_logic_vector(6 downto 0)
    );
end entity;

architecture Behavioral of BCDTO7SEG is

begin

    -- SEG = (A, B, C, D, E, F, G)
    -- 1 = segment ON, 0 = segment OFF
    with BCD select
        SEG <= "1111110" when "0000",  -- 0
               "0110000" when "0001",  -- 1
               "1101101" when "0010",  -- 2
               "1111001" when "0011",  -- 3
               "0110011" when "0100",  -- 4
               "1011011" when "0101",  -- 5
               "1011111" when "0110",  -- 6
               "1110000" when "0111",  -- 7
               "1111111" when "1000",  -- 8
               "1111011" when "1001",  -- 9
               "0000000" when others;  -- invalid BCD

end architecture;
