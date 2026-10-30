# synth_dc.tcl -- flujo de sintesis con Design Compiler (dc_shell) para
# alu_plus_sync (WIDTH=16), nodo GF 150nm + librerias standard M31.
#
# COMO CORRERLO (en el servidor del curso):
#   dc_shell-t -f parte2/scripts/synth_dc.tcl | tee parte2/reportes/synth_dc.log
#
# Ajustar RUTA_LIBS / target_library / link_library con los nombres reales
# que dio el profesor (los placeholders de abajo son genericos GF150/M31 --
# ver parte2/docs/00-estado.md, ahi queda anotado el valor real apenas lo
# tenga del servidor).

# ------------------------------------------------------------------
# 0. Librerias (AJUSTAR con las rutas/nombres reales del servidor)
# ------------------------------------------------------------------
set RUTA_LIBS       "/ruta/al/pdk/gf150/libs"   ;# AJUSTAR
set target_library  "m31_gf150_tt.db"           ;# AJUSTAR (nombre real del .db)
set link_library     "* $target_library"
set symbol_library   "m31_gf150.sdb"            ;# AJUSTAR

lappend search_path $RUTA_LIBS

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

# ------------------------------------------------------------------
# 2. Restricciones
# ------------------------------------------------------------------
source -echo -verbose scripts/constraints.sdc

# ------------------------------------------------------------------
# 3. Sintesis
# ------------------------------------------------------------------
set_fix_multiple_port_nets -all -buffer_constants
compile_ultra -no_autoungroup

# ------------------------------------------------------------------
# 4. Reportes pedidos en la Discusion del PDF (Parte 2, item 7.1)
# ------------------------------------------------------------------
file mkdir ../reportes
redirect ../reportes/report_qor.txt        { report_qor }
redirect ../reportes/report_timing.txt     { report_timing -delay_type max -max_paths 5 }
redirect ../reportes/report_area.txt       { report_area -hierarchy }
redirect ../reportes/report_power.txt      { report_power -hierarchy }
redirect ../reportes/report_constraint.txt { report_constraint -all_violators }

# ------------------------------------------------------------------
# 5. Entregables para ICC2
# ------------------------------------------------------------------
file mkdir ../netlist
write -format verilog -hierarchy -output ../netlist/alu_plus_sync_synth.v
write_sdc ../netlist/alu_plus_sync_synth.sdc
write -format ddc -hierarchy -output ../netlist/alu_plus_sync_synth.ddc

exit
