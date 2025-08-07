create_clock -name clk -period 20.0 [get_ports clk]
set_false_path -from [get_ports rx]
set_false_path -to [get_ports tx]
