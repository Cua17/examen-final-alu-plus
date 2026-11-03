# Discusión (PDF, Parte 2, item 7)

> Respuestas de la parte 1 (Design Compiler) con números reales de
> `dc_shell-t` corrido en el servidor del curso el 2026-11-02, librería
> `M31LLSC733GL150MS` (corner típico 25°C/TT/3.3V), proceso GF150MCU — ver
> [`00-estado.md`](00-estado.md) para el detalle completo. La parte de
> IC Compiler II (item 2) sigue pendiente: la librería física M31 que
> tenemos es formato Milkyway clásico, y esta instalación de ICC2 no tiene
> ningún soporte para Milkyway (confirmado con `info commands *milkyway*`
> / `*ndm*` dentro de `icc2_shell`, sin resultados) — falta una versión en
> formato NDM antes de poder correr `place_opt`→`clock_opt`→`route_auto`→`route_opt`.

## 1. Reportes de Design Compiler

Fuente: `reportes/report_qor.txt`, `reportes/report_timing.txt`,
`reportes/report_area.txt`, `reportes/report_power.txt`,
`reportes/report_constraint.txt`, `reportes/report_reference.txt`.

### 1. ¿Cuál es el área total del diseño y cuántas celdas contiene?

**30448.05 µm²** de área total de celda (`report_area.txt`), con
**2671 celdas** (2574 combinacionales + 87 secuenciales, 0 macros). El
divisor (`array_divider_WIDTH16`) domina el diseño: **23454.95 µm² — el
77% del área total** — frente a solo 959.62 µm² (3.2%) del sumador
Prefix Adder y unos pocos cientos de µm² por cada mux de la jerarquía.
Esto confirma la hipótesis que habíamos anotado antes de correr la
síntesis ([`01-conceptos-dc-icc2.md`](01-conceptos-dc-icc2.md)): el
divisor en arreglo, al ser lógica combinacional profunda sin compartir
hardware entre etapas, es por lejos el bloque más caro del diseño.

### 2. ¿Cuál es el período del reloj y qué frecuencia representa?

Período de reloj: **20 ns → 50 MHz**. Es un punto de partida conservador
(no un número optimizado) para un proceso de 150nm, bastante más lento
que un nodo moderno; ver la discusión de optimización en la pregunta 6.

### 3. ¿Qué significan WNS y TNS? ¿El diseño cumple timing?

**WNS** (Worst Negative Slack) es el peor caso de incumplimiento de
timing entre todos los caminos del diseño — cuánto le faltó al camino
más lento para llegar a tiempo. **TNS** (Total Negative Slack) es la
suma de todos los incumplimientos de todos los caminos que violan la
restricción — mide qué tan extendido está el problema, no solo el peor
caso.

