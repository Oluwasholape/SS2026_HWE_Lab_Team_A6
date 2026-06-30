library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_pkg.all;

entity tb_elevator_fsm is
end entity;

architecture sim of tb_elevator_fsm is
  constant CLK_PERIOD : time := 10 ns;

  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';
  signal call_1     : std_logic := '0';
  signal call_e     : std_logic := '0';
  signal call_u     : std_logic := '0';
  signal timer_done : std_logic;
  signal timer_start: std_logic;
  signal timer_mode : timer_mode_t;
  signal current_floor : std_logic_vector(1 downto 0);
  signal led_up, led_down, led_door : std_logic;
  signal sim_done   : boolean := false;
begin
  dut : entity work.elevator_fsm
    port map (
      clk => clk, rst => rst,
      call_1 => call_1, call_e => call_e, call_u => call_u,
      timer_done => timer_done,
      timer_start => timer_start, timer_mode => timer_mode,
      current_floor => current_floor,
      led_up => led_up, led_down => led_down, led_door => led_door );

  tmr : entity work.timer_unit                 -- real timer, N-test generics
    generic map ( TRAVEL_CYCLES => 4, DOOR_CYCLES => 6 )
    port map ( clk => clk, rst => rst, start => timer_start,
               mode => timer_mode, done => timer_done );

  clk_gen : process
  begin
    while not sim_done loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  stim : process
  begin
    rst <= '1';
    wait for 4 * CLK_PERIOD;
    wait until rising_edge(clk);
    rst <= '0';
    wait until rising_edge(clk);

    assert current_floor = "01"
      report "FAIL: after reset expected E (01)" severity error;
    report "PASS: reset at E" severity note;

    -- Tie test: at E, request U and 1 together -> serve 1 first (up), then U
    call_u <= '1'; call_1 <= '1';
    wait until rising_edge(clk);
    call_u <= '0'; call_1 <= '0';

    wait until led_door = '1' for 200 * CLK_PERIOD;
    assert led_door = '1' report "FAIL: first door never opened" severity error;
    assert current_floor = "10"
      report "FAIL: tie should serve floor 1 first, got " &
             integer'image(to_integer(unsigned(current_floor))) severity error;
    report "PASS: tie served floor 1 first (up)" severity note;

    wait until led_door = '0' for 200 * CLK_PERIOD;

    wait until led_door = '1' for 200 * CLK_PERIOD;
    assert current_floor = "00"
      report "FAIL: second stop should be U (00)" severity error;
    report "PASS: then served U" severity note;

    wait until led_door = '0' for 200 * CLK_PERIOD;

    -- From U, request E -> one step up
    call_e <= '1';
    wait until rising_edge(clk);
    call_e <= '0';

    wait until led_door = '1' for 200 * CLK_PERIOD;
    assert current_floor = "01"
      report "FAIL: should stop at E (01)" severity error;
    report "PASS: served E" severity note;

    report "=== ALL FSM TESTS COMPLETE ===" severity note;
    sim_done <= true;
    wait;
  end process;
end architecture;