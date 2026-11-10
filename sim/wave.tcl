# wave.tcl
#
# Agrega al visor de formas de onda de Vivado (xsim GUI) las senales
# clave para demostrar en vivo el funcionamiento de alu_plus: las dos
# entradas, el codigo de operacion, el resultado, y las 4 banderas.
# Pensado para correr dentro de la GUI de xsim (Tools > Run Tcl
# Script, o "source sim/wave.tcl" en la consola Tcl), despues de
# elaborar con "-debug all".

add_wave /testbench/a
add_wave /testbench/b
add_wave /testbench/aluControl
add_wave /testbench/result
add_wave /testbench/n
add_wave /testbench/z
add_wave /testbench/c
add_wave /testbench/v

run all
