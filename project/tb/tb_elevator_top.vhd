library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_pkg.all;

entity tb_elevator_top is
end entity;

architecture sim of tb_elevator_top is
  constant CLK_PERIOD : time := 10 ns;

  -- glyph constants (active-low seg patterns, same as seg7_decoder)
  constant GLYPH_U : std_logic_vector(6 downto 0) := "1000001";
  constant GLYPH_E : std_logic_vector(6 downto 0) := "0000110";
  constant GLYPH_1 : std_logic_vector(6 downto 0) := "1111001";

  signal clk      : std_logic := '0';
  signal resetn   : std_logic := '0';   -- active-low: start asserted (0 = in reset)
  signal btn_1, btn_e, btn_u : std_logic := '0';
  signal seg      : std_logic_vector(6 downto 0);
  signal an       : std_logic_vector(7 downto 0);
  signal led_up, led_down, led_door : std_logic;
  signal sim_done : boolean := false;
begin
  dut : entity work.elevator_top
    generic map ( DEBOUNCE_CYCLES => 4, TRAVEL_CYCLES => 4, DOOR_CYCLES => 6 )
    port map (
      clk => clk, resetn => resetn,
      btn_1 => btn_1, btn_e => btn_e, btn_u => btn_u,
      seg => seg, an => an,
      led_up => led_up, led_down => led_down, led_door => led_door );

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
    resetn <= '0';                 -- assert reset (active-low)
    wait for 5 * CLK_PERIOD;
    resetn <= '1';                 -- release
    wait for 3 * CLK_PERIOD;

    assert seg = GLYPH_E
      report "FAIL: reset not showing E" severity error;
    assert an = "11111110"
      report "FAIL: AN0 not the active digit" severity error;
    report "PASS: reset at E, AN0 active" severity note;

    -- Scenario 1: clean press floor 1 -> cabin goes up to 1
    btn_1 <= '1'; wait for 12 * CLK_PERIOD; btn_1 <= '0';
    wait until led_door = '1' for 300 * CLK_PERIOD;
    assert led_door = '1' report "FAIL: floor-1 door never opened" severity error;
    assert seg = GLYPH_1
      report "FAIL: should display floor 1" severity error;
    assert led_up = '0' and led_down = '0'
      report "FAIL: direction LEDs should be off at door" severity error;
    report "PASS: travelled up to floor 1, door open" severity note;
    wait until led_door = '0' for 300 * CLK_PERIOD;

    -- Scenario 2: BOUNCY press U -> debounced to one request, cabin descends to U
    btn_u <= '1'; wait for 1 * CLK_PERIOD;
    btn_u <= '0'; wait for 1 * CLK_PERIOD;
    btn_u <= '1'; wait for 12 * CLK_PERIOD; btn_u <= '0';
    wait until led_door = '1' for 300 * CLK_PERIOD;
    assert seg = GLYPH_U
      report "FAIL: should display U" severity error;
    report "PASS: bouncy press debounced, descended to U" severity note;
    wait until led_door = '0' for 300 * CLK_PERIOD;

    -- Scenario 3: press E -> single step up
    btn_e <= '1'; wait for 12 * CLK_PERIOD; btn_e <= '0';
    wait until led_door = '1' for 300 * CLK_PERIOD;
    assert seg = GLYPH_E
      report "FAIL: should be back at E" severity error;
    report "PASS: returned to E" severity note;

    report "=== ALL SYSTEM TESTS COMPLETE ===" severity note;
    sim_done <= true;
    wait;
  end process;
end architecture;