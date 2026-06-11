-- ============================================================
-- One_Digit_Counter.vhd
-- Lab 07, Exercise 02 - Decimal counter (0-9) on Nexys A7-100T
-- One digit of the onboard 7-segment display
-- Uses clk_divider from Exercise 01 (100 MHz -> 1 Hz)
-- STANDARD VHDL library only (type bit, no std_logic)
-- ============================================================

entity One_Digit_Counter is
    port (
        CLK        : in  bit;                      -- 100 MHz board clock
        START_STOP : in  bit;                      -- switch SW0: '1' = count, '0' = pause
        CLEAR      : in  bit;                      -- button BTNC: '1' = reset to 0
        SEG        : out bit_vector(6 downto 0);   -- segments g..a (active low)
        AN         : out bit_vector(7 downto 0)    -- digit anodes (active low)
    );
end entity One_Digit_Counter;

architecture behavioral of One_Digit_Counter is

    signal clk_1hz : bit;                          -- 1 Hz counting clock
    signal count   : integer range 0 to 9 := 0;   -- current digit value

begin

    -- Clock divider from Exercise 01: 100 MHz / 100_000_000 = 1 Hz
    divider : entity work.clk_divider
        generic map ( N => 100_000_000 )
        port map (
            CLK   => CLK,
            CLK_N => clk_1hz
        );

    -- Decimal counter with asynchronous clear and enable
    counter : process (clk_1hz, CLEAR)
    begin
        if CLEAR = '1' then
            count <= 0;
        elsif clk_1hz'event and clk_1hz = '1' then
            if START_STOP = '1' then
                if count = 9 then
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process counter;

    -- 7-segment decoder, active low, order SEG(6 downto 0) = "gfedcba"
    with count select
        SEG <= "1000000" when 0,
               "1111001" when 1,
               "0100100" when 2,
               "0110000" when 3,
               "0011001" when 4,
               "0010010" when 5,
               "0000010" when 6,
               "1111000" when 7,
               "0000000" when 8,
               "0010000" when 9;

    -- Enable only the rightmost digit (AN0), all others off
    AN <= "11111110";

end architecture behavioral;
