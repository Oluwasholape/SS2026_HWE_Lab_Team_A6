library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FULL_ADDER is
    port (
        A    : in  std_logic;
        B    : in  std_logic;
        CIN  : in  std_logic;
        SUM  : out std_logic;
        COUT : out std_logic
    );
end entity;

architecture Behavioral of FULL_ADDER is
begin
    SUM  <= A xor B xor CIN;
    COUT <= (A and B) or (B and CIN) or (A and CIN);
end architecture;