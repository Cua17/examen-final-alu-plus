# constraints.sdc -- restricciones de timing para alu_plus_sync (WIDTH=16)
#
# El periodo de abajo es un PUNTO DE PARTIDA conservador para un nodo de
# 150nm (GF), NO un numero validado contra las librerias reales de M31 --
# eso todavia no lo pude correr (ver parte2/docs/00-estado.md). La idea es
# sintetizar con esta restriccion, leer report_timing / report_qor reales,
# y ajustar el periodo segun la ruta critica que reporte DC (igual criterio
# de "nada inventado" que el resto del curso: el numero final sale de un
# reporte real, no de aqui).

set CLK_NAME  clk
set CLK_PORT  clk
set CLK_PERIOD 20.0  ;# 20 ns = 50 MHz, punto de partida -- AJUSTAR con report_timing real

create_clock -name $CLK_NAME -period $CLK_PERIOD [get_ports $CLK_PORT]

# margen de reloj no ideal (jitter + incertidumbre de CTS), tipico 10% del periodo
set_clock_uncertainty [expr {$CLK_PERIOD * 0.10}] [get_clocks $CLK_NAME]

# entradas/salidas: la mitad del periodo como placeholder de delay externo
set_input_delay  [expr {$CLK_PERIOD * 0.5}] -clock $CLK_NAME [remove_from_collection [all_inputs]  [get_ports $CLK_PORT]]
set_output_delay [expr {$CLK_PERIOD * 0.5}] -clock $CLK_NAME [all_outputs]

# reset como señal lenta/falsa ruta de timing (es sincrono, pero no es
# critico que llegue en el mismo ciclo que los datos)
set_false_path -from [get_ports reset]
