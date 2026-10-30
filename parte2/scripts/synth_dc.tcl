# synth_dc.tcl -- flujo de sintesis con Design Compiler (dc_shell) para
# alu_plus_sync (WIDTH=16).
#
# Libreria real confirmada por el material de apoyo del curso (Google
# Drive "DC y ICC2", TCL_DC_ICC2_originales_y_comentados.zip): es
# SkyWater sky130 (sky130_fd_sc_hd), NO el GF 150nm / M31 que decia el PDF
# del examen -- ver parte2/docs/00-estado.md para la aclaracion completa.
# Esta version sigue el mismo patron de setup que
# dc_ppa1_performance.tcl / dc_ppa2_power.tcl del material de apoyo
# (mismo curso, mismas librerias, proyecto anterior "ProyectoCPU_F").
#
# COMO CORRERLO (en el servidor del curso, una vez dentro por SSH):
#   dc_shell-t -f parte2/scripts/synth_dc.tcl | tee parte2/reportes/synth_dc.log
#
# PENDIENTE DE VERIFICAR EN EL SERVIDOR (marcado "AJUSTAR" abajo):
#   - $HOME de "cuax" puede no ser /home/synuser19/... (ese es de otro
#     usuario, de un proyecto anterior) -- confirmar con "echo $DESIGN_REF_PATH"
#     o preguntando al profesor donde vive el PDK para este examen.
#   - El resto de la ruta (new_google_skywater/.../sky130_fd_sc_hd...) es
#     la instalacion compartida del curso y probablemente es la misma
#     para todos los usuarios.

# ------------------------------------------------------------------
# 0. Librerias (sky130_fd_sc_hd, confirmado por el material de apoyo)
# ------------------------------------------------------------------
set DESIGN_REF_PATH "/home/cuax/bootcamp_data/ExamenFinal_ALU"  ;# AJUSTAR: verificar $HOME real de cuax
set PDK_ROOT "${DESIGN_REF_PATH}/new_google_skywater/latest/pdk/synopsys/results"

set_app_var search_path "$search_path .. ./rtl ./libs ${PDK_ROOT}/lib/sky130_fd_sc_hd/db_nldm"
set_app_var synthetic_library dw_foundation.sldb

set_app_var target_library \
    "sky130_fd_sc_hd__ss_100C_1v40.db"

set_app_var link_library \
    "* $target_library $synthetic_library"

set_min_library \
    sky130_fd_sc_hd__ss_100C_1v40.db \
    -min_version sky130_fd_sc_hd__ff_100C_1v95.db

get_libs

# ------------------------------------------------------------------
# 1. Leer RTL (misma jerarquia que la simulacion, mas el envoltorio
#    sincrono de la Parte 2)
# ------------------------------------------------------------------
set RTL_FILES {
    ../../src/mux2.sv
    ../../src/prefix_adder.sv
    ../../src/array_divider.sv
    ../../src/alu_plus.sv
    rtl/alu_plus_sync.sv
}
analyze -format sverilog $RTL_FILES
elaborate alu_plus_sync -parameters "WIDTH=16"
current_design alu_plus_sync
link

set_operating_conditions \
    -max ss_100C_1v40 \
    -max_library sky130_fd_sc_hd__ss_100C_1v40 \
    -min ff_100C_1v95 \
    -min_library sky130_fd_sc_hd__ff_100C_1v95

# ------------------------------------------------------------------
# 2. Restricciones de timing (mismo patron que el material de apoyo:
#    uncertainty/transition/latencia como fraccion del periodo, grupos
#    de paths IN->REG / REG->OUT / IN->OUT)
# ------------------------------------------------------------------
# Periodo de partida para un bloque chico (ALU de 16 bits + registros) en
# sky130_fd_sc_hd, corner ss_100C_1v40 -- AJUSTAR con report_timing real,
# igual criterio que el resto del curso (nada inventado, el numero final
# sale de un reporte real).
set clk_val 10.0
set CLK_PORT clk

create_clock -name clk -period $clk_val [get_ports $CLK_PORT]

set_clock_uncertainty -setup [expr {$clk_val * 0.10}] [get_clocks clk]
set_clock_transition  -max   [expr {$clk_val * 0.10}] [get_clocks clk]
set_clock_latency -source -max [expr {$clk_val * 0.05}] [get_clocks clk]
set_clock_latency        -max [expr {$clk_val * 0.03}] [get_clocks clk]

set data_inputs [remove_from_collection [all_inputs] [get_ports $CLK_PORT]]

set_input_delay  -max [expr {$clk_val * 0.4}]  -clock [get_clocks clk] $data_inputs
set_input_delay  -min [expr {$clk_val * 0.01}] -clock [get_clocks clk] $data_inputs
set_output_delay -max [expr {$clk_val * 0.5}]  -clock [get_clocks clk] [all_outputs]
set_output_delay -min [expr {$clk_val * 0.01}] -clock [get_clocks clk] [all_outputs]

set_load -max 0.04 [all_outputs]

set_false_path -from [get_ports reset]

group_path -name INREG      -from [all_inputs]
group_path -name REGOUT     -to   [all_outputs]
group_path -name FEEDTHROUGH -from [all_inputs] -to [all_outputs]

# ------------------------------------------------------------------
# 3. Sintesis
# ------------------------------------------------------------------
set_fix_multiple_port_nets -all -buffer_constants
compile_ultra -scan -no_autoungroup

# ------------------------------------------------------------------
# 4. Reportes pedidos en la Discusion del PDF (Parte 2, item 7.1)
# ------------------------------------------------------------------
file mkdir ../reportes
redirect -file ../reportes/report_qor.txt        { report_qor }
redirect -file ../reportes/report_timing.txt     { report_timing -delay_type max -max_paths 10 }
redirect -file ../reportes/report_area.txt       { report_area -hierarchy }
redirect -file ../reportes/report_power.txt      { report_power }
redirect -file ../reportes/report_constraint.txt { report_constraint -all_violators }
redirect -file ../reportes/report_reference.txt  { report_reference -hierarchy }

# ------------------------------------------------------------------
# 5. Entregables para ICC2
# ------------------------------------------------------------------
file mkdir ../netlist
write_file -format verilog -hierarchy -output ../netlist/alu_plus_sync_synth.v
write_sdc ../netlist/alu_plus_sync_synth.sdc
write_file -format ddc -hierarchy -output ../netlist/alu_plus_sync_synth.ddc

exit
