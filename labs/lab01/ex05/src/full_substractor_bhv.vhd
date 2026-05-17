library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FULL_SUBTRACTOR is
    port (
        A    : in  std_logic;
        B    : in  std_logic;
        BIN  : in  std_logic;
        DIFF : out std_logic;
        BOUT : out std_logic
    );
end entity;

architecture Behavioral of FULL_SUBTRACTOR is
begin
    DIFF <= A xor B xor BIN;
    BOUT <= ((not A) and B) or ((not A) and BIN) or (B and BIN);
end architecture;