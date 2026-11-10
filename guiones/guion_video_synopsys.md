# Guion — Video corto: herramientas de Synopsys en vivo

José Daniel Cuá Fagiani — Carné 21200. Video corto adicional, pedido
por el profesor después de ver el video principal: mostrar las
herramientas de Synopsys (Design Compiler, IC Compiler II, VCS) de la
Parte 2 corriendo en vivo, conectado al servidor del curso. Duración
estimada: 4-6 minutos.

Todo esto se escribe en vivo durante la grabación — no hay nada
pre-corrido para esta parte, a diferencia del video principal. Los
tres comandos de abajo ya se probaron antes de grabar y funcionan
(ver resultado esperado de cada uno).

## Antes de grabar

- Conectado por SSH al servidor (`ssh -X cuax@10.252.1.11`), parado en
  `~/bootcamp_data/ExamenFinal_ALU/ExamenFinal/parte2`.
- Pantalla compartida mostrando la terminal, letra grande para que se
  lea bien en el video.

## 0. Apertura (20 seg)

**Decir:**
"Hola profe, esto es un video corto aparte, mostrando en vivo las
herramientas de Synopsys que usé para la Parte 2 del examen —
conectado ahora mismo al servidor del curso, no son capturas de
antes."

## 1. Design Compiler (1.5-2 min)

**Escribir:**
```bash
dc_shell-t
```

**Decir mientras carga** (tarda unos segundos en inicializar
licencias):
"Esto es Design Compiler corriendo de verdad en el servidor de la
universidad — versión X-2025.06-SP5-5."

**Escribir, una vez que aparezca el prompt `dc_shell>`:**
```bash
read_ddc netlist/alu_plus_sync_synth.ddc
report_timing
```

**Decir (señalando el resultado real):**
"Esto carga el diseño ya sintetizado y pide el reporte de timing real.
Abajo dice `slack (MET)` en `4.43` — exactamente el número que ya
documenté, pero corriendo ahora mismo, no copiado de un archivo."

**Escribir:**
```bash
exit
```

## 2. IC Compiler II (1.5-2 min)

**Escribir:**
```bash
icc2_shell
```

**Decir mientras carga:**
"Y esto es IC Compiler II, la herramienta de diseño físico —
versión Y-2026.03-SP2."

**Escribir, una vez que aparezca el prompt `icc2_shell>`:**
```bash
open_lib scripts/lib_icc2_alu_plus_sync
open_block alu_plus_sync_route_opt
report_qor
```

**Decir (señalando el resultado real, grupo `clk`):**
"Esto abre la base de datos final, ya colocada y ruteada, y pide el
reporte de calidad. En el grupo de reloj `clk` —el que importa, el
camino crítico real del divisor— da `Critical Path Slack: 0.81` y
`No. of Hold Violations: 0`, igual que lo que reporté. Y acá abajo el
área de celdas, `19914.85` micrómetros cuadrados, también coincide."

**Escribir:**
```bash
exit
```

## 3. VCS (1 min)

**Escribir:**
```bash
cd vcs_run
./simv_sync
```

**Decir (señalando el resultado real):**
"Y esto es VCS, el simulador de Synopsys — la verificación que el PDF
pedía específicamente con esta herramienta, no con Vivado. Corre el
mismo envoltorio síncrono de la Parte 2, y da `5 PASS, 0 FAIL`, igual
que en mi documentación."

## 4. Cierre (20 seg)

**Decir:**
"Esas son las tres herramientas de Synopsys que usé: Design Compiler
para la síntesis, IC Compiler II para el diseño físico, y VCS para la
verificación — las tres corriendo ahora mismo contra el PDK real de la
universidad, con los mismos resultados que ya documenté. Gracias."
