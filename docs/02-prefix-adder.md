# Prefix Adder (Kogge-Stone)

## Por qué esta estructura y no CLA ni rizado

Un sumador por acarreo rizado (ripple-carry) calcula el carry de cada bit
esperando el carry del bit anterior: `O(WIDTH)` de retardo. El CLA
(asignado a Alas y Chamo, no a mí) calcula el carry de cada bit en paralelo
a partir de generar/propagar de **todos** los bits anteriores en un solo
bloque de compuertas grande — rápido pero con compuertas de abanico (fan-in)
enorme para anchos grandes, lo cual complica el ruteo físico.

Un **prefix adder** (Kogge-Stone, el que me toca) combina esa misma idea de
generar/propagar pero en `log2(WIDTH)` etapas, cada una combinando pares de
bits a una distancia que se va duplicando (1, 2, 4, 8...). Con eso el
camino crítico crece como `log2(WIDTH)` en vez de `WIDTH` (como el rizado)
y las compuertas individuales son siempre de 2 entradas (a diferencia del
CLA), lo que lo hace más regular para sintetizar a celdas estándar — por
eso es la estructura preferida en ALUs rápidas de propósito general.

## Generar y propagar

Para cada bit `i`: `g[i] = a[i] & b[i]` (ese bit *genera* un carry sin
importar lo que venga de atrás), `p[i] = a[i] ^ b[i]` (ese bit *propaga* el
carry que le llegue). Combinando dos bloques de bits (uno "alto", uno
"bajo"):

```
G_combinado = G_alto | (P_alto & G_bajo)
P_combinado = P_alto & P_bajo
```

"El bloque alto genera un carry, o lo propaga Y el bloque bajo generó uno".
Kogge-Stone aplica esto en `log2(WIDTH)` etapas, cada una a distancia
`2^etapa` (1, 2, 4...), hasta que cada bit `i` tiene el generar/propagar
acumulado desde el bit `0` hasta `i`. El carry de entrada al bit `i` sale
entonces de `G_acumulado[i] | (P_acumulado[i] & cin)`.

Implementado en [`src/prefix_adder.sv`](../src/prefix_adder.sv) con un
`generate` de dos niveles (`stage` × `bit_`), parametrizado en `WIDTH`
(`STAGES = $clog2(WIDTH)` — requiere que `WIDTH` sea potencia de 2, cumplido
por 8/16/32).

## Resta y la bandera de overflow

`sub=1` invierte `b` (`bb = ~b`) y mete `cin=1` — complemento a 2 estándar,
mismo truco que `ALUControl0` en la ALU original del curso. Para no
duplicar la lógica de overflow entre ADD y SUB, `alu_plus.sv` calcula el
signo de `b` **tal como entra al sumador** (`b_sign_in_add = is_sub ? ~b[MSB]
: b[MSB]`), y una sola fórmula sirve para los dos casos:

```
v = (a[MSB] == b_sign_in_add) && (sum[MSB] != a[MSB])
```

Verificado contra casos límite reales de overflow con 8 bits en
`sim/testbench.sv` (`B3`/`B4`/`C3`): `127+1`, `-128+-128`, `-128-1`.

## Verificación

`sim/testbench.sv` cubre ADD/SUB con suma simple, carry, overflow positivo
y negativo, y resta con y sin préstamo — 35/35 PASS (ver
[`docs/05-verificacion.md`](05-verificacion.md)). `sim/testbench_widths.sv`
confirma que la misma arquitectura funciona igual a 16 y 32 bits, incluido
overflow a 32 bits (`0x80000000 + 0x80000000`).
