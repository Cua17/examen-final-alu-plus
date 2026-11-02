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

## 2. Reportes de IC Compiler II — PENDIENTE

No se completan estas respuestas todavía: requieren la librería física
M31 en formato NDM (ver nota al inicio) para poder correr
`place_opt`→`clock_opt`→`route_auto`→`route_opt` de verdad. Se completan
en cuanto esté resuelto — ver [`00-estado.md`](00-estado.md).

1. ¿Cómo cambia el WNS entre las diferentes etapas?
2. ¿Cómo afectan el clock skew y las latencias del reloj al timing?
3. ¿Aumentó el área respecto a Design Compiler? ¿Por qué?
4. ¿Existen violaciones de setup, hold, capacitancia o transición?
5. ¿Qué muestran las verificaciones de routing, legalidad y conexiones de
   alimentación?
