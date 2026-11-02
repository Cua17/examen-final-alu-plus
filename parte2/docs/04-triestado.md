# Tratamiento del bus triestado en síntesis

> Respondido con los reportes reales de `dc_shell-t` corrido en el
> servidor el 2026-11-02 (librería `M31LLSC733GL150MS`) — ver
> [`00-estado.md`](00-estado.md). El PDF (Parte 2, item 4) pide explicar
> "cómo se transformaron los bloques del RTL, incluyendo el tratamiento de
> los buses triestado" — esta sección responde eso puntualmente para
> `and_or_bus` ([`docs/04-flags-triestado.md`](../../docs/04-flags-triestado.md)
> en la Parte 1 explica por qué existe ese bus).

## 1. ¿`compile_ultra` mapeó `and_or_bus` a celdas triestado reales, o lo colapsó a un mux?

**A celdas triestado reales.** El log de síntesis (`reportes/synth_dc.log`)
muestra, durante la elaboración del RTL, el mensaje explícito:

```
Inferred tri-state devices in process
| and_or_bus_tri  | Tri-State Buffer | 16 |
Inferred tri-state devices in process
| and_or_bus_tri2 | Tri-State Buffer | 16 |
```

DC reconoció cada uno de los dos `assign` condicionales sobre el bus
`tri [WIDTH-1:0] and_or_bus` ([`docs/04-flags-triestado.md`](../../docs/04-flags-triestado.md))
como un dispositivo tri-state independiente — uno para la rama AND
(`and_or_bus_tri`) y otro para la rama OR (`and_or_bus_tri2`) — en vez de
colapsarlos en un mux 2:1 equivalente.

## 2. ¿Qué celda usó y cuántas instancias aparecen?

La netlist sintetizada (`netlist/alu_plus_sync_synth.v`) confirma
**32 instancias de `TRIINVX1AS7`** (inversor tri-state, M31LLSC733GL150MS)
— exactamente 16 por rama (AND y OR), una por bit del bus de 16 bits:

```verilog
TRIINVX1AS7 \and_or_bus_tri[15]  ( .I(n1),  .E(n2),  .O(\and_or_bus[15] ) );
TRIINVX1AS7 \and_or_bus_tri2[15] ( .I(n33), .E(n34), .O(\and_or_bus[15] ) );
```

Las dos instancias de cada bit comparten el mismo nodo de salida
(`\and_or_bus[N]`) — el bus físico real — con sus señales de enable
(`.E(...)`) mutuamente excluyentes según `aluControl`, igual que en el
RTL original. `report_area -hierarchy` (dentro de `alu_plus_WIDTH16`)
confirma el área: `TRIINVX1AS7 ... Count 32 ... Total Area 309.657593`
µm² — menos del 1.2% del área del bloque (`alu_plus_WIDTH16`,
27511.14 µm²), un costo marginal.

## 3. Impacto en el camino crítico

Ninguno: el camino crítico real ([`05-discusion.md`](05-discusion.md),
pregunta 4) pasa por `u_alu/u_divider` y el árbol de muxes del resultado,
no toca `and_or_bus`. Tiene sentido — el bus triestado solo participa
cuando `aluControl` selecciona AND u OR, operaciones de 1 nivel lógico,
muy lejos de la profundidad del divisor (122 niveles).

## 4. ¿Hubo advertencias por el bus con múltiples manejadores?

No. `elaborate`/`link` no reportaron error ni advertencia de conflicto
— el log solo muestra el mensaje informativo "Inferred tri-state
devices" citado arriba. Esto confirma que describir el bus como `tri
[WIDTH-1:0]` con dos `assign` condicionales (en vez de, por ejemplo, un
`always` con un `case`) es una forma válida y sin ambigüedad de pedirle a
Design Compiler un triestado real, y que la librería M31 efectivamente
tiene la celda nativa (`TRIINVX1AS7`) para implementarlo tal cual.
