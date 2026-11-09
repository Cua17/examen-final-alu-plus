# Discusión (PDF, Parte 2, item 7)

> Respuestas con números reales de las corridas en el servidor del curso,
> librería `M31LLSC733GL150MS` (corner típico 25°C/TT/3.3V), proceso
> GF150MCU. Resultado **final** (2026-11-09): período de reloj 40 ns
> (25 MHz) — el diseño cumple timing de punta a punta, sin violaciones.
> Ver [`00-estado.md`](00-estado.md) para el historial completo del
> ajuste de período (20→24→25→30→40 ns) y el porqué de cada paso.

## 1. Reportes de Design Compiler

Fuente: `reportes/report_qor.txt`, `reportes/report_timing.txt`,
`reportes/report_area.txt`, `reportes/report_power.txt`,
`reportes/report_constraint.txt`, `reportes/report_reference.txt`.

### 1. ¿Cuál es el área total del diseño y cuántas celdas contiene?

**18477.85 µm²** de área total de celda, con **1796 celdas** (1699
combinacionales + 87 secuenciales, 0 macros). El divisor
(`array_divider_WIDTH16`) sigue dominando el diseño: **12345.98 µm² — el
66.8% del área total** — frente a 959.62 µm² (5.2%) del Prefix Adder y
unos pocos cientos de µm² por cada mux. Confirma, igual que en la corrida
anterior, que el divisor en arreglo es por lejos el bloque más caro
(ver [`01-conceptos-dc-icc2.md`](01-conceptos-dc-icc2.md)).

### 2. ¿Cuál es el período del reloj y qué frecuencia representa?

Período de reloj final: **40 ns → 25 MHz**. No es el primer número
probado — se llegó ahí ajustando con datos reales (ver pregunta 6 y
[`00-estado.md`](00-estado.md) para el historial completo de por qué
20/24/25/30 ns no alcanzaban).

### 3. ¿Qué significan WNS y TNS? ¿El diseño cumple timing?

**WNS** (Worst Negative Slack) es el peor caso de incumplimiento de
timing entre todos los caminos del diseño. **TNS** (Total Negative
Slack) es la suma de todos los incumplimientos de todos los caminos que
violan la restricción.

En este diseño: **0 caminos violados, 0 ns de TNS**
(`report_constraint.txt`: *"This design has no violated constraints"*).
El diseño **cumple timing** con margen real: el camino crítico tiene
**4.43 ns de slack positivo** (no al límite como en la corrida anterior a
20 ns) — hay espacio real, no solo "justo pasa".

### 4. ¿Cuál es el critical path? Identificar su Startpoint, Endpoint y Path Group.

- **Startpoint:** `b_reg_reg[1]` (flip-flop del registro de entrada `b`,
  bit 1)
- **Endpoint:** `z_out_reg` (flip-flop de la bandera Zero)
- **Path Group:** `clk`
- **Data arrival time:** 33.25 ns — **Data required time:** 37.68 ns —
  **Slack:** 4.43 ns (MET, con margen real)

El camino sigue el mismo patrón estructural que en la corrida anterior:
atraviesa `u_alu/u_divider` (el divisor en arreglo) de punta a punta y
después el árbol de muxes del resultado antes de llegar al flip-flop de
la bandera Zero.

### 5. ¿Qué operaciones o celdas provocan el mayor retraso en ese camino?

Igual que antes: no es una celda lenta puntual, es la **profundidad
estructural del divisor por restas sucesivas** — cada una de las 16
etapas del `array_divider` depende del resultado de la etapa anterior,
así que el retraso se acumula etapa por etapa. Lo que sí cambió: con más
margen de período, `compile_ultra` usó celdas más chicas en general
(menos `X2`/`X4`, más `X1`) porque ya no necesitaba empujar tanto la
velocidad — eso explica la caída de área de 30448 a 18477 µm².

### 6. ¿Qué optimizaciones implementarían para mejorar el diseño? Justificar su respuesta

Esta pregunta ya no es hipotética — se probó en la práctica, con
resultados reales:

- **Relajar el período de reloj SÍ funcionó, pero no de forma lineal.**
  Se probó 20→24→25→30→40 ns, corriendo DC + ICC2 completos cada vez.
  Entre 20 y 30 ns el slack post-layout se mantuvo pegado a ~0.00 ns sin
  importar cuánto subiera el período (-1.45 → -0.01 → -0.03 → -0.0034 ns)
  — **`compile_ultra` y `place_opt`/`route_opt` optimizan para cumplir
  justo la restricción, no para maximizar margen**: cualquier slack extra
  que aparece lo "gastan" achicando celdas para ahorrar área/potencia.
  Recién a 40 ns el optimizador se quedó sin más celdas para achicar (ya
  usaba las más chicas disponibles en gran parte del divisor) y el
  margen positivo se mantuvo (+4.43 ns en DC, +0.81 ns post-route en
  ICC2). Esto es un comportamiento real y documentado de cómo trabajan
  estas herramientas, no algo que se sepa de antemano sin probarlo.
- **Segmentar el divisor en más de un ciclo de reloj** seguiría siendo el
  cambio arquitectónico de mayor impacto si se necesitara una frecuencia
  mucho más alta (p. ej. volver a 50 MHz o más) sin depender de bajar
  tanto el período — reduciría la profundidad lógica del camino crítico
  a costa de más ciclos de latencia. No hizo falta para este entregable,
  pero sería el siguiente paso si 25 MHz no alcanzara para la aplicación.
- **`group_path` con pesos** seguiría sin ayudar aquí por la misma razón
  que antes: el área cara (divisor) y el camino crítico coinciden, no hay
  margen entre bloques para redistribuir.

## 2. Reportes de IC Compiler II

Corrido completo en el servidor, librería M31 vía LEF (no Milkyway —
ver [`00-estado.md`](00-estado.md) para el porqué): `create_lib` →
`place_opt` → `clock_opt` → `route_auto` → `route_opt` → `write_gds`,
sin errores fatales, GDSII final exportado
(`parte2/gds/alu_plus_sync.gds`). Fuente de los números:
`reportes/icc2/{00_pre_place,10_place_opt,20_clock_opt,30_route_auto,40_post_route}/report_qor.rpt`
(última corrida, 40 ns).

**Resultado final: el diseño cumple timing de punta a punta, sin
violaciones de ningún tipo.**

### 1. ¿Cómo cambia el WNS entre las diferentes etapas?

| Etapa | Slack (grupo `clk`) | TNS | Caminos violados | Peor hold | Violaciones hold |
|---|---|---|---|---|---|
| `00_pre_place` (post-floorplan, antes de optimizar) | -10.90 ns | -188.80 ns | 18 | -2.03 ns | 20 |
| `10_place_opt` | +0.02 ns | 0.00 ns | 0 | -2.09 ns | 20 |
| `20_clock_opt` | +1.38 ns (mejor punto) | 0.00 ns | 0 | 0.00 ns | **0** |
| `30_route_auto` | +0.84 ns | 0.00 ns | 0 | -0.02 ns | 3 |
| `40_post_route` (`route_opt`, final) | **+0.81 ns** | **0.00 ns** | **0** | **0.00 ns** | **0** |

El patrón es el mismo que en la corrida a 20 ns: `place_opt` ya corrige
el setup de golpe (de -10.90 a +0.02 ns, porque antes de optimizar las
celdas están sin dimensionar), `clock_opt` lo mejora un poco más con
*useful skew* (+1.38 ns, el mejor punto de toda la corrida), y
`route_auto` lo empeora levemente (+0.84 ns) al reemplazar las
estimaciones de parásitos por los reales del ruteo. La diferencia con la
corrida a 20 ns es que ahora el margen de partida (+4.43 ns en DC) alcanzó
para absorber esa caída sin volver a violación — a 20 ns ese mismo
patrón de caída post-`route_auto` sí cruzaba a negativo porque no había
colchón.

### 2. ¿Cómo afectan el clock skew y las latencias del reloj al timing?

Igual que en la corrida anterior: `clock_opt` es la etapa que más ayuda
al hold, construyendo el árbol de reloj real con *useful skew* en vez de
una latencia "ideal". Con el margen de 40 ns, el resultado final quedó
en **0 violaciones de hold** (no solo "casi cero" como antes) — el
árbol de reloj real, con el ruteo incluido, no generó ningún problema.

### 3. ¿Aumentó el área respecto a Design Compiler? ¿Por qué?

- **Área de celdas lógicas:** DC = 18477.85 µm², ICC2 post-route =
  19914.85 µm² — prácticamente igual, misma relación que antes.
- **Área física total** (con celdas tap/filler): ICC2 reporta
  21724.42 µm² — sigue siendo mayor que la de DC por la misma razón que
  en la corrida anterior: las celdas tap (`TAP01AS7`) que
  `create_tap_cells` inserta son un concepto físico que DC nunca ve.

### 4. ¿Existen violaciones de setup, hold, capacitancia o transición?

**No, ninguna.** 0 caminos de setup violados, 0 de hold,
`report_qor.rpt` sin violaciones de max transition ni max capacitancia
(`MaxTrnV`, `MaxCapV` = 0). Startpoint `b_reg_reg[15]`, Endpoint
`z_out_reg`, Path Group `clk` — mismo camino estructural que en DC y que
en la corrida anterior, pero ahora con margen (+0.81 ns en vez de
negativo).

### 5. ¿Qué muestran las verificaciones de routing, legalidad y conexiones de alimentación?

- `check_legality` (post-route): **"check_legality succeeded"** — sin
  violaciones de ningún tipo.
- `check_routes` (post-route): **0 nets abiertas, 0 DRC**, sin
  violaciones de antena.
- `check_pg_connectivity` (post-placement y post-route): **0 celdas,
  vías o cables flotantes** en VDD y VSS — alimentación correctamente
  conectada en todas las celdas del diseño.

## Resumen: bus triestado (confirmación tras la corrida final)

La netlist final sigue mapeando `and_or_bus` a **32 instancias de
`TRIINVX1AS7`** (mismo resultado que en la corrida anterior — el período
de reloj no afecta cómo se sintetiza el triestado). Ver
[`04-triestado.md`](04-triestado.md) para el detalle completo.
