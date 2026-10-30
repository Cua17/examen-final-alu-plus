# Banderas NZCV y el bus triestado AND/OR

## Banderas

- **N (Negative)**: `result[MSB]` — válida siempre, cualquier resultado con
  el bit más significativo en 1 se interpreta como negativo si se lee como
  número con signo.
- **Z (Zero)**: `result == 0` — válida siempre.
- **C (Carry)**: solo tiene sentido para ADD/SUB; para el resto de
  operaciones se fuerza a `0`. En SUB sigue la convención ARM: `C = NOT
  préstamo` (si `a >= b` sin signo, no hubo préstamo, `C=1`) — por eso el
  código usa el `cout` crudo del sumador tanto para ADD como para SUB (ver
  [`docs/02-prefix-adder.md`](02-prefix-adder.md)), en vez de invertirlo
  para SUB.
- **V (oVerflow)**: solo ADD/SUB, mismo criterio que el prefix adder
  (detalle de la fórmula en el documento anterior).

Forzar `C`/`V` a `0` fuera de ADD/SUB evita que, por ejemplo, un `AND` dado
dos operandos cuyo resultado tiene el bit alto en 1 parezca un "overflow" —
esas banderas solo tienen significado aritmético.

## Bus triestado para AND/OR (item 6 del PDF)

La ALU original (vista en clase, ver figura del PDF) calcula `a & b` y
`a | b` **todo el tiempo**, sin importar si `ALUControl` pidió esa
operación — el mux final simplemente descarta el resultado que no usa. El
PDF pide un circuito donde **solo** la operación invocada se propague por
sus compuertas: eso es, literalmente, la razón de ser de un bus triestado —
la compuerta que no fue seleccionada no debe tener una salida válida en
absoluto (no "se calcula y se ignora", sino "no se calcula").

`alu_plus.sv` declara `and_or_bus` como `tri` (no `logic`, que no soporta
múltiples manejadores) y dos `assign` continuos, uno por operación:

```systemverilog
tri [WIDTH-1:0] and_or_bus;
assign and_or_bus = (aluControl == OP_AND) ? (a & b) : {WIDTH{1'bz}};
assign and_or_bus = (aluControl == OP_OR)  ? (a | b) : {WIDTH{1'bz}};
```

Cuando `ALUControl` no es `AND` ni `OR`, **ambos** manejadores sueltan el
bus en alta impedancia (`z`) — ninguna de las dos compuertas está
"prendida". Cuando sí es `AND` (o `OR`), ese manejador calcula el valor
real y el otro se queda en `z`; la resolución de múltiples manejadores de
una señal `tri` en Verilog/SystemVerilog hace que el bus tome el único
valor que no es `z`.

El mux final (`u_a0` en el árbol de `mux2`, ver
[`docs/01-alu-estructura.md`](01-alu-estructura.md)) recibe `and_or_bus` en
sus dos entradas a propósito: la selección entre AND y OR ya ocurrió
*dentro* del bus triestado, no en ese mux — ahí no hay un "AND puro" y un
"OR puro" calculados en paralelo para elegir entre ellos, que es
justamente lo que el PDF pide evitar.

## Qué pasa con esto en síntesis ASIC (adelanto de la Parte 2)

Los buses triestado internos no son el patrón preferido en diseño ASIC con
celdas estándar (a diferencia de un bus de periférico, por ejemplo) — la
mayoría de flujos de síntesis los convierte de vuelta a un mux equivalente,
o exige una celda de buffer triestado explícita de la librería si está
disponible. La discusión real de cómo lo resolvió Design Compiler con las
librerías de M31 (si sintetizó celdas triestado reales o lo colapsó a un
mux) queda documentada en
[`../parte2/docs/04-triestado.md`](../parte2/docs/04-triestado.md) una vez
que corra la síntesis en el servidor — es exactamente la pregunta que pide
el PDF en el item 4 de la Parte 2 ("incluyendo el tratamiento de los buses
triestado").
