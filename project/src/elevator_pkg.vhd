library ieee;
use ieee.std_logic_1164.all;

package elevator_pkg is
  -- Floor codes (U=basement, E=ground, 1=first)
  constant FLOOR_U : std_logic_vector(1 downto 0) := "00";
  constant FLOOR_E : std_logic_vector(1 downto 0) := "01";
  constant FLOOR_1 : std_logic_vector(1 downto 0) := "10";

  type state_t      is (IDLE, MOVING, DOOR_OPEN);
  type timer_mode_t is (TMR_TRAVEL, TMR_DOOR);
end package;