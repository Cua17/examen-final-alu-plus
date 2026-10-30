# Discusión (PDF, Parte 2, item 7) — PENDIENTE

> Pendiente de completar con los reportes reales de `synth_dc.tcl` /
> `impl_icc2.tcl` una vez corran en el servidor del curso — ver
> [`00-estado.md`](00-estado.md). No se llenan estas respuestas con números
> supuestos: cada una sale directo de un reporte real (mismo criterio que
> el resto del curso — "datasheets reales, nada inventado").

## 1. Reportes de Design Compiler

Fuente: `reportes/report_qor.txt`, `reportes/report_timing.txt`,
`reportes/report_area.txt`, `reportes/report_power.txt`,
`reportes/report_constraint.txt`.

1. ¿Cuál es el área total del diseño y cuántas celdas contiene?
2. ¿Cuál es el período del reloj y qué frecuencia representa?
3. ¿Qué significan WNS y TNS? ¿El diseño cumple timing?
4. ¿Cuál es el critical path? Identificar su Startpoint, Endpoint y Path
   Group.
5. ¿Qué operaciones o celdas provocan el mayor retraso en ese camino?
6. ¿Qué optimizaciones implementarían para mejorar el diseño? Justificar.

## 2. Reportes de IC Compiler II

Fuente: `reportes/icc2/qor_*.txt`, `reportes/icc2/timing_*.txt`,
`reportes/icc2/clock_tree.txt`, `reportes/icc2/check_*.txt`.

1. ¿Cómo cambia el WNS entre `place_opt` → `clock_opt` → `route_auto` →
   `route_opt`?
2. ¿Cómo afectan el clock skew y las latencias del reloj al timing?
3. ¿Aumentó el área respecto a Design Compiler? ¿Por qué?
4. ¿Existen violaciones de setup, hold, capacitancia o transición?
5. ¿Qué muestran las verificaciones de routing, legalidad y conexiones de
   alimentación?
