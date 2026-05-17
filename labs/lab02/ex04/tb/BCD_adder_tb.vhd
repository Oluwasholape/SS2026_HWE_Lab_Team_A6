library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD_ADDER_TB is
end entity;

architecture Behavioral of BCD_ADDER_TB is

    component BCD_ADDER
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

    UUT: BCD_ADDER port map (
        A    => A,
        B    => B,
        CIN  => CIN,
        SUM  => SUM,
        COUT => COUT
    );

    process
    begin
        -- Test 1: 0+0=0 (no correction needed)
        A <= "0000"; B <= "0000"; CIN <= '0';
        wait for 10 ns;

        -- Test 2: 3+4=7 (no correction needed)
        A <= "0011"; B <= "0100"; CIN <= '0';
        wait for 10 ns;

        -- Test 3: 5+4=9 (no correction needed, boundary case)
        A <= "0101"; B <= "0100"; CIN <= '0';
        wait for 10 ns;

        -- Test 4: 5+5=10 ? SUM=0, COUT=1 (correction needed)
        A <= "0101"; B <= "0101"; CIN <= '0';
        wait for 10 ns;

        -- Test 5: 6+7=13 ? SUM=3, COUT=1 (correction needed)
        A <= "0110"; B <= "0111"; CIN <= '0';
        wait for 10 ns;

        -- Test 6: 9+1=10 ? SUM=0, COUT=1 (correction needed)
        A <= "1001"; B <= "0001"; CIN <= '0';
        wait for 10 ns;

        -- Test 7: 9+9=18 ? SUM=8, COUT=1 (correction needed)
        A <= "1001"; B <= "1001"; CIN <= '0';
        wait for 10 ns;

        -- Test 8: 4+4+1=9 (with CIN, no correction needed)
        A <= "0100"; B <= "0100"; CIN <= '1';
        wait for 10 ns;

        -- Test 9: 5+5+1=11 ? SUM=1, COUT=1 (with CIN, correction needed)
        A <= "0101"; B <= "0101"; CIN <= '1';
        wait for 10 ns;

        wait;
    end process;

end architecture;