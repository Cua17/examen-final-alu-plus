# Verificación

Toda la Parte 1 se simuló con Vivado Simulator 2026.1 por línea de comandos
(`xvlog`/`xelab`/`xsim`, sin abrir la GUI), mismo criterio que
[P3](../P3/docs/02-hdl.md). Dos testbenches, cada uno con su propio modelo
de referencia calculado con operadores nativos de SystemVerilog (no
reimplementan Kogge-Stone ni el divisor en arreglo — si lo hicieran, un
error de lógica se repetiría igual en el "modelo" y en el RTL, y nunca se
detectaría).

## `sim/testbench.sv` — WIDTH=8, 35 checks

Cubre: AND/OR (con operandos en 0 y todo-unos), ADD/SUB (simple, carry,
overflow positivo y negativo, resta con y sin préstamo), el código
reservado de multiplicador (debe dar `0`), división y residuo (exacta, con
resto, dividendo menor, dividendo grande, y por cero), el código "todos en
0", y un barrido de los 8 valores de `ALUControl` con un mismo par de
operandos fijo.

Corrida real:

```
RESULTADO: 35 PASS, 0 FAIL
TESTBENCH: PASS
```

Reproducir:

```bash
cd ExamenFinal
xvlog --sv src/mux2.sv src/prefix_adder.sv src/array_divider.sv src/alu_plus.sv sim/testbench.sv
xelab testbench -s testbench_sim
xsim testbench_sim -runall
```

## `sim/testbench_widths.sv` — WIDTH=16 y WIDTH=32, 10 checks

Confirma que la misma arquitectura (sin cambiar un solo archivo de `src/`)
funciona igual a 16 y 32 bits: suma, resta, carry, overflow, división y
residuo, instanciando `alu_plus` dos veces con `WIDTH=16` y `WIDTH=32` en
el mismo testbench.

Corrida real:

```
RESULTADO (anchos 16/32): 10 PASS, 0 FAIL
TESTBENCH_WIDTHS: PASS
```

Reproducir:

```bash
cd ExamenFinal
xvlog --sv src/mux2.sv src/prefix_adder.sv src/array_divider.sv src/alu_plus.sv sim/testbench_widths.sv
xelab testbench_widths -s testbench_widths_sim
xsim testbench_widths_sim -runall
```

## `parte2/sim/testbench_sync.sv` — envoltorio síncrono, WIDTH=16, 5 checks

Chequeo funcional de `alu_plus_sync` (registro de entrada → ALU+
combinacional → registro de salida, latencia de 2 ciclos) antes de subirlo
al servidor. **No reemplaza** la verificación con VCS/Verdi que pide el PDF
(item 1 de la Parte 2) — VCS/Verdi no están instalados en esta máquina,
solo confirma que la lógica del envoltorio está bien antes de gastar tiempo
de servidor en ella. Ver [`../parte2/docs/00-estado.md`](../parte2/docs/00-estado.md).

Corrida real:

```
RESULTADO (sync): 5 PASS, 0 FAIL
TESTBENCH_SYNC: PASS
```
