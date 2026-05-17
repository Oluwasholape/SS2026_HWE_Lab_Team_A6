library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD_ADDER is
    port (
        A    : in  std_logic_vector(3 downto 0);
        B    : in  std_logic_vector(3 downto 0);
        CIN  : in  std_logic;
        SUM  : out std_logic_vector(3 downto 0);
        COUT : out std_logic
    );
end entity;

architecture Structural of BCD_ADDER is

    component CR_ADDER
        port (
            A    : in  std_logic_vector(3 downto 0);
            B    : in  std_logic_vector(3 downto 0);
            CIN  : in  std_logic;
            SUM  : out std_logic_vector(3 downto 0);
            COUT : out std_logic
        );
    end component;

    -- Raw sum from first addition
    signal SUM1    : std_logic_vector(3 downto 0);
    signal COUT1   : std_logic;

    -- Correction signal
    signal CORRECT : std_logic;

    -- Correction value (0110 when needed, 0000 when not)
    signal CORR_VAL : std_logic_vector(3 downto 0);

begin

    -- Stage 1: Regular binary addition A + B
    ADDER1: CR_ADDER port map (
        A    => A,
        B    => B,
        CIN  => CIN,
        SUM  => SUM1,
        COUT => COUT1
    );

    -- Correction needed if result > 9 or carry out
    CORRECT <= COUT1 or
               (SUM1(3) and SUM1(2)) or
               (SUM1(3) and SUM1(1));

    -- Correction value: 0110 if correction needed, 0000 if not
    CORR_VAL(0) <= '0';
    CORR_VAL(1) <= CORRECT;
    CORR_VAL(2) <= CORRECT;
    CORR_VAL(3) <= '0';

    -- Stage 2: Add correction value to raw sum
    ADDER2: CR_ADDER port map (
        A    => SUM1,
        B    => CORR_VAL,
        CIN  => '0',
        SUM  => SUM,
        COUT => open
    );

    -- Final carry out
    COUT <= CORRECT;

end architecture;