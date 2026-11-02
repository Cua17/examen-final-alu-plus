# synth_dc.tcl -- flujo de sintesis con Design Compiler (dc_shell) para
# alu_plus_sync (WIDTH=16).
#
# Libreria REAL confirmada en dos pasos:
#   1. PDK de proceso: GlobalFoundries 150MCU (GF 150nm), ZIP oficial de GF
#      (GF-20261031T234429Z-1-001.zip) que el usuario bajo de su Drive.
#   2. Libreria de celdas: M31LLSC733GL150MS -- "7-Track SVT Low Leakage
#      Standard Cell Library" de M31 para el mismo proceso GF 150MCU,
#      dominio 3.3V (la variante digital normal; existe tambien
#      M31LLSC750GL150MS para dominio 5V/IO, no aplica a un bloque logico
#      puro como esta ALU). ZIP de M31 que el usuario bajo de su cuenta
#      (M31-20261101T003501Z-1-001.zip), confirmado por el ayudante del
#      catedratico por audio: "la libreria m31... la que te voy a enviar
#      es para la del circuito" (no la de memoria/SRAM).
#   Esto reemplaza la version anterior de este script (sky130), que estaba
#   mal -- ver parte2/docs/00-estado.md para el historial completo de la
#   correccion.
#
# COMO CORRERLO (en el servidor del curso, una vez dentro por SSH -- OJO,
# hay que pararse DENTRO de parte2/scripts antes de correrlo, los paths
# relativos del script asumen ese cwd):
#   cd ExamenFinal/parte2/scripts
#   dc_shell-t -f synth_dc.tcl | tee ../reportes/synth_dc.log
#
# Rutas esperadas en el servidor (ver parte2/docs/00-estado.md "Subida de
# archivos al servidor" para como se generaron):
#   /home/cuax/bootcamp_data/ExamenFinal_ALU/GF_PDK/...   (techfiles GF, ya extraidos)
#   /home/cuax/bootcamp_data/ExamenFinal_ALU/m31/...      (libreria M31, ya extraida)

# ------------------------------------------------------------------
# 0. Librerias (M31LLSC733GL150MS, corner tipico 25C/TT/3.3V)
# ------------------------------------------------------------------
set DESIGN_REF_PATH "/home/cuax/bootcamp_data/ExamenFinal_ALU"
set M31_LIB_PATH     "${DESIGN_REF_PATH}/m31"

set_app_var search_path "$search_path .. ./rtl ${M31_LIB_PATH}"
set_app_var synthetic_library dw_foundation.sldb

# Corner tipico (25C, TT, 3.3V) -- el ZIP de M31 trae mas corners
# (cworst/cbest a distintas temperaturas/voltajes) si hace falta signoff
# multi-corner mas adelante; para el flujo basico que pide el PDF alcanza
# con el tipico.
set_app_var target_library \
    "${M31_LIB_PATH}/M31LLSC733GL150MS_25CTT3P3_ctyp_nldm.db"

set_app_var link_library \
    "* $target_library $synthetic_library"

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
    ../rtl/alu_plus_sync.sv
}
analyze -format sverilog $RTL_FILES
elaborate alu_plus_sync -parameters "WIDTH=16"
current_design alu_plus_sync
link

# ------------------------------------------------------------------
# 2. Restricciones de timing
# ------------------------------------------------------------------
# Periodo de partida para un bloque chico (ALU de 16 bits + registros) en
# GF150MCU + M31 7-track (proceso de 150nm, bastante mas lento que un nodo
# moderno) -- AJUSTAR con el report_timing real de la primera corrida;
# 20ns (50MHz) es un punto de partida conservador, no un numero medido.
set clk_val 20.0
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
