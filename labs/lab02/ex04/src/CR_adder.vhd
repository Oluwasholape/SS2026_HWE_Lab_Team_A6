library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CR_ADDER is
    port (
        A    : in  std_logic_vector(3 downto 0);
        B    : in  std_logic_vector(3 downto 0);
        CIN  : in  std_logic;
        SUM  : out std_logic_vector(3 downto 0);
        COUT : out std_logic
    );
end entity;

architecture Structural of CR_ADDER is

    component FULL_ADDER
        port (
            A    : in  std_logic;
            B    : in  std_logic;
            CIN  : in  std_logic;
            SUM  : out std_logic;
            COUT : out std_logic
        );
    end component;

    -- Internal carry signals between stages
    signal C0 : std_logic;
    signal C1 : std_logic;
    signal C2 : std_logic;

begin

    -- Stage 0: LSB
    FA0: FULL_ADDER port map (
        A    => A(0),
        B    => B(0),
        CIN  => CIN,
        SUM  => SUM(0),
        COUT => C0
    );

    -- Stage 1
    FA1: FULL_ADDER port map (
        A    => A(1),
        B    => B(1),
        CIN  => C0,
        SUM  => SUM(1),
        COUT => C1
    );

    -- Stage 2
    FA2: FULL_ADDER port map (
        A    => A(2),
        B    => B(2),
        CIN  => C1,
        SUM  => SUM(2),
        COUT => C2
    );

    -- Stage 3: MSB
    FA3: FULL_ADDER port map (
        A    => A(3),
        B    => B(3),
        CIN  => C2,
        SUM  => SUM(3),
        COUT => COUT
    );

end architecture;