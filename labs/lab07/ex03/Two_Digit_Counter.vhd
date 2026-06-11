-- ============================================================
-- Two_Digit_Counter.vhd
-- Lab 07, Exercise 03 - Two-digit decimal counter (00-99)
-- Nexys A7-100T, multiplexed 7-segment display (AN0 = units,
-- AN1 = tens)
-- Uses clk_divider from Exercise 01 twice:
--   - 1 Hz   counting clock
--   - 1 kHz  display refresh clock
-- STANDARD VHDL library only (type bit, no std_logic)
-- ============================================================

entity Two_Digit_Counter is
    port (
        CLK        : in  bit;                      -- 100 MHz board clock
        START_STOP : in  bit;                      -- switch SW0: '1' = count, '0' = pause
        CLEAR      : in  bit;                      -- button BTNC: '1' = reset to 00
        SEG        : out bit_vector(6 downto 0);   -- segments g..a (active low)
        AN         : out bit_vector(7 downto 0)    -- digit anodes (active low)
    );
end entity Two_Digit_Counter;

architecture behavioral of Two_Digit_Counter is

    signal clk_1hz   : bit;                        -- counting clock
    signal clk_1khz  : bit;                        -- display refresh clock

    signal units     : integer range 0 to 9 := 0; -- ones digit
    signal tens      : integer range 0 to 9 := 0; -- tens digit

    signal digit_sel : bit := '0';                 -- which digit is active
    signal digit_val : integer range 0 to 9;      -- value shown right now

begin

    -- 100 MHz / 100_000_000 = 1 Hz (counting)
    divider_count : entity work.clk_divider
        generic map ( N => 100_000_000 )
        port map ( CLK => CLK, CLK_N => clk_1hz );

    -- 100 MHz / 100_000 = 1 kHz (display multiplexing)
    divider_refresh : entity work.clk_divider
        generic map ( N => 100_000 )
        port map ( CLK => CLK, CLK_N => clk_1khz );

    -- Two-digit decimal counter 00..99 with async clear and enable
    counter : process (clk_1hz, CLEAR)
    begin
        if CLEAR = '1' then
            units <= 0;
            tens  <= 0;
        elsif clk_1hz'event and clk_1hz = '1' then
            if START_STOP = '1' then
                if units = 9 then
                    units <= 0;
                    if tens = 9 then
                        tens <= 0;          -- 99 -> 00
                    else
                        tens <= tens + 1;   -- carry into tens
                    end if;
                else
                    units <= units + 1;
                end if;
            end if;
        end if;
    end process counter;

    -- Display multiplexing: alternate between the two digits at 1 kHz
    -- (each digit is on 500 times per second -> no visible flicker)
    mux_sel : process (clk_1khz)
    begin
        if clk_1khz'event and clk_1khz = '1' then
            digit_sel <= not digit_sel;
        end if;
    end process mux_sel;

    -- Select the value and the anode of the active digit
    digit_val <= units when digit_sel = '0' else tens;
    AN        <= "11111110" when digit_sel = '0' else  -- AN0: units
                 "11111101";                            -- AN1: tens

    -- 7-segment decoder, active low, order SEG(6 downto 0) = "gfedcba"
    with digit_val select
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

end architecture behavioral;
