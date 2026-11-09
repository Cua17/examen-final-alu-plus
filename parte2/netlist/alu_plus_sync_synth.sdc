###################################################################

# Created by write_sdc on Mon Nov  9 12:15:10 2026

###################################################################
set sdc_version 2.2

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_load -pin_load 0.04 [get_ports {result_out[15]}]
set_load -pin_load 0.04 [get_ports {result_out[14]}]
set_load -pin_load 0.04 [get_ports {result_out[13]}]
set_load -pin_load 0.04 [get_ports {result_out[12]}]
set_load -pin_load 0.04 [get_ports {result_out[11]}]
set_load -pin_load 0.04 [get_ports {result_out[10]}]
set_load -pin_load 0.04 [get_ports {result_out[9]}]
set_load -pin_load 0.04 [get_ports {result_out[8]}]
set_load -pin_load 0.04 [get_ports {result_out[7]}]
set_load -pin_load 0.04 [get_ports {result_out[6]}]
set_load -pin_load 0.04 [get_ports {result_out[5]}]
set_load -pin_load 0.04 [get_ports {result_out[4]}]
set_load -pin_load 0.04 [get_ports {result_out[3]}]
set_load -pin_load 0.04 [get_ports {result_out[2]}]
set_load -pin_load 0.04 [get_ports {result_out[1]}]
set_load -pin_load 0.04 [get_ports {result_out[0]}]
set_load -pin_load 0.04 [get_ports n_out]
set_load -pin_load 0.04 [get_ports z_out]
set_load -pin_load 0.04 [get_ports c_out]
set_load -pin_load 0.04 [get_ports v_out]
create_clock [get_ports clk]  -period 40  -waveform {0 20}
set_clock_latency -max 1.2  [get_clocks clk]
set_clock_latency -source -max 2  [get_clocks clk]
set_clock_uncertainty -setup 4  [get_clocks clk]
set_clock_transition -max -rise 4 [get_clocks clk]
set_clock_transition -max -fall 4 [get_clocks clk]
group_path -name FEEDTHROUGH  -from [list [get_ports clk] [get_ports reset] [get_ports {a_in[15]}]          \
[get_ports {a_in[14]}] [get_ports {a_in[13]}] [get_ports {a_in[12]}]           \
[get_ports {a_in[11]}] [get_ports {a_in[10]}] [get_ports {a_in[9]}] [get_ports \
{a_in[8]}] [get_ports {a_in[7]}] [get_ports {a_in[6]}] [get_ports {a_in[5]}]   \
[get_ports {a_in[4]}] [get_ports {a_in[3]}] [get_ports {a_in[2]}] [get_ports   \
{a_in[1]}] [get_ports {a_in[0]}] [get_ports {b_in[15]}] [get_ports {b_in[14]}] \
[get_ports {b_in[13]}] [get_ports {b_in[12]}] [get_ports {b_in[11]}]           \
[get_ports {b_in[10]}] [get_ports {b_in[9]}] [get_ports {b_in[8]}] [get_ports  \
{b_in[7]}] [get_ports {b_in[6]}] [get_ports {b_in[5]}] [get_ports {b_in[4]}]   \
[get_ports {b_in[3]}] [get_ports {b_in[2]}] [get_ports {b_in[1]}] [get_ports   \
{b_in[0]}] [get_ports {aluControl_in[2]}] [get_ports {aluControl_in[1]}]       \
[get_ports {aluControl_in[0]}]]  -to [list [get_ports {result_out[15]}] [get_ports {result_out[14]}]           \
[get_ports {result_out[13]}] [get_ports {result_out[12]}] [get_ports           \
{result_out[11]}] [get_ports {result_out[10]}] [get_ports {result_out[9]}]     \
[get_ports {result_out[8]}] [get_ports {result_out[7]}] [get_ports             \
{result_out[6]}] [get_ports {result_out[5]}] [get_ports {result_out[4]}]       \
[get_ports {result_out[3]}] [get_ports {result_out[2]}] [get_ports             \
{result_out[1]}] [get_ports {result_out[0]}] [get_ports n_out] [get_ports      \
z_out] [get_ports c_out] [get_ports v_out]]
group_path -name INREG  -from [get_ports reset]
group_path -name INREG  -from [list [get_ports clk] [get_ports {a_in[15]}] [get_ports {a_in[14]}]     \
[get_ports {a_in[13]}] [get_ports {a_in[12]}] [get_ports {a_in[11]}]           \
[get_ports {a_in[10]}] [get_ports {a_in[9]}] [get_ports {a_in[8]}] [get_ports  \
{a_in[7]}] [get_ports {a_in[6]}] [get_ports {a_in[5]}] [get_ports {a_in[4]}]   \
[get_ports {a_in[3]}] [get_ports {a_in[2]}] [get_ports {a_in[1]}] [get_ports   \
{a_in[0]}] [get_ports {b_in[15]}] [get_ports {b_in[14]}] [get_ports            \
{b_in[13]}] [get_ports {b_in[12]}] [get_ports {b_in[11]}] [get_ports           \
{b_in[10]}] [get_ports {b_in[9]}] [get_ports {b_in[8]}] [get_ports {b_in[7]}]  \
[get_ports {b_in[6]}] [get_ports {b_in[5]}] [get_ports {b_in[4]}] [get_ports   \
{b_in[3]}] [get_ports {b_in[2]}] [get_ports {b_in[1]}] [get_ports {b_in[0]}]   \
[get_ports {aluControl_in[2]}] [get_ports {aluControl_in[1]}] [get_ports       \
{aluControl_in[0]}]]
group_path -name REGOUT  -to [list [get_ports {result_out[15]}] [get_ports {result_out[14]}]           \
[get_ports {result_out[13]}] [get_ports {result_out[12]}] [get_ports           \
{result_out[11]}] [get_ports {result_out[10]}] [get_ports {result_out[9]}]     \
[get_ports {result_out[8]}] [get_ports {result_out[7]}] [get_ports             \
{result_out[6]}] [get_ports {result_out[5]}] [get_ports {result_out[4]}]       \
[get_ports {result_out[3]}] [get_ports {result_out[2]}] [get_ports             \
{result_out[1]}] [get_ports {result_out[0]}] [get_ports n_out] [get_ports      \
z_out] [get_ports c_out] [get_ports v_out]]
set_input_delay -clock clk  -max 16  [get_ports reset]
set_input_delay -clock clk  -min 0.4  [get_ports reset]
set_input_delay -clock clk  -max 16  [get_ports {a_in[15]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[15]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[14]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[14]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[13]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[13]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[12]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[12]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[11]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[11]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[10]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[10]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[9]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[9]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[8]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[8]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[7]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[7]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[6]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[6]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[5]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[5]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[4]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[4]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[3]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[3]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[2]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[2]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[1]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[1]}]
set_input_delay -clock clk  -max 16  [get_ports {a_in[0]}]
set_input_delay -clock clk  -min 0.4  [get_ports {a_in[0]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[15]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[15]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[14]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[14]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[13]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[13]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[12]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[12]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[11]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[11]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[10]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[10]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[9]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[9]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[8]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[8]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[7]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[7]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[6]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[6]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[5]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[5]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[4]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[4]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[3]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[3]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[2]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[2]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[1]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[1]}]
set_input_delay -clock clk  -max 16  [get_ports {b_in[0]}]
set_input_delay -clock clk  -min 0.4  [get_ports {b_in[0]}]
set_input_delay -clock clk  -max 16  [get_ports {aluControl_in[2]}]
set_input_delay -clock clk  -min 0.4  [get_ports {aluControl_in[2]}]
set_input_delay -clock clk  -max 16  [get_ports {aluControl_in[1]}]
set_input_delay -clock clk  -min 0.4  [get_ports {aluControl_in[1]}]
set_input_delay -clock clk  -max 16  [get_ports {aluControl_in[0]}]
set_input_delay -clock clk  -min 0.4  [get_ports {aluControl_in[0]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[15]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[15]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[14]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[14]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[13]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[13]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[12]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[12]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[11]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[11]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[10]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[10]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[9]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[9]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[8]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[8]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[7]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[7]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[6]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[6]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[5]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[5]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[4]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[4]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[3]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[3]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[2]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[2]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[1]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[1]}]
set_output_delay -clock clk  -max 20  [get_ports {result_out[0]}]
set_output_delay -clock clk  -min 0.4  [get_ports {result_out[0]}]
set_output_delay -clock clk  -max 20  [get_ports n_out]
set_output_delay -clock clk  -min 0.4  [get_ports n_out]
set_output_delay -clock clk  -max 20  [get_ports z_out]
set_output_delay -clock clk  -min 0.4  [get_ports z_out]
set_output_delay -clock clk  -max 20  [get_ports c_out]
set_output_delay -clock clk  -min 0.4  [get_ports c_out]
set_output_delay -clock clk  -max 20  [get_ports v_out]
set_output_delay -clock clk  -min 0.4  [get_ports v_out]
set_false_path   -from [get_ports reset]
