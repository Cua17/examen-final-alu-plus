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
PDK real de GlobalFoundries 150nm ("150MCU") + celdas M31, tal como dice
el PDF — ver [`parte2/docs/00-estado.md`](parte2/docs/00-estado.md) para el
estado y lo que falta) queda preparada en `parte2/` a la espera de correr
en el servidor del curso.

José Daniel Cuá Fagiani — Carné 21200

## Resultados principales (Parte 1 — verificados)

| Parte | Resultado |
|---|---|
| `sim/testbench.sv` (WIDTH=8, xvlog/xelab/xsim) | **35/35 PASS**, sin warnings |
| `sim/testbench_widths.sv` (WIDTH=16 y WIDTH=32, misma arquitectura) | **10/10 PASS** |
| `parte2/sim/testbench_sync.sv` (envoltorio síncrono, WIDTH=16, Vivado xsim) | **5/5 PASS** |
| `parte2/sim/testbench_sync.sv` con **VCS** real (servidor del curso) | **5/5 PASS** |
| Síntesis **Design Compiler** real (GF150MCU + M31LLSC733GL150MS) | **Timing OK — slack +4.43 ns, 0 violaciones**, 1796 celdas, 18478 µm² (40 ns / 25 MHz) |
| Flujo físico **IC Compiler II** real (floorplan→place→CTS→route→GDSII) | **Completo — timing post-layout cumple**, slack +0.81 ns, 0 violaciones de setup/hold |

Reportes reales y respuestas de la Discusión (PDF item 7.1), incluyendo
la comparación de timing/área entre DC e ICC2 etapa por etapa, en
[`parte2/docs/05-discusion.md`](parte2/docs/05-discusion.md) y
[`parte2/docs/04-triestado.md`](parte2/docs/04-triestado.md).

Parte 2 completa de punta a punta: scripts, netlist, SDC, reportes de
cada etapa de ICC2 y el GDSII final en `parte2/gds/alu_plus_sync.gds`.
Ver [`parte2/docs/00-estado.md`](parte2/docs/00-estado.md) para el
detalle de cómo se resolvió cada bloqueo técnico encontrado en el camino
(librería M31 vía LEF, nombres de capas/celdas reales de GF+M31, redes
de alimentación, parásitos, densidad de floorplan).

## Contenido

1. [Estructura de la ALU+ y asignación](docs/01-alu-estructura.md)
2. [Prefix Adder (Kogge-Stone)](docs/02-prefix-adder.md)
3. [Divisor en arreglo](docs/03-divisor.md)
4. [Banderas NZCV y bus triestado AND/OR](docs/04-flags-triestado.md)
5. [Verificación](docs/05-verificacion.md)
6. Parte 2 — Physical Design + Synopsys (`parte2/`):
   [estado y cómo se resolvió cada bloqueo](parte2/docs/00-estado.md) ·
   [tratamiento del triestado en síntesis](parte2/docs/04-triestado.md) ·
   [discusión con los reportes reales](parte2/docs/05-discusion.md)

## Estructura del repositorio

```
src/           mux2.sv, prefix_adder.sv, array_divider.sv, alu_plus.sv
sim/           testbench.sv (35 checks, WIDTH=8), testbench_widths.sv (10 checks, WIDTH=16/32)
docs/          diseño de la ALU+, prefix adder, divisor, flags/triestado, verificación
guiones/       guion completo del video (Parte 1 y Parte 2), con demo en vivo en Vivado
parte2/
  rtl/         alu_plus_sync.sv (envoltorio síncrono, registros de entrada/salida)
  sim/         testbench_sync.sv (verificado con Vivado xsim y VCS real)
  scripts/     synth_dc.tcl (Design Compiler), impl_icc2.tcl (IC Compiler II) -- ambos corridos reales
  netlist/     netlist sintetizada (alu_plus_sync_synth.v) y SDC de DC
  reportes/    reportes reales de DC e ICC2 (uno por etapa), logs de synth_dc/impl_icc2/VCS
  gds/         alu_plus_sync.gds (GDSII final de ICC2) + img/ (imagen del layout real)
  icc2_db/     base de datos final de ICC2 (lib_icc2_alu_plus_sync)
  docs/        estado del flujo, discusión con reportes reales, tratamiento del triestado
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
- **Design Compiler** / **IC Compiler II** (Synopsys), PDK real de
  GlobalFoundries 150nm ("150MCU") + celdas M31LLSC733GL150MS — Parte 2,
  corrida completa en el servidor del curso (síntesis + floorplan + place
  + CTS + route + GDSII), ver
  [`parte2/docs/00-estado.md`](parte2/docs/00-estado.md) para el detalle
  completo de cómo se resolvió cada bloqueo técnico.

## Video y presentación

Pendiente de grabar: guion completo (Parte 1 y Parte 2, con demo en
vivo en el visor de formas de onda de Vivado) en
[`guiones/guion_video_examen_final.md`](guiones/guion_video_examen_final.md).
El PDF pide un video sin límite de tiempo por cada inciso (enlace de
YouTube oculto, no privado) y una presentación oral de 15 minutos.
