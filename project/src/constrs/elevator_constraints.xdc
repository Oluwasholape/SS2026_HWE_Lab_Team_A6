## Clock - 100 MHz oscillator
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]

## Reset - CPU_RESETN button (active-low, inverted inside elevator_top)
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports resetn]

## Call buttons (active-high)
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports btn_1]   ;# BTNU
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports btn_e]   ;# BTNC
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports btn_u]   ;# BTND

## Seven-segment cathodes  seg(6..0) = g f e d c b a  (active low)
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {seg[0]}] ;# CA (a)
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports {seg[1]}] ;# CB (b)
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {seg[2]}] ;# CC (c)
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports {seg[3]}] ;# CD (d)
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {seg[4]}] ;# CE (e)
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports {seg[5]}] ;# CF (f)
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports {seg[6]}] ;# CG (g)

## Seven-segment anodes  an(7..0) = AN7..AN0  (active low)
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {an[0]}] ;# AN0
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {an[1]}] ;# AN1
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports {an[2]}] ;# AN2
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports {an[3]}] ;# AN3
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {an[4]}] ;# AN4
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports {an[5]}] ;# AN5
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports {an[6]}] ;# AN6
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports {an[7]}] ;# AN7

## Status LEDs
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports led_up]   ;# LD0
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports led_down] ;# LD1
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports led_door] ;# LD2
