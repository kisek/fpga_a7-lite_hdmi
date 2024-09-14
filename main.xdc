###############################################################################################
## main.xdc for A7_LITE FPGA Board              ArchLab Institute of Science Tokyo / Tokyo Tech
###############################################################################################

## 50MHz system clock
###############################################################################################
set_property -dict { PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports { w_clk }];
create_clock -add -name sys_clk -period 20.00 [get_ports {w_clk}];

###############################################################################################
#set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports { w_led1 }];
#set_property -dict { PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports { w_led2 }];

###############################################################################################
set_property -dict { PACKAGE_PIN L19 IOSTANDARD TMDS_33} [get_ports { tmds_clk_p }];
set_property -dict { PACKAGE_PIN L20 IOSTANDARD TMDS_33} [get_ports { tmds_clk_n }];

set_property -dict { PACKAGE_PIN G17 IOSTANDARD TMDS_33} [get_ports { tmds_r_p }]; # red
set_property -dict { PACKAGE_PIN G18 IOSTANDARD TMDS_33} [get_ports { tmds_r_n }]; # red

set_property -dict { PACKAGE_PIN J20 IOSTANDARD TMDS_33} [get_ports { tmds_g_p }]; # green
set_property -dict { PACKAGE_PIN J21 IOSTANDARD TMDS_33} [get_ports { tmds_g_n }]; # green

set_property -dict { PACKAGE_PIN K21 IOSTANDARD TMDS_33} [get_ports { tmds_b_p }]; # blue
set_property -dict { PACKAGE_PIN K22 IOSTANDARD TMDS_33} [get_ports { tmds_b_n }]; # blue
###############################################################################################
