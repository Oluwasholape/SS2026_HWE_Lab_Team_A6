library ieee;
use ieee.std_logic_1164.all;
use work.elevator_pkg.all;

entity timer_unit is
  generic (
    TRAVEL_CYCLES : positive := 200_000_000;  -- 2 s @ 100 MHz (hardware)
    DOOR_CYCLES   : positive := 300_000_000   -- 3 s @ 100 MHz
  );
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;      -- 1-cycle pulse to (re)start
    mode  : in  timer_mode_t;   -- TMR_TRAVEL or TMR_DOOR
    done  : out std_logic       -- 1-cycle pulse on expiry
  );
end entity;

architecture rtl of timer_unit is
  signal counter : natural := 0;
  signal target  : natural := 0;
  signal running : std_logic := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      done <= '0';                         -- default; high for exactly 1 cycle
      if rst = '1' then
        running <= '0';
        counter <= 0;
      elsif start = '1' then               -- (re)start: latch target, restart count
        running <= '1';
        counter <= 1;
        if mode = TMR_TRAVEL then
          target <= TRAVEL_CYCLES;
        else
          target <= DOOR_CYCLES;
        end if;
      elsif running = '1' then
        if counter >= target then
          done    <= '1';
          running <= '0';
          counter <= 0;
        else
          counter <= counter + 1;
        end if;
      end if;
    end if;
  end process;
end architecture;