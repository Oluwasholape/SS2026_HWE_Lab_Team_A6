 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HALF_ADDER is
    port (
        A    : in  std_logic;
        B    : in  std_logic;
        SUM  : out std_logic;
        COUT : out std_logic
    );
end entity;

architecture Behavioral of HALF_ADDER is
begin
    SUM  <= A xor B;
    COUT <= A and B;
end architecture;
