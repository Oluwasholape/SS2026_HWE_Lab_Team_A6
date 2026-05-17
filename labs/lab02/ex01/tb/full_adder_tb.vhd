library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FULL_ADDER_TB is
end entity;

architecture Behavioral of FULL_ADDER_TB is

    component FULL_ADDER
        port (
            A    : in  std_logic;
            B    : in  std_logic;
            CIN  : in  std_logic;
            SUM  : out std_logic;
            COUT : out std_logic
        );
    end component;

    signal A    : std_logic := '0';
    signal B    : std_logic := '0';
    signal CIN  : std_logic := '0';
    signal SUM  : std_logic;
    signal COUT : std_logic;

begin

    UUT: FULL_ADDER port map (
        A    => A,
        B    => B,
        CIN  => CIN,
        SUM  => SUM,
        COUT => COUT
    );

    process
    begin
        -- Test case 1: 0+0+0 = 00
        A <= '0'; B <= '0'; CIN <= '0';
        wait for 10 ns;

        -- Test case 2: 0+0+1 = 01
        A <= '0'; B <= '0'; CIN <= '1';
        wait for 10 ns;

        -- Test case 3: 0+1+0 = 01
        A <= '0'; B <= '1'; CIN <= '0';
        wait for 10 ns;

        -- Test case 4: 0+1+1 = 10
        A <= '0'; B <= '1'; CIN <= '1';
        wait for 10 ns;

        -- Test case 5: 1+0+0 = 01
        A <= '1'; B <= '0'; CIN <= '0';
        wait for 10 ns;

        -- Test case 6: 1+0+1 = 10
        A <= '1'; B <= '0'; CIN <= '1';
        wait for 10 ns;

        -- Test case 7: 1+1+0 = 10
        A <= '1'; B <= '1'; CIN <= '0';
        wait for 10 ns;

        -- Test case 8: 1+1+1 = 11
        A <= '1'; B <= '1'; CIN <= '1';
        wait for 10 ns;

        wait;
    end process;

end architecture;