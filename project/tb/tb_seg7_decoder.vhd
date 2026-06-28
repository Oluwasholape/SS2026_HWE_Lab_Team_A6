library ieee;
use ieee.std_logic_1164.all;
use work.elevator_pkg.all;

entity tb_seg7_decoder is
end entity;

architecture sim of tb_seg7_decoder is
  signal floor : std_logic_vector(1 downto 0) := FLOOR_U;
  signal seg   : std_logic_vector(6 downto 0);
  signal an    : std_logic_vector(7 downto 0);
begin
  dut : entity work.seg7_decoder
    port map ( floor => floor, seg => seg, an => an );

  stim : process
  begin
    floor <= FLOOR_U; wait for 10 ns;
    assert seg = "1000001"
      report "FAIL: U pattern wrong, got " severity error;
    assert an = "11111110"
      report "FAIL: anode not AN0-only" severity error;
    report "PASS: U" severity note;

    floor <= FLOOR_E; wait for 10 ns;
    assert seg = "0000110" report "FAIL: E pattern wrong" severity error;
    report "PASS: E" severity note;

    floor <= FLOOR_1; wait for 10 ns;
    assert seg = "1111001" report "FAIL: 1 pattern wrong" severity error;
    report "PASS: 1" severity note;

    floor <= "11";       wait for 10 ns;   -- unused code -> blank
    assert seg = "1111111" report "FAIL: blank pattern wrong" severity error;
    report "PASS: blank" severity note;

    report "=== ALL SEG7 TESTS COMPLETE ===" severity note;
    wait;
  end process;
end architecture;