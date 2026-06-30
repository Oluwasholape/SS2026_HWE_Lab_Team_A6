library ieee;
use ieee.std_logic_1164.all;

entity tb_debouncer is
end entity;

architecture sim of tb_debouncer is
  constant CLK_PERIOD : time     := 10 ns;
  constant DB_CYCLES  : positive := 5;       -- N-test: tiny debounce window

  signal clk      : std_logic := '0';
  signal rst      : std_logic := '1';
  signal btn_raw  : std_logic := '0';
  signal btn_edge : std_logic;
  signal sim_done : boolean   := false;
  signal edge_count : natural := 0;
begin
  dut : entity work.debouncer
    generic map ( DEBOUNCE_CYCLES => DB_CYCLES )
    port map ( clk => clk, rst => rst, btn_raw => btn_raw, btn_edge => btn_edge );

  clk_gen : process
  begin
    while not sim_done loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  counter_proc : process(clk)
  begin
    if rising_edge(clk) then
      if btn_edge = '1' then
        edge_count <= edge_count + 1;
      end if;
    end if;
  end process;

  stim : process
  begin
    rst <= '1';
    wait for 3 * CLK_PERIOD;
    rst <= '0';
    wait for 2 * CLK_PERIOD;

    -- Test 1: clean press -> exactly 1 pulse
    btn_raw <= '1';
    wait for 15 * CLK_PERIOD;
    assert edge_count = 1
      report "Test 1 FAIL: clean press expected 1, got " &
             integer'image(edge_count) severity error;
    report "Test 1 PASS: clean press -> 1 pulse" severity note;
    btn_raw <= '0';
    wait for 15 * CLK_PERIOD;

    -- Test 2: bouncy press -> still only 1 new pulse (total 2)
    btn_raw <= '1'; wait for 2 * CLK_PERIOD;
    btn_raw <= '0'; wait for 1 * CLK_PERIOD;
    btn_raw <= '1'; wait for 1 * CLK_PERIOD;
    btn_raw <= '0'; wait for 2 * CLK_PERIOD;
    btn_raw <= '1';
    wait for 15 * CLK_PERIOD;
    assert edge_count = 2
      report "Test 2 FAIL: bouncy press expected 2, got " &
             integer'image(edge_count) severity error;
    report "Test 2 PASS: bounces collapsed into 1 pulse" severity note;
    btn_raw <= '0';
    wait for 15 * CLK_PERIOD;

    -- Test 3: short glitch -> no new pulse (still 2)
    btn_raw <= '1'; wait for 2 * CLK_PERIOD;
    btn_raw <= '0';
    wait for 15 * CLK_PERIOD;
    assert edge_count = 2
      report "Test 3 FAIL: glitch expected 2 (no new), got " &
             integer'image(edge_count) severity error;
    report "Test 3 PASS: short glitch rejected" severity note;

    report "=== ALL DEBOUNCER TESTS COMPLETE ===" severity note;
    sim_done <= true;
    wait;
  end process;
end architecture;