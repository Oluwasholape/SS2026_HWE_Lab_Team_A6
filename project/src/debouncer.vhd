library ieee;
use ieee.std_logic_1164.all;

entity debouncer is
  generic ( DEBOUNCE_CYCLES : positive := 1_000_000 );  -- 10 ms @ 100 MHz
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    btn_raw  : in  std_logic;
    btn_edge : out std_logic   -- single-cycle pulse per clean press
  );
end entity;

architecture rtl of debouncer is
  signal sync0, sync1 : std_logic := '0';   -- 2-FF synchronizer
  signal stable       : std_logic := '0';   -- debounced level
  signal stable_prev  : std_logic := '0';   -- for edge detect
  signal counter      : natural   := 0;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      btn_edge <= '0';                      -- default: high for exactly 1 cycle

      if rst = '1' then
        sync0 <= '0'; sync1 <= '0';
        stable <= '0'; stable_prev <= '0';
        counter <= 0;
      else
        -- Stage 1: synchronize raw input
        sync0 <= btn_raw;
        sync1 <= sync0;

        -- Stage 2: debounce (accept new level only after it holds stable)
        if sync1 = stable then
          counter <= 0;
        elsif counter >= DEBOUNCE_CYCLES - 1 then
          stable  <= sync1;
          counter <= 0;
        else
          counter <= counter + 1;
        end if;

        -- Stage 3: rising-edge detect on the debounced level
        stable_prev <= stable;
        if stable = '1' and stable_prev = '0' then
          btn_edge <= '1';
        end if;
      end if;
    end if;
  end process;
end architecture;