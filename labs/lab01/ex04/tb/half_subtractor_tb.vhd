library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HALF_SUBTRACTOR_TB is
end entity;

architecture Behavioral of HALF_SUBTRACTOR_TB is

    component HALF_SUBTRACTOR
        port (
            A    : in  std_logic;
            B    : in  std_logic;
            DIFF : out std_logic;
            BOUT : out std_logic
        );
    end component;

    signal A    : std_logic := '0';
    signal B    : std_logic := '0';
    signal DIFF : std_logic;
    signal BOUT : std_logic;

begin

    UUT: HALF_SUBTRACTOR port map (
        A    => A,
        B    => B,
        DIFF => DIFF,
        BOUT => BOUT
    );

    process
    begin
        -- Test case 1: 0-0 = 0, BOUT=0
        A <= '0'; B <= '0';
        wait for 10 ns;

        -- Test case 2: 0-1 = 1, BOUT=1 (borrow needed)
        A <= '0'; B <= '1';
        wait for 10 ns;

        -- Test case 3: 1-0 = 1, BOUT=0
        A <= '1'; B <= '0';
        wait for 10 ns;

        -- Test case 4: 1-1 = 0, BOUT=0
        A <= '1'; B <= '1';
        wait for 10 ns;

        wait; -- Stop simulation
    end process;

end architecture;