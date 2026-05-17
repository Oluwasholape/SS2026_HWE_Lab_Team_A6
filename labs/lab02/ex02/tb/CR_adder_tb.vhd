library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CR_ADDER_TB is
end entity;

architecture Behavioral of CR_ADDER_TB is

    component CR_ADDER
        port (
            A    : in  std_logic_vector(3 downto 0);
            B    : in  std_logic_vector(3 downto 0);
            CIN  : in  std_logic;
            SUM  : out std_logic_vector(3 downto 0);
            COUT : out std_logic
        );
    end component;

    signal A    : std_logic_vector(3 downto 0) := "0000";
    signal B    : std_logic_vector(3 downto 0) := "0000";
    signal CIN  : std_logic := '0';
    signal SUM  : std_logic_vector(3 downto 0);
    signal COUT : std_logic;

begin

    UUT: CR_ADDER port map (
        A    => A,
        B    => B,
        CIN  => CIN,
        SUM  => SUM,
        COUT => COUT
    );

    process
    begin
        -- Test 1: 0+0=0
        A <= "0000"; B <= "0000"; CIN <= '0';
        wait for 10 ns;

        -- Test 2: 1+1=2
        A <= "0001"; B <= "0001"; CIN <= '0';
        wait for 10 ns;

        -- Test 3: 5+3=8
        A <= "0101"; B <= "0011"; CIN <= '0';
        wait for 10 ns;

        -- Test 4: 7+7=14
        A <= "0111"; B <= "0111"; CIN <= '0';
        wait for 10 ns;

        -- Test 5: 15+1=16 (COUT=1, SUM=0000)
        A <= "1111"; B <= "0001"; CIN <= '0';
        wait for 10 ns;

        -- Test 6: 15+15=30 (COUT=1, SUM=1110)
        A <= "1111"; B <= "1111"; CIN <= '0';
        wait for 10 ns;

        -- Test 7: with CIN=1, 5+3+1=9
        A <= "0101"; B <= "0011"; CIN <= '1';
        wait for 10 ns;

        -- Test 8: 15+15+1=31 (COUT=1, SUM=1111)
        A <= "1111"; B <= "1111"; CIN <= '1';
        wait for 10 ns;

        wait;
    end process;

end architecture;