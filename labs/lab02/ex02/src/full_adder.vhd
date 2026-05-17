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

architecture Structural of FULL_ADDER is

    -- Declare the HALF_ADDER component (from Lab 01)
    component HALF_ADDER
        port (
            A    : in  std_logic;
            B    : in  std_logic;
            SUM  : out std_logic;
            COUT : out std_logic
        );
    end component;

    -- Internal wires connecting the two half adders
    signal SUM1  : std_logic;
    signal COUT1 : std_logic;
    signal COUT2 : std_logic;

begin

    -- First Half Adder: A + B
    HA1: HALF_ADDER port map (
        A    => A,
        B    => B,
        SUM  => SUM1,
        COUT => COUT1
    );

    -- Second Half Adder: SUM1 + CIN
    HA2: HALF_ADDER port map (
        A    => SUM1,
        B    => CIN,
        SUM  => SUM,
        COUT => COUT2
    );

    -- OR gate for final carry out
    COUT <= COUT1 or COUT2;

end architecture;
