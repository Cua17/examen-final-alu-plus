# Conceptos del flujo DC → ICC2 (resumen, aplicado a `alu_plus_sync`)

Basado en el material de apoyo del profesor (`DC_ICC2_presentacion.pdf`,
carpeta "DC y ICC2" en Drive) y en los scripts reales del curso
(`TCL_DC_ICC2_originales_y_comentados.zip`), adaptado a este bloque
(`alu_plus_sync`, 16 bits) en vez del CPU del material de apoyo.

## DC e ICC2 no hacen lo mismo

- **Design Compiler**: lee RTL (`.sv`), aplica restricciones (`.sdc`),
  mapea a celdas estándar de la librería (`.db`), optimiza timing/área/power
  y saca un **netlist de compuertas** — todavía sin ubicación física.
- **ICC2**: toma ese netlist y lo convierte en layout real — floorplan,
  power grid, placement, árbol de reloj (CTS), routing — con parásitos
  reales (capacitancia/resistencia de los cables), que DC no conoce.

En nuestro caso: `synth_dc.tcl` hace la primera mitad, `impl_icc2.tcl` la
segunda.

## Qué entra y qué sale de cada etapa

| | Entradas | Salidas |
|---|---|---|
| DC | `src/*.sv` + `parte2/rtl/alu_plus_sync.sv`, constraints (inline en `synth_dc.tcl`), librería `sky130_fd_sc_hd` | netlist (`alu_plus_sync_synth.v`), SDC actualizado, reportes |
| ICC2 | netlist + SDC de DC, tech file + NDM de sky130 | GDSII, reportes físicos (QoR/timing/power por etapa) |

## Por qué sky130 y no GF150nm/M31

El PDF del examen menciona GF 150nm + M31, pero el material de apoyo real
usa SkyWater sky130 (`sky130_fd_sc_hd`) — PDK open-source, el que
efectivamente está instalado en el servidor del curso. Ver
[`00-estado.md`](00-estado.md) para el detalle completo de esta corrección.

## El `ALUControl` extendido y la ruta crítica esperada

A diferencia del CPU del material de apoyo (que compara estrategias
Baseline/PPA1/PPA2 con clocks distintos), `alu_plus_sync` es un solo
bloque registrado con una latencia de 2 ciclos (registro de entrada → ALU+
combinacional → registro de salida, ver
[`../rtl/alu_plus_sync.sv`](../rtl/alu_plus_sync.sv)). La ruta crítica
candidata, antes de tener el `report_timing` real, es la lógica
combinacional más profunda dentro de ese único ciclo:

- El **divisor en arreglo** (`array_divider`, WIDTH=16 etapas en cascada,
  cada una con una resta de WIDTH+1 bits) es, por construcción, la lógica
  más profunda de las tres (vs. `prefix_adder`, que es `log2(16)=4`
  etapas). Es razonable esperar que el critical path real pase por ahí —
  hipótesis a confirmar con `report_timing -delay_type max` una vez corra
  la síntesis real (no se reporta como hecho hasta no tener el reporte).

## Bus triestado y síntesis ASIC

Pregunta específica del PDF (Parte 2, item 4): cómo se transforma
`and_or_bus` (ver
[`../../docs/04-flags-triestado.md`](../../docs/04-flags-triestado.md)) al
sintetizar. Respuesta pendiente de `report_reference -hierarchy` y la
netlist real — ver [`04-triestado.md`](04-triestado.md).

## Preguntas de la Discusión (PDF item 7) — dónde buscar cada respuesta

Ver [`05-discusion.md`](05-discusion.md) para las preguntas exactas y,
entre paréntesis, el reporte real de donde debería salir cada respuesta
(`report_qor`, `report_timing`, `report_area`, etc.) — no se completan con
suposiciones.
