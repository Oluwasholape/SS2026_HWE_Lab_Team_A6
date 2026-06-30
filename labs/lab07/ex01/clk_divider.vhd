-- ============================================================
-- clk_divider.vhd
-- Lab 07, Exercise 01 - Clock Divider
-- Generates CLK_N with frequency = f(CLK) / N
-- STANDARD VHDL library only (type bit, no std_logic)
-- ============================================================

entity clk_divider is
    generic (
        N : positive := 100_000_000   -- division factor (use even N for 50% duty cycle)
    );
    port (
        CLK   : in  bit;   -- main clock from oscillator
        CLK_N : out bit    -- divided clock, f = f_CLK / N
    );
end entity clk_divider;

architecture behavioral of clk_divider is
    signal clk_int : bit := '0';
    signal count   : natural range 0 to N/2 - 1 := 0;
begin

    -- Toggle the internal clock every N/2 rising edges of CLK.
    -- One full period of CLK_N therefore lasts N periods of CLK.
    divide : process (CLK)
    begin
        if CLK'event and CLK = '1' then
            if count = N/2 - 1 then
                count   <= 0;
                clk_int <= not clk_int;
            else
                count <= count + 1;
            end if;
        end if;
    end process divide;

    CLK_N <= clk_int;

end architecture behavioral;
