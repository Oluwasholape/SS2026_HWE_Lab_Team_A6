library ieee;
use ieee.std_logic_1164.all;
use work.elevator_pkg.all;

entity tb_timer_unit is
end entity;

architecture sim of tb_timer_unit is
  constant CLK_PERIOD : time     := 10 ns;   -- 100 MHz
  constant TRAVEL_C   : positive := 10;      -- N-test: tiny values for fast sim
  constant DOOR_C     : positive := 20;

  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal start : std_logic := '0';
  signal mode  : timer_mode_t := TMR_TRAVEL;
  signal done  : std_logic;
  signal sim_done : boolean := false;
begin
  dut : entity work.timer_unit
    generic map ( TRAVEL_CYCLES => TRAVEL_C, DOOR_CYCLES => DOOR_C )
    port map ( clk => clk, rst => rst, start => start, mode => mode, done => done );

  clk_gen : process
  begin
    while not sim_done loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  stim : process
    variable t0 : time;
  begin
    rst <= '1';
    wait for 3 * CLK_PERIOD;
    rst <= '0';
    wait until rising_edge(clk);

    -- Test 1: TRAVEL mode
    mode  <= TMR_TRAVEL;
    start <= '1';
    wait until rising_edge(clk);          -- DUT samples start on this edge
    start <= '0';
    t0 := now;
    wait until done = '1' for 100 * CLK_PERIOD;
    assert done = '1'
      report "Test 1 FAIL: TRAVEL done never asserted" severity error;
    assert (now - t0) = TRAVEL_C * CLK_PERIOD
      report "Test 1 FAIL: TRAVEL expected " & time'image(TRAVEL_C*CLK_PERIOD) &
             ", got " & time'image(now - t0) severity error;
    report "Test 1 PASS: TRAVEL done after " & time'image(now - t0) severity note;

    wait for 5 * CLK_PERIOD;

    -- Test 2: DOOR mode
    mode  <= TMR_DOOR;
    start <= '1';
    wait until rising_edge(clk);
    start <= '0';
    t0 := now;
    wait until done = '1' for 100 * CLK_PERIOD;
    assert done = '1'
      report "Test 2 FAIL: DOOR done never asserted" severity error;
    assert (now - t0) = DOOR_C * CLK_PERIOD
      report "Test 2 FAIL: DOOR expected " & time'image(DOOR_C*CLK_PERIOD) &
             ", got " & time'image(now - t0) severity error;
    report "Test 2 PASS: DOOR done after " & time'image(now - t0) severity note;

    report "=== ALL TIMER TESTS COMPLETE ===" severity note;
    sim_done <= true;
    wait;
  end process;
end architecture;