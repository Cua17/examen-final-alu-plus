# Estructura de la ALU+ y asignación

## Qué pide el examen final (parte práctica, 70% de la nota)

El PDF de instrucciones llama a esta entrega "Parcial 3" por error del
catedrático — es en realidad el examen final del curso, y así se nombra en
todo este repositorio y en la entrega.

Cada quien tiene asignado un tipo de sumador y una extensión distintos, para
que no todos entreguen el mismo circuito:

| | Sumador | Extensión |
|---|---|---|
| Alas | CLA (Carry Look-ahead) | Multiplicador |
| Chamo | CLA (Carry Look-ahead) | Divisor |
| **Cua** | **Prefix Adder** | **Divisor** |
| Chuleta | Prefix Adder | Multiplicador |
| Pili | Prefix Adder | Divisor |

Esta entrega implementa **Prefix Adder** (Kogge-Stone) + **Divisor**. El
código de `ALUControl` para el multiplicador (`100`) está reservado en la
arquitectura pero no implementado — no me fue asignado, y hacerlo igual
sería entregar trabajo que no es mío (ver
[`docs/02-prefix-adder.md`](02-prefix-adder.md) y
[`docs/03-divisor.md`](03-divisor.md) para el detalle de lo que sí
construí).

## Jerarquía

```
src/
  mux2.sv          mux 2:1 parametrizado, operador ternario (bloque reusable)
  prefix_adder.sv  sumador Kogge-Stone, parametrizado (ADD/SUB)
  array_divider.sv divisor en arreglo, parametrizado (división entera sin signo)
  alu_plus.sv      top: instancia los tres anteriores + bus triestado AND/OR
                   + árbol de mux2 (8:1) + lógica de banderas NZCV
sim/
  testbench.sv         35 checks autoverificados, WIDTH=8 (default)
  testbench_widths.sv  10 checks dirigidos confirmando WIDTH=16 y WIDTH=32
```

Todo bajo `src/` tiene un parámetro `WIDTH` con default `8`, sin ningún
valor de ancho fijo hardcodeado dentro de la lógica — por eso la misma
jerarquía se instancia a 16 o 32 bits sin tocar un archivo (ver
[`docs/05-verificacion.md`](05-verificacion.md), sección de
`testbench_widths.sv`).

## Codificación de `ALUControl` (3 bits)

La ALU original del curso usa `ALUControl[1:0]` (AND/OR/ADD/SUB). Extenderla
implica +1 bit, tal como pide el PDF (item 5):

| `ALUControl` | Operación | Resultado |
|---|---|---|
| `000` | AND | `a & b` |
| `001` | OR | `a \| b` |
| `010` | ADD | `a + b` |
| `011` | SUB | `a - b` |
| `100` | Multiplicador | reservado (no asignado, sale `0`) |
| `101` | Divisor — operación | cociente `a / b` |
| `110` | Divisor — residuo | resto `a % b` |
| `111` | Todos los bits en 0 | `0` (código "de mucha utilidad" del PDF) |

El bit más significativo (`ALUControl[2]`) separa la ALU clásica (`0`) de
las extensiones (`1`); los dos bits bajos siguen jugando el mismo rol de
selector que ya tenían.

## El mux final (item 2 del PDF)

En vez de un `case` behavioral, el resultado final se arma con un árbol de
3 niveles de `mux2` (que sí usa el operador ternario), indexado directo por
el valor binario de `ALUControl` — nivel A agrupa por `ALUControl[0]`,
nivel B por `ALUControl[1]`, nivel C (la salida) por `ALUControl[2]`. Con
eso, "el mux debe implementarse como RTL nativo... con el operador
ternario" queda satisfecho con una pieza reusable (`mux2`) en vez de
lógica de selección escrita a mano por cada combinación.

## División por cero

`array_divider` define una convención explícita para `b == 0`: cociente y
residuo salen en todo-unos (`'1`), en vez de dejar el resultado de la resta
de prueba sin definir. Se documenta y se prueba en
[`docs/03-divisor.md`](03-divisor.md) y en los casos `E4`/`F3` del
testbench.
