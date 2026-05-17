library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HALF_ADDER_TB is
end entity;

architecture Behavioral of HALF_ADDER_TB is

    -- Component declaration
    component HALF_ADDER
        port (
            A    : in  std_logic;
            B    : in  std_logic;
            SUM  : out std_logic;
            COUT : out std_logic
        );
    end component;

    -- Internal signals
    signal A    : std_logic := '0';
    signal B    : std_logic := '0';
    signal SUM  : std_logic;
    signal COUT : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: HALF_ADDER port map (
        A    => A,
        B    => B,
        SUM  => SUM,
        COUT => COUT
    );

    -- Stimulus process (all 4 input combinations)
    process
    begin
        -- Test case 1: A=0, B=0 ? SUM=0, COUT=0
        A <= '0'; B <= '0';
        wait for 10 ns;

        -- Test case 2: A=0, B=1 ? SUM=1, COUT=0
        A <= '0'; B <= '1';
        wait for 10 ns;

        -- Test case 3: A=1, B=0 ? SUM=1, COUT=0
        A <= '1'; B <= '0';
        wait for 10 ns;

        -- Test case 4: A=1, B=1 ? SUM=0, COUT=1
        A <= '1'; B <= '1';
        wait for 10 ns;

        wait; -- Stop simulation
    end process;

end architecture;