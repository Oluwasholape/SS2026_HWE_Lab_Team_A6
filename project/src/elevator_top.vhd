library ieee;
use ieee.std_logic_1164.all;
use work.elevator_pkg.all;

entity elevator_top is
  generic (
    DEBOUNCE_CYCLES : positive := 1_000_000;    -- 10 ms @ 100 MHz
    TRAVEL_CYCLES   : positive := 200_000_000;  -- 2 s
    DOOR_CYCLES     : positive := 300_000_000   -- 3 s
  );
  port (
    clk      : in  std_logic;                      -- 100 MHz, pin E3
    resetn   : in  std_logic;                      -- CPU_RESETN, active-low
    btn_1    : in  std_logic;                      -- BTNU
    btn_e    : in  std_logic;                      -- BTNC
    btn_u    : in  std_logic;                      -- BTND
    seg      : out std_logic_vector(6 downto 0);
    an       : out std_logic_vector(7 downto 0);
    led_up   : out std_logic;
    led_down : out std_logic;
    led_door : out std_logic
  );
end entity;

architecture rtl of elevator_top is
  signal rst                     : std_logic;
  signal call_1, call_e, call_u  : std_logic;
  signal timer_start, timer_done : std_logic;
  signal timer_mode    : timer_mode_t;
  signal current_floor : std_logic_vector(1 downto 0);
begin

  rst <= not resetn;             -- active-low button -> active-high internal reset

  db_1 : entity work.debouncer
    generic map ( DEBOUNCE_CYCLES => DEBOUNCE_CYCLES )
    port map ( clk => clk, rst => rst, btn_raw => btn_1, btn_edge => call_1 );

  db_e : entity work.debouncer
    generic map ( DEBOUNCE_CYCLES => DEBOUNCE_CYCLES )
    port map ( clk => clk, rst => rst, btn_raw => btn_e, btn_edge => call_e );

  db_u : entity work.debouncer
    generic map ( DEBOUNCE_CYCLES => DEBOUNCE_CYCLES )
    port map ( clk => clk, rst => rst, btn_raw => btn_u, btn_edge => call_u );

  fsm : entity work.elevator_fsm
    port map (
      clk => clk, rst => rst,
      call_1 => call_1, call_e => call_e, call_u => call_u,
      timer_done => timer_done,
      timer_start => timer_start, timer_mode => timer_mode,
      current_floor => current_floor,
      led_up => led_up, led_down => led_down, led_door => led_door );

  tmr : entity work.timer_unit
    generic map ( TRAVEL_CYCLES => TRAVEL_CYCLES, DOOR_CYCLES => DOOR_CYCLES )
    port map ( clk => clk, rst => rst, start => timer_start,
               mode => timer_mode, done => timer_done );

  disp : entity work.seg7_decoder
    port map ( floor => current_floor, seg => seg, an => an );

end architecture;