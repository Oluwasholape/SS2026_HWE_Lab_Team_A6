-- ============================================================
-- clk_divider_tb.vhd
-- Lab 07, Exercise 01 - Testbench for clk_divider
-- Verifies that CLK_N has a period N times longer than CLK
-- STANDARD VHDL library only
-- ============================================================

entity clk_divider_tb is
end entity clk_divider_tb;

architecture testbench of clk_divider_tb is

    constant N_TEST     : positive := 10;     -- small N so the result is easy to see
    constant CLK_PERIOD : time     := 10 ns;  -- 100 MHz main clock (like Nexys A7)

    signal clk_tb   : bit := '0';
    signal clk_n_tb : bit;

    signal sim_done : boolean := false;

begin

    -- Device under test
    dut : entity work.clk_divider
        generic map ( N => N_TEST )
        port map (
            CLK   => clk_tb,
            CLK_N => clk_n_tb
        );

    -- Main clock generation (stops when simulation is done)
    clk_gen : process
    begin
        while not sim_done loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process clk_gen;

    -- Check: measure one full period of CLK_N and compare with N * CLK_PERIOD
    check : process
        variable t_rise1 : time;
        variable t_rise2 : time;
    begin
        -- wait for two consecutive rising edges of CLK_N
        wait until clk_n_tb'event and clk_n_tb = '1';
        t_rise1 := now;
        wait until clk_n_tb'event and clk_n_tb = '1';
        t_rise2 := now;

        assert (t_rise2 - t_rise1) = N_TEST * CLK_PERIOD
            report "ERROR: CLK_N period is wrong!"
            severity error;

        assert (t_rise2 - t_rise1) /= N_TEST * CLK_PERIOD
            report "PASS: CLK_N period = N * CLK period as expected."
            severity note;

        -- let it run a bit longer for the waveform, then stop
        wait for 5 * N_TEST * CLK_PERIOD;
        sim_done <= true;
        wait;
    end process check;

end architecture testbench;