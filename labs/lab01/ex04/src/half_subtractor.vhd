library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HALF_SUBTRACTOR is
    port (
        A    : in  std_logic;
        B    : in  std_logic;
        DIFF : out std_logic;
        BOUT : out std_logic
    );
end entity;

architecture Behavioral of HALF_SUBTRACTOR is
begin
    DIFF <= A xor B;
    BOUT <= (not A) and B;
end architecture;