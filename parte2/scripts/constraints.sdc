# constraints.sdc -- SUPERADO por las restricciones ya inline en
# scripts/synth_dc.tcl (mismo patron que dc_ppa1_performance.tcl del
# material de apoyo del curso: create_clock + uncertainty/transition/
# latencia + input/output delay + group_path, todo dentro del script de
# sintesis en vez de un .sdc aparte). Se deja este archivo solo como
# referencia rapida de los valores usados; el .sdc real para ICC2 sale de
# "write_sdc" al final de synth_dc.tcl (parte2/netlist/alu_plus_sync_synth.sdc),
# no de este archivo.

set CLK_NAME  clk
set CLK_PERIOD 10.0  ;# ns, corner ss_100C_1v40 -- AJUSTAR con report_timing real (ver synth_dc.tcl)
