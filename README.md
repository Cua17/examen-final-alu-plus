# Examen Final — ALU+ (Prefix Adder + Divisor) y diseño físico

> El PDF de instrucciones del catedrático lo llama "Parcial 3, parte
> práctica" por error — es en realidad el **examen final** del curso, y así
> se nombra en toda esta entrega.

Parte práctica de Arquitectura de Computadoras: a partir de la ALU vista en
clase, describo en SystemVerilog una ALU+ extendida (ALU original +
división entera), con sumador Prefix Adder (Kogge-Stone) y un bus
triestado real para AND/OR — la combinación asignada a mí según la matriz
del PDF (ver [`docs/01-alu-estructura.md`](docs/01-alu-estructura.md)).
Parte 2 (síntesis + diseño físico con Design Compiler / IC Compiler II,
PDK SkyWater sky130 — el material de apoyo real del curso corrige al PDF,
que decía GF 150nm/M31 — ver [`parte2/docs/00-estado.md`](parte2/docs/00-estado.md))
queda preparada en `parte2/` a la espera de correr en el servidor del curso.

José Daniel Cuá Fagiani — Carné 21200

## Resultados principales (Parte 1 — verificados)

| Parte | Resultado |
|---|---|
| `sim/testbench.sv` (WIDTH=8, xvlog/xelab/xsim) | **35/35 PASS**, sin warnings |
| `sim/testbench_widths.sv` (WIDTH=16 y WIDTH=32, misma arquitectura) | **10/10 PASS** |
| `parte2/sim/testbench_sync.sv` (envoltorio síncrono, WIDTH=16, pre-chequeo antes de VCS/Verdi) | **5/5 PASS** |

Parte 2 (Design Compiler / IC Compiler II): **pendiente** — scripts y
documentación listos en `parte2/`, ver
[`parte2/docs/00-estado.md`](parte2/docs/00-estado.md).

## Contenido

1. [Estructura de la ALU+ y asignación](docs/01-alu-estructura.md)
2. [Prefix Adder (Kogge-Stone)](docs/02-prefix-adder.md)
3. [Divisor en arreglo](docs/03-divisor.md)
4. [Banderas NZCV y bus triestado AND/OR](docs/04-flags-triestado.md)
5. [Verificación](docs/05-verificacion.md)
6. Parte 2 — Physical Design + Synopsys (`parte2/`):
   [estado y bloqueador](parte2/docs/00-estado.md) ·
   [tratamiento del triestado en síntesis](parte2/docs/04-triestado.md) (pendiente) ·
   [discusión con los reportes reales](parte2/docs/05-discusion.md) (pendiente)

## Estructura del repositorio

```
src/           mux2.sv, prefix_adder.sv, array_divider.sv, alu_plus.sv
sim/           testbench.sv (35 checks, WIDTH=8), testbench_widths.sv (10 checks, WIDTH=16/32)
docs/          diseño de la ALU+, prefix adder, divisor, flags/triestado, verificación
guiones/       guion para la presentación oral / video (Parte 1)
parte2/
  rtl/         alu_plus_sync.sv (envoltorio síncrono, registros de entrada/salida)
  sim/         testbench_sync.sv (pre-chequeo funcional, antes de VCS/Verdi)
  scripts/     constraints.sdc, synth_dc.tcl (Design Compiler), impl_icc2.tcl (IC Compiler II)
  docs/        estado/bloqueador, discusión (pendiente de correr en el servidor)
```

## Cómo reproducir (Parte 1)

Simulación con Vivado Simulator 2026.1 por línea de comandos (sin GUI):

```bash
cd ExamenFinal
xvlog --sv src/mux2.sv src/prefix_adder.sv src/array_divider.sv src/alu_plus.sv sim/testbench.sv
xelab testbench -s testbench_sim
xsim testbench_sim -runall
```

Tiene que terminar en `TESTBENCH: PASS` (35/35). Igual para
`sim/testbench_widths.sv` → `xelab testbench_widths -s testbench_widths_sim`.

## Herramientas usadas

- **Vivado Simulator 2026.1** (`xvlog`/`xelab`/`xsim`, línea de comandos)
  para simular y verificar toda la Parte 1 — mismo criterio que
  [P3](../P3/README.md).
- **Design Compiler** / **IC Compiler II** (Synopsys), PDK SkyWater sky130
  (`sky130_fd_sc_hd`) — Parte 2, scripts ya preparados en `parte2/scripts/`
  siguiendo el flujo real del curso (ver
  [`parte2/docs/00-estado.md`](parte2/docs/00-estado.md)), pendiente de
  correr en el servidor.

## Video y presentación

Pendiente de grabar: guion en [`guiones/guion_parte1_alu.md`](guiones/guion_parte1_alu.md).
El PDF pide un video sin límite de tiempo por cada inciso (enlace de
YouTube oculto, no privado) y una presentación oral de 15 minutos.