En este diseño: **WNS = 0.00 ns, TNS = 0.00 ns, 0 caminos violados**
(`report_qor.txt`, `report_constraint.txt`: *"This design has no
violated constraints"*). El diseño **cumple timing** a 20 ns — pero el
slack del camino crítico es exactamente 0.00 ns (no hay margen), lo cual
es información real y relevante: `compile_ultra` optimizó el diseño
hasta encajar justo en el límite del período dado, así que 20 ns es
prácticamente el mínimo alcanzable con esta configuración (ver pregunta
6 sobre cómo bajarlo más).

### 4. ¿Cuál es el critical path? Identificar su Startpoint, Endpoint y Path Group.

- **Startpoint:** `b_reg_reg[5]` (flip-flop del registro de entrada `b`,
  bit 5)
- **Endpoint:** `z_out_reg` (flip-flop de la bandera Zero, en el
  registro de salida)
- **Path Group:** `clk` (camino registro→registro, el grupo de mayor
  profundidad lógica — 122 niveles de lógica según `report_qor.txt`)
- **Data arrival time:** 18.66 ns — **Data required time:** 18.67 ns —
  **Slack:** 0.00 ns (MET, justo en el límite)

El camino recorre `u_alu/u_divider` (el divisor en arreglo) de punta a
punta — más de 100 celdas en cascada — y después pasa por tres niveles
del árbol de muxes del resultado (`u_a3` → `u_b1` → `u_c0`, que
corresponden a los multiplexores del `alu_plus` original más las
funciones nuevas) antes de llegar al flip-flop de la bandera Zero.

### 5. ¿Qué operaciones o celdas provocan el mayor retraso en ese camino?

El retraso se acumula en una larga cadena de celdas lógicas pequeñas del
divisor — sobre todo `NAND2X*`, `NOR2X*`, `AOI12X*` y `OAI12X*` de baja
capacidad de carga (`X1`/`X2`), cada una aportando entre 0.07 y 0.3 ns
(ver `report_timing.txt` completo). No es una sola celda lenta: es la
**profundidad estructural del divisor por restas sucesivas** — cada una
de las 16 etapas del `array_divider` depende del resultado (resta +
selección) de la etapa anterior, así que el retraso se va sumando etapa
por etapa sin manera de paralelizarlo con esta arquitectura.

### 6. ¿Qué optimizaciones implementarían para mejorar el diseño? Justificar su respuesta

- **Relajar el período de reloj** (p.ej. a 22–24 ns) le daría margen real
  a `compile_ultra` para usar celdas más pequeñas/de menor potencia en
  vez de forzar el camino al límite — ahora mismo el slack es
  exactamente 0.00 ns, señal de que DC está "estirando" la lógica al
  máximo para cumplir 20 ns.
- **Segmentar el divisor en más de un ciclo de reloj** (p.ej. una etapa
  de 4 bits por ciclo con una máquina de estados, en vez de las 16 etapas
  combinacionales en un solo ciclo) reduciría drásticamente la
  profundidad lógica del camino crítico a costa de más ciclos de latencia
  — el cambio arquitectónico con más impacto real, dado que el divisor es
  el 77% del área y domina por completo el camino crítico.
  `compile_ultra -scan -no_autoungroup` solo optimiza dentro de la
  arquitectura combinacional dada; no puede re-segmentar el algoritmo.
- **Usar `group_path` con pesos** o restricciones más finas por grupo no
  ayudaría aquí porque el área cara (divisor) y el camino crítico ya
  coinciden — no hay margen entre bloques para "robarle" tiempo a uno
  para dárselo a otro.

## 2. Reportes de IC Compiler II

Corrido completo en el servidor el 2026-11-02:
`create_lib` (librería M31 vía LEF, no Milkyway — ver
[`00-estado.md`](00-estado.md) para el porqué) →
`place_opt` → `clock_opt` → `route_auto` → `route_opt` → `write_gds`,
los cinco sin errores fatales, GDSII final exportado
(`parte2/gds/alu_plus_sync.gds`, 1.86 MB). Fuente de los números:
`reportes/icc2/{00_pre_place,10_place_opt,20_clock_opt,30_route_auto,40_post_route}/report_qor.rpt`.

**Resultado honesto, no es "todo perfecto":** a diferencia de Design
Compiler (que cumplía timing con slack 0.00 exacto a nivel lógico), el
diseño **no cumple timing** una vez metidos los efectos físicos reales
(parásitos de ruteo, celdas tap, árbol de reloj real) — el camino
crítico final queda violado por **-1.45 ns**. Esto es exactamente el
tipo de brecha pre-layout vs. post-layout que esta sección del examen
busca que se entienda, así que se reporta tal cual salió, sin suavizarlo.

### 1. ¿Cómo cambia el WNS entre las diferentes etapas?

| Etapa | WNS (slack, grupo `clk`) | TNS | Caminos violados | Peor hold | Violaciones hold |
|---|---|---|---|---|---|
| `00_pre_place` (post-floorplan, antes de optimizar) | -6.63 ns | -115.36 ns | 18 | -0.52 ns | 20 |
| `10_place_opt` | -3.02 ns | -49.66 ns | 18 | -0.50 ns | 19 |
| `20_clock_opt` | -1.26 ns | -15.22 ns | 18 | **0.00 ns** | **0** |
| `30_route_auto` | -1.45 ns | -18.52 ns | 18 | -0.01 ns | 2 |
| `40_post_route` (`route_opt`, final) | -1.45 ns | -18.18 ns | 18 | -0.01 ns | 1 |

El WNS mejora muchísimo entre `pre_place` y `clock_opt` (de -6.63 a
-1.26 ns) porque `place_opt` y `clock_opt` optimizan activamente timing
(upsizing de celdas, buffering, useful skew). Pero **empeora un poco**
después de `route_auto` (-1.45 ns) porque ahí se reemplazan las
estimaciones de parásitos por los parásitos **reales** extraídos del
ruteo — siempre más pesados que la estimación. `route_opt` no logró
recuperar ese margen perdido (se mantuvo en -1.45 ns).

### 2. ¿Cómo afectan el clock skew y las latencias del reloj al timing?

El efecto más claro está en el **hold**: antes de `clock_opt` había
19-20 violaciones de hold (peor caso -0.50/-0.52 ns) porque el reloj
llegaba a cada registro con una latencia "ideal" (sin árbol real). Una
vez que `clock_opt` construye el árbol de reloj real con *useful skew*
(cada rama del reloj llega en el momento justo para ayudar al camino más
lento), las violaciones de hold bajan a **0**. El ruteo real del reloj
después (`route_auto`/`route_opt`) reintroduce una violación de hold
mínima (-0.01 ns, 1-2 caminos) — esperable, ya no es skew "ideal" sino
el de los cables reales.

### 3. ¿Aumentó el área respecto a Design Compiler? ¿Por qué?

Sí, pero hay que separar dos números:

- **Área de celdas lógicas** (lo que DC reporta): DC = 30448.05 µm²,
  ICC2 post-route = 30367.41 µm² — prácticamente igual (incluso un poco
  menor, por el swapping de celdas que hace `place_opt`/`route_opt`
  durante la optimización de timing/área).
- **Área física total** (celdas lógicas + físicas): ICC2 reporta
  **33238.19 µm²** — un 9% más que DC. La diferencia son las **1764
  celdas tap** (`TAP01AS7`) que `create_tap_cells` insertó en el
  floorplan — necesarias para la regla de proceso (conexión de pozo/
  substrate contra latch-up), pero DC nunca las ve porque son un
  concepto 100% físico, no lógico.

### 4. ¿Existen violaciones de setup, hold, capacitancia o transición?

- **Setup:** sí, 18 caminos violados, peor caso -1.45 ns (ver tabla
  arriba). Startpoint `b_reg_reg[6]`, Endpoint `z_out_reg`, Path Group
  `clk` — mismo patrón que en DC: el camino pasa por
  `u_alu/u_divider` completo.
- **Hold:** 1 violación residual, -0.01 ns — prácticamente resuelta por
  `clock_opt`.
- **Capacitancia/transición:** `report_qor.rpt` no muestra violaciones de
  max transition ni max capacitancia en el diseño final (`MaxTrnV`,
  `MaxCapV` = 0 en el resumen de `route_opt`).

### 5. ¿Qué muestran las verificaciones de routing, legalidad y conexiones de alimentación?

- `check_legality` (post-route): **"check_legality succeeded"** — sin
  violaciones (celdas fuera de sitio, fuera de región, de voltage area,
  de movebound, de márgenes de CTS o de coloring: todas en 0).
- `check_routes` (post-route): **0 nets abiertas**, **0 DRC**, sin
  violaciones de antena (no hay reglas de antena definidas en este PDK
  para este flujo básico).
- `check_pg_connectivity` (post-placement): **0 celdas, vías o cables
  flotantes** tanto en VDD como en VSS — las 2661 celdas estándar están
  correctamente conectadas a alimentación (comparado con el chequeo
  hecho justo después del floorplan, donde las 2661 celdas aparecían
  "flotantes" porque todavía no estaban colocadas — es el orden esperado,
  no un error).
