library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FULL_SUBTRACTOR_TB is
end entity;

architecture Behavioral of FULL_SUBTRACTOR_TB is

    component FULL_SUBTRACTOR
        port (
            A    : in  std_logic;
            B    : in  std_logic;
            BIN  : in  std_logic;
            DIFF : out std_logic;
            BOUT : out std_logic
        );
    end component;

    signal A    : std_logic := '0';
    signal B    : std_logic := '0';
    signal BIN  : std_logic := '0';
    signal DIFF : std_logic;
    signal BOUT : std_logic;

begin

    UUT: FULL_SUBTRACTOR port map (
        A    => A,
        B    => B,
        BIN  => BIN,
        DIFF => DIFF,
        BOUT => BOUT
    );

    process
    begin
        -- Test case 1: 0-0-0 = 0, BOUT=0
        A <= '0'; B <= '0'; BIN <= '0';
        wait for 10 ns;

        -- Test case 2: 0-0-1 = 1, BOUT=1
        A <= '0'; B <= '0'; BIN <= '1';
        wait for 10 ns;

        -- Test case 3: 0-1-0 = 1, BOUT=1
        A <= '0'; B <= '1'; BIN <= '0';
        wait for 10 ns;

        -- Test case 4: 0-1-1 = 0, BOUT=1
        A <= '0'; B <= '1'; BIN <= '1';
        wait for 10 ns;

        -- Test case 5: 1-0-0 = 1, BOUT=0
        A <= '1'; B <= '0'; BIN <= '0';
        wait for 10 ns;

        -- Test case 6: 1-0-1 = 0, BOUT=0
        A <= '1'; B <= '0'; BIN <= '1';
        wait for 10 ns;

        -- Test case 7: 1-1-0 = 0, BOUT=0
        A <= '1'; B <= '1'; BIN <= '0';
        wait for 10 ns;

        -- Test case 8: 1-1-1 = 1, BOUT=1
        A <= '1'; B <= '1'; BIN <= '1';
        wait for 10 ns;

        wait; -- Stop simulation
    end process;

end architecture;