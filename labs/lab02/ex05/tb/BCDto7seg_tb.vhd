library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCDTO7SEG_TB is
end entity;

architecture Behavioral of BCDTO7SEG_TB is

    component BCDTO7SEG
        port (
            BCD : in  std_logic_vector(3 downto 0);
            SEG : out std_logic_vector(6 downto 0)
        );
    end component;

    signal BCD : std_logic_vector(3 downto 0) := "0000";
    signal SEG : std_logic_vector(6 downto 0);

begin

    UUT: BCDTO7SEG port map (
        BCD => BCD,
        SEG => SEG
    );

    process
    begin
        -- Test digit 0: SEG = 1111110
        BCD <= "0000"; wait for 10 ns;

        -- Test digit 1: SEG = 0110000
        BCD <= "0001"; wait for 10 ns;

        -- Test digit 2: SEG = 1101101
        BCD <= "0010"; wait for 10 ns;

        -- Test digit 3: SEG = 1111001
        BCD <= "0011"; wait for 10 ns;

        -- Test digit 4: SEG = 0110011
        BCD <= "0100"; wait for 10 ns;

        -- Test digit 5: SEG = 1011011
        BCD <= "0101"; wait for 10 ns;

        -- Test digit 6: SEG = 1011111
        BCD <= "0110"; wait for 10 ns;

        -- Test digit 7: SEG = 1110000
        BCD <= "0111"; wait for 10 ns;

        -- Test digit 8: SEG = 1111111
        BCD <= "1000"; wait for 10 ns;

        -- Test digit 9: SEG = 1111011
        BCD <= "1001"; wait for 10 ns;

        -- Test invalid: SEG = 0000000
        BCD <= "1010"; wait for 10 ns;

        wait;
    end process;

end architecture;