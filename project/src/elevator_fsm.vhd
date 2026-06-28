library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_pkg.all;

entity elevator_fsm is
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    call_1        : in  std_logic;
    call_e        : in  std_logic;
    call_u        : in  std_logic;
    timer_done    : in  std_logic;
    timer_start   : out std_logic;
    timer_mode    : out timer_mode_t;
    current_floor : out std_logic_vector(1 downto 0);
    led_up        : out std_logic;
    led_down      : out std_logic;
    led_door      : out std_logic
  );
end entity;

architecture rtl of elevator_fsm is
  signal state : state_t := IDLE;
  signal cur   : integer range 0 to 2 := 1;   -- 0=U, 1=E, 2=floor1; start at E
  signal tgt   : integer range 0 to 2 := 1;
  signal req   : std_logic_vector(2 downto 0) := "000";  -- (2)=1, (1)=E, (0)=U
begin
  current_floor <= std_logic_vector(to_unsigned(cur, 2));

  process(clk)
    variable best      : integer range -1 to 2;
    variable best_dist : integer range 0 to 3;
    variable d         : integer range 0 to 2;
    variable next_cur  : integer range 0 to 2;
  begin
    if rising_edge(clk) then
      timer_start <= '0';                 -- default: 1-cycle pulse

      -- Request latching: independent of state, so a press is never missed
      if call_u = '1' then req(0) <= '1'; end if;
      if call_e = '1' then req(1) <= '1'; end if;
      if call_1 = '1' then req(2) <= '1'; end if;

      if rst = '1' then
        state    <= IDLE;
        cur      <= 1;
        tgt      <= 1;
        req      <= "000";
        led_up   <= '0';
        led_down <= '0';
        led_door <= '0';
        timer_mode <= TMR_TRAVEL;
      else
        case state is

          when IDLE =>
            led_up <= '0'; led_down <= '0'; led_door <= '0';

            best := -1; best_dist := 3;          -- scheduler: nearest, ties up
            for i in 0 to 2 loop
              if req(i) = '1' then
                d := abs(i - cur);
                if (d < best_dist) or (d = best_dist and i > best) then
                  best := i; best_dist := d;
                end if;
              end if;
            end loop;

            if best >= 0 then
              tgt <= best;
              if best = cur then                 -- already at the requested floor
                req(best)   <= '0';
                timer_mode  <= TMR_DOOR;
                timer_start <= '1';
                state       <= DOOR_OPEN;
              else
                timer_mode  <= TMR_TRAVEL;
                timer_start <= '1';
                if best > cur then led_up <= '1'; else led_down <= '1'; end if;
                state       <= MOVING;
              end if;
            end if;

          when MOVING =>
            if tgt > cur then led_up <= '1'; led_down <= '0';
            else                led_up <= '0'; led_down <= '1'; end if;
            led_door <= '0';

            if timer_done = '1' then
              if    tgt > cur then next_cur := cur + 1;   -- step one floor
              elsif tgt < cur then next_cur := cur - 1;
              else                 next_cur := cur; end if;
              cur <= next_cur;

              if next_cur = tgt then              -- arrived
                req(tgt)    <= '0';
                timer_mode  <= TMR_DOOR;
                timer_start <= '1';
                state       <= DOOR_OPEN;
              else                                -- one more floor to go
                timer_mode  <= TMR_TRAVEL;
                timer_start <= '1';
              end if;
            end if;

          when DOOR_OPEN =>
            led_door <= '1'; led_up <= '0'; led_down <= '0';
            if timer_done = '1' then
              state <= IDLE;
            end if;

        end case;
      end if;
    end if;
  end process;
end architecture;