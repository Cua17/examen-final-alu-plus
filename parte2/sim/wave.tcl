# wave.tcl
#
# Agrega al visor de formas de onda de Vivado (xsim GUI) las senales
# clave para demostrar en vivo el envoltorio sincrono alu_plus_sync:
# reloj, reset, las entradas registradas y las salidas registradas
# (resultado + 4 banderas), para mostrar la latencia de 2 ciclos
# (registro de entrada -> ALU+ combinacional -> registro de salida).
# Pensado para correr dentro de la GUI de xsim (Tools > Run Tcl
# Script, o "source parte2/sim/wave.tcl" en la consola Tcl), despues
# de elaborar con "-debug all".

add_wave /testbench_sync/clk
add_wave /testbench_sync/reset
add_wave /testbench_sync/a_in
add_wave /testbench_sync/b_in
add_wave /testbench_sync/aluControl_in
add_wave /testbench_sync/result_out
add_wave /testbench_sync/n_out
add_wave /testbench_sync/z_out
add_wave /testbench_sync/c_out
add_wave /testbench_sync/v_out

run all
