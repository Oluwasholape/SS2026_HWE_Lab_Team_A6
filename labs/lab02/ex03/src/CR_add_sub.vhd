library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CR_ADD_SUB is
    port (
        A   : in  std_logic_vector(3 downto 0);
        B   : in  std_logic_vector(3 downto 0);
        SUB : in  std_logic;
        SUM : out std_logic_vector(3 downto 0);
        COUT: out std_logic
    );
end entity;

architecture Structural of CR_ADD_SUB is

    component CR_ADDER
        port (
            A    : in  std_logic_vector(3 downto 0);
            B    : in  std_logic_vector(3 downto 0);
            CIN  : in  std_logic;
            SUM  : out std_logic_vector(3 downto 0);
            COUT : out std_logic
        );
    end component;

    -- B after XOR with SUB
    signal B_XOR : std_logic_vector(3 downto 0);

begin

    -- XOR each bit of B with SUB
    -- SUB=0: B passes unchanged (addition)
    -- SUB=1: B gets inverted (subtraction step 1)
    B_XOR(0) <= B(0) xor SUB;
    B_XOR(1) <= B(1) xor SUB;
    B_XOR(2) <= B(2) xor SUB;
    B_XOR(3) <= B(3) xor SUB;

    -- SUB also drives CIN
    -- SUB=1 adds the +1 needed for two's complement
    ADDSUB: CR_ADDER port map (
        A    => A,
        B    => B_XOR,
        CIN  => SUB,
        SUM  => SUM,
        COUT => COUT
    );

end architecture;