# Guion — Examen Final, Parte 1 (ALU+ en SystemVerilog)

Puntos a cubrir en el video/presentación oral de 15 min. Mostrar cámara al
exponer (pide el PDF). Grabar con OBS, pantalla + cámara.

## 1. Encuadre (1 min)

- Esto es el examen final (el PDF lo llama "Parcial 3" por error del
  catedrático), parte práctica, 70% de la nota.
- Mi asignación: **Prefix Adder** (no CLA) + **Divisor** (no Multiplicador)
  — mostrar la tabla de [`docs/01-alu-estructura.md`](../docs/01-alu-estructura.md).

## 2. Arquitectura general (2-3 min)

- Mostrar `src/alu_plus.sv` completo en pantalla.
- `ALUControl` pasó de 2 a 3 bits: bit alto separa ALU clásica (AND/OR/ADD/SUB)
  de las extensiones (Mult reservado / Div / Zero) — tabla de códigos.
- Mencionar que el multiplicador (`100`) no está implementado a propósito:
  no fue parte de mi asignación.

## 3. Prefix Adder — Kogge-Stone (3-4 min)

- Abrir `src/prefix_adder.sv`.
- Explicar generar/propagar bit a bit, y cómo las etapas van combinando
  pares a distancia 1, 2, 4... hasta tener el acumulado 0..i.
- Por qué esto da `log2(WIDTH)` de profundidad en vez de `WIDTH` (rizado) o
  un bloque gigante de una sola etapa (CLA).
- Mostrar el `generate` de dos niveles y señalar que `STAGES = $clog2(WIDTH)`
  es lo que hace que la misma arquitectura sirva para 8/16/32 bits.

## 4. Divisor en arreglo (3-4 min)

- Abrir `src/array_divider.sv`.
- Explicar el algoritmo de división restauradora: desplazar, restar de
  prueba, restaurar si no cupo.
- Señalar el caso de división por cero y por qué se definió una convención
  explícita (todo-unos) en vez de dejarlo indefinido.
- Mencionar el paralelo estructural con un multiplicador en arreglo (una
  celda por bit, en cascada) aunque el multiplicador no es parte de esta
  entrega.

## 5. Mux final y bus triestado (2-3 min)

- Mostrar el árbol de `mux2` en `alu_plus.sv` y por qué se construyó así
  (item 2 del PDF: mux nativo con ternario) en vez de un `case`.
- Mostrar `and_or_bus` (`tri`, dos `assign` con alta impedancia) y explicar
  por qué esto responde al item 6 del PDF: AND/OR solo se calculan cuando
  de verdad fueron invocados.
- Aclarar por qué `u_a0` recibe `and_or_bus` en sus dos entradas (no es un
  error, la selección ya pasó en el bus).

## 6. Banderas NZCV (1-2 min)

- Mostrar la fórmula de overflow unificada para ADD/SUB
  (`b_sign_in_add`) y por qué C/V se fuerzan a 0 fuera de esas dos
  operaciones.

## 7. Verificación (1-2 min)

- Correr en vivo (o mostrar grabado) `xvlog`/`xelab`/`xsim` de
  `sim/testbench.sv` → 35/35 PASS.
- Mostrar `sim/testbench_widths.sv` → 10/10 PASS a 16 y 32 bits, como
  prueba de que "instanciar fácilmente la ALU de 16 o 32 bits sin cambiar
  la arquitectura" (texto del PDF) realmente se cumple.

## 8. Cierre / transición a Parte 2 (1 min)

- Estado de la Parte 2: scripts y SDC listos en `parte2/`, pendiente de
  acceso al servidor de Synopsys del curso — mostrar brevemente
  `parte2/docs/00-estado.md`.
