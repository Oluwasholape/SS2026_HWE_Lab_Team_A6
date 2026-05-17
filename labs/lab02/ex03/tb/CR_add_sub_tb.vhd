library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CR_ADD_SUB_TB is
end entity;

architecture Behavioral of CR_ADD_SUB_TB is

    component CR_ADD_SUB
        port (
            A   : in  std_logic_vector(3 downto 0);
            B   : in  std_logic_vector(3 downto 0);
            SUB : in  std_logic;
            SUM : out std_logic_vector(3 downto 0);
            COUT: out std_logic
        );
    end component;

    signal A    : std_logic_vector(3 downto 0) := "0000";
    signal B    : std_logic_vector(3 downto 0) := "0000";
    signal SUB  : std_logic := '0';
    signal SUM  : std_logic_vector(3 downto 0);
    signal COUT : std_logic;

begin

    UUT: CR_ADD_SUB port map (
        A    => A,
        B    => B,
        SUB  => SUB,
        SUM  => SUM,
        COUT => COUT
    );

    process
    begin
        -- ADDITION TESTS (SUB=0)
        -- Test 1: 0+0=0
        A <= "0000"; B <= "0000"; SUB <= '0';
        wait for 10 ns;

        -- Test 2: 5+3=8
        A <= "0101"; B <= "0011"; SUB <= '0';
        wait for 10 ns;

        -- Test 3: 7+7=14
        A <= "0111"; B <= "0111"; SUB <= '0';
        wait for 10 ns;

        -- Test 4: 15+1=16 (COUT=1, SUM=0)
        A <= "1111"; B <= "0001"; SUB <= '0';
        wait for 10 ns;

        -- SUBTRACTION TESTS (SUB=1)
        -- Test 5: 5-3=2
        A <= "0101"; B <= "0011"; SUB <= '1';
        wait for 10 ns;

        -- Test 6: 7-7=0
        A <= "0111"; B <= "0111"; SUB <= '1';
        wait for 10 ns;

        -- Test 7: 15-1=14
        A <= "1111"; B <= "0001"; SUB <= '1';
        wait for 10 ns;

        -- Test 8: 3-5 (underflow, result is negative in two's complement)
        A <= "0011"; B <= "0101"; SUB <= '1';
        wait for 10 ns;

        wait;
    end process;

end architecture;