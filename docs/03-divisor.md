# Divisor en arreglo (array divider)

## Por qué esta estructura

La extensión asignada es "Divisor". Para mantener la ALU+ puramente
combinacional (igual que el resto: AND/OR/ADD/SUB/mux ya son combinacionales,
sin ningún reloj dentro de `alu_plus.sv`), implementé división entera sin
signo como un **divisor en arreglo**: el mismo principio estructural que un
multiplicador en arreglo (una celda por bit, en cascada), pero cada celda
hace "desplazar + restar de prueba + restaurar si el resultado se volvió
negativo" en vez de "desplazar + sumar condicional". Es la versión
desenrollada (sin reloj, todas las celdas en paralelo físicamente) del
algoritmo de división restauradora que normalmente se ve como circuito
secuencial bit a bit.

## Algoritmo, celda por celda

Para dividir `dividend` entre `divisor` (ambos de `WIDTH` bits sin signo):

1. Arranca con un residuo parcial `rem[0] = 0` (de `WIDTH+1` bits).
2. En la celda `i` (para `i = 0 .. WIDTH-1`, procesando el dividendo de bit
   más significativo a menos significativo):
   - Desplaza el residuo parcial un bit a la izquierda y mete el siguiente
     bit del dividendo: `shifted = {rem[i], dividend[WIDTH-1-i]}`.
   - Resta de prueba: `trial = shifted - divisor`.
   - Si `trial` "pide prestado" (su bit extra queda en 1, señal de que el
     residuo se hubiera vuelto negativo), **no cupo**: el bit de cociente
     de esa posición es `0` y el residuo se restaura a `shifted` (como si
     nunca se hubiera restado).
   - Si no pidió prestado, **sí cupo**: el bit de cociente es `1` y el
     residuo pasa a ser `trial`.
3. Después de las `WIDTH` celdas, `rem[WIDTH]` es el residuo final y los
   bits de cociente acumulados forman `quotient`.

Implementado en [`src/array_divider.sv`](../src/array_divider.sv) con un
único `generate for` de `WIDTH` celdas — mismo patrón de "una etapa por
bit, encadenada con un arreglo de señales intermedias" que
[`prefix_adder.sv`](../src/prefix_adder.sv) usa para sus etapas, pero acá
cada etapa procesa un bit del dividendo en vez de combinar generar/propagar.

## División por cero

Sin un caso especial, `divisor == 0` haría que la resta de prueba nunca
"quepa" (todo cociente en `0`) y el residuo final terminaría siendo el
dividendo completo — un resultado técnicamente consistente con el
algoritmo pero que oculta el error en vez de señalarlo. En cambio, el
módulo define una convención explícita: si `divisor == 0`, tanto
`quotient` como `remainder` salen en todo-unos (`'1`), un valor que no se
puede confundir con una división real entre operandos de `WIDTH` bits
razonables y que el testbench verifica explícitamente (casos `E4`/`F3`).

## Verificación

`sim/testbench.sv` cubre división exacta, con resto, dividendo menor que el
divisor (cociente `0`), dividendo grande entre `1`, y división por cero —
para cociente y residuo por separado (casos `E0`-`E4`, `F0`-`F3`) — más un
barrido (`H0`-`H7`) que ejercita todos los códigos de `ALUControl` con un
mismo par de operandos. `sim/testbench_widths.sv` repite división y resto
a 16 y 32 bits contra el resultado de `/` y `%` nativos de SystemVerilog
como modelo de referencia independiente.
