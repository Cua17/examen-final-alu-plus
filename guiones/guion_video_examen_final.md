# Guion — Examen Final (ALU+ : Prefix Adder + Divisor, Parte 1 y Parte 2)

José Daniel Cuá Fagiani — Carné 21200. El PDF no pone límite de tiempo
al video (sí pide una presentación oral aparte de 15 min, que es otra
cosa). Con todo el contenido real de abajo, esto ronda los 15-18
minutos — no hay que apurarse ni cortar nada para que entre en 10.

Mostrar cámara mientras se habla. Cada paso dice **qué pestaña/ventana
abrir** y **qué decir mientras está en pantalla**, en orden. Cuando
termines el texto de una pestaña, recién ahí cambiás a la siguiente.

## Qué tener abierto ANTES de grabar, y qué es cada cosa

1. **El landing del repositorio**
   (`https://cua17.github.io/examen-final-alu-plus/`) — una página con
   los resultados principales y, más abajo, el render real del layout
   GDSII (la imagen del chip ya colocado y ruteado). La usás en la
   apertura y de nuevo cuando mostrés el resultado físico final.

2. **VS Code**, con la carpeta `ExamenFinal` abierta y estas pestañas
   ya abiertas de antemano (no hace falta abrir nada más durante la
   grabación, solo cambiar de pestaña):
   - `docs/01-alu-estructura.md`, `docs/02-prefix-adder.md`,
     `docs/03-divisor.md`, `docs/04-flags-triestado.md` (la
     documentación de la Parte 1, en español, con la explicación de
     diseño)
   - `src/mux2.sv`, `src/prefix_adder.sv`, `src/array_divider.sv`,
     `src/alu_plus.sv` (el código de la Parte 1)
   - `parte2/rtl/alu_plus_sync.sv` (el envoltorio síncrono de la
     Parte 2)
   - `parte2/docs/00-estado.md`, `parte2/docs/04-triestado.md`,
     `parte2/docs/05-discusion.md` (la documentación de la Parte 2,
     con los bloqueos reales que se resolvieron y los reportes)
   - `parte2/reportes/report_qor.txt` (o `report_timing.txt`) —
     reporte **real** que escupió Design Compiler en el servidor, no
     un texto inventado

3. **Ventana de Vivado #1** — simulación de `alu_plus` (la ALU+
   combinacional de la Parte 1, `sim/testbench.sv`), **ya corrida**,
   con las ondas de `sim/wave.tcl` cargadas y el zoom ajustado a toda
   la simulación ("Zoom Fit"). Muestra las 35 operaciones que verifica
   el testbench: `a`, `b`, el código de operación `aluControl`, el
   `result`, y las 4 banderas `n`/`z`/`c`/`v`.

4. **Ventana de Vivado #2** — simulación de `alu_plus_sync` (el
   envoltorio síncrono de la Parte 2, `parte2/sim/testbench_sync.sv`),
   **ya corrida**, con las ondas de `parte2/sim/wave.tcl` cargadas y
   el zoom ajustado. Muestra el reloj, el reset, las entradas y
   salidas registradas, con la latencia de 2 ciclos entre que entra un
   dato y sale el resultado.

Para dejar las dos ventanas de Vivado listas de antemano (no correr
nada de esto en cámara):

```powershell
$env:PATH = "C:\AMDDesignTools\2026.1\Vivado\bin;" + $env:PATH

# Ventana 1 (Parte 1)
xvlog --sv src/mux2.sv src/prefix_adder.sv src/array_divider.sv src/alu_plus.sv sim/testbench.sv
xelab testbench -s testbench_sim -debug all
xsim testbench_sim -gui
# en la consola Tcl de esa ventana: source sim/wave.tcl

# Ventana 2 (Parte 2) -- abrir una terminal nueva para no pisar la anterior
$env:PATH = "C:\AMDDesignTools\2026.1\Vivado\bin;" + $env:PATH
xvlog --sv src/mux2.sv src/prefix_adder.sv src/array_divider.sv src/alu_plus.sv parte2/rtl/alu_plus_sync.sv parte2/sim/testbench_sync.sv
xelab testbench_sync -s testbench_sync_sim -debug all
xsim testbench_sync_sim -gui
# en la consola Tcl de esa ventana: source parte2/sim/wave.tcl
```

Las dos corridas ya quedaron probadas: la ventana 1 da
`RESULTADO: 35 PASS, 0 FAIL`, la ventana 2 da
`RESULTADO (sync): 5 PASS, 0 FAIL`, ambas en la consola Tcl.

---

## 0. Apertura (1 min)

**Abrir:** el landing del repositorio.

**Decir:**
"Hola profe, soy José Daniel Cuá, carné 21200. Este es el examen
final de la clase — el PDF lo llama 'Parcial 3' pero usted mismo
aclaró que en realidad es el examen final, así que así lo voy a
nombrar en todo lo que muestre. Me tocó Prefix Adder y Divisor. Todo
lo que voy a mostrar corrió de verdad, no son capturas de otro lado:
tengo el repositorio en GitHub con el código, los reportes reales y
la documentación, se los voy mostrando a medida que avanzo."

---

# PARTE 1 — HDL + ALU+

## 1. Estructura, asignación y el mux ternario (2.5 min)

**Abrir:** `docs/01-alu-estructura.md`.

**Decir:**
"Según la tabla de asignación del PDF, me tocó Prefix Adder — no
Carry Look-ahead — y Divisor, no Multiplicador. El `ALUControl`
original de la clase usaba 2 bits para AND, OR, ADD, SUB; para agregar
división le sumé un tercer bit: cuando ese bit está en cero sigue
siendo la ALU clásica, y cuando está en uno entra a las extensiones —
`101` para el cociente de la división, `110` para el residuo. El
código `100`, reservado para multiplicador, lo dejo sin implementar a
propósito: no fue parte de mi asignación, implementarlo igual sería
entregar trabajo que no es mío."

**Abrir:** `src/mux2.sv`.

**Decir:**
"El PDF pide que el mux se implemente nativo con el operador ternario,
no con un `case` ni un `if`, porque mapea mejor a hardware real. Acá
está completo: una sola línea, `y = s ? d1 : d0`."

**Abrir:** `src/alu_plus.sv`.

**Decir:**
"Y acá está la ALU+ completa: instancia el sumador y el divisor que
voy a mostrar en un momento, arma el resultado final con un árbol de
siete de estos mux en tres niveles — indexado directo por el valor
binario de `aluControl` — y calcula las banderas. Todo parametrizado
en `WIDTH`, por defecto 8 bits, pero se puede instanciar a 16 o 32 sin
tocar la arquitectura — eso lo voy a demostrar más adelante con la
simulación."

## 2. Prefix Adder — Kogge-Stone (3 min)

**Abrir:** `docs/02-prefix-adder.md`.

**Decir:**
"Un sumador de acarreo rizado calcula el carry de cada bit esperando
el del bit anterior, así que el retardo crece con el ancho completo.
Un Carry Look-ahead, que le tocó a otros compañeros, lo calcula todo
en paralelo pero con compuertas gigantes de muchísimas entradas,
complicadas de rutear en un chip real. El Prefix Adder que me tocó a
mí combina las dos ideas: para cada bit calculo si genera un carry
propio, o si propaga el que le llega, y después combino esos pares a
una distancia que se va duplicando — 1, 2, 4, 8 — en `log2` del ancho
de etapas en vez de todo el ancho. Con 8 bits son 3 etapas, no 8; y
con compuertas siempre de 2 entradas, no una gigante."

**Abrir:** `src/prefix_adder.sv`.

**Decir:**
"Acá está armado con un `generate` de dos niveles, uno por etapa y uno
por bit dentro de cada etapa, y el número de etapas sale solo de
`$clog2(WIDTH)` — por eso la misma descripción sirve para 8, 16 o 32
bits sin cambiar una línea. Para la resta, invierto `b` y meto un
acarreo de entrada en uno, el truco normal de complemento a dos; y
para no duplicar la lógica de overflow entre suma y resta, calculo el
signo de `b` tal como realmente entra al sumador, y uso una sola
fórmula para los dos casos."

## 3. Divisor en arreglo (3 min)

**Abrir:** `docs/03-divisor.md`.

**Decir:**
"La extensión que me tocó fue división. Para mantener toda la ALU
combinacional, sin ningún reloj adentro, lo armé como un divisor en
arreglo: una celda por bit, todas en paralelo físicamente, en vez de
un circuito secuencial que itera bit a bit con un reloj. Cada celda
hace lo mismo que el algoritmo de división restauradora que se ve en
clase, pero desenrollado: desplaza el residuo parcial, mete el
siguiente bit del dividendo, resta de prueba contra el divisor, y si
esa resta se hubiera vuelto negativa, no cupo — el bit de cociente
queda en cero y se restaura el residuo como si nunca se hubiera
restado. Si sí cupo, el bit de cociente es uno y el residuo se queda
con el resultado de la resta. Y para división entre cero definí una
convención explícita: cociente y residuo salen en todo-unos, en vez de
dejar un resultado indefinido que esconda el error."

**Abrir:** `src/array_divider.sv`.

**Decir:**
"Acá está, con un único `generate for` de `WIDTH` celdas encadenadas —
el mismo patrón de 'una etapa por bit' que usé en el sumador, pero acá
cada etapa procesa un bit del dividendo en vez de combinar generar y
propagar."

## 4. Banderas NZCV y el bus triestado AND/OR (2.5 min)

**Abrir:** `docs/04-flags-triestado.md`.

**Decir:**
"Las banderas: Negative y Zero son válidas siempre, se leen directo
del resultado. Carry y Overflow solo tienen sentido para suma y resta
— en cualquier otra operación se fuerzan a cero, para que un AND con
el bit alto en uno no parezca falsamente un overflow.

"Y el punto que pide específicamente el PDF: la ALU original que se ve
en clase calcula el AND y el OR todo el tiempo, sin importar qué
operación se pidió, y el mux final simplemente descarta la que no usa.
A mí me pidieron que solo la operación invocada se propague de verdad
por sus compuertas — eso es literalmente lo que hace un bus triestado.
No es que la compuerta que no se usó 'se calcule y se ignore', es que
directamente no se calcula."

**Abrir:** `src/alu_plus.sv` (de nuevo, señalando la declaración `tri` y
los dos `assign` del bus).

**Decir:**
"Acá está: declaro `and_or_bus` como `tri`, no como un `logic`
normal que no soporta varios manejadores, y tengo dos `assign`
continuos — uno por operación. Cuando `aluControl` no pide ni AND ni
OR, los dos sueltan el bus en alta impedancia; cuando sí pide una de
las dos, esa calcula el valor real y la otra se queda en z. Esto no se
queda solo en simulación — más adelante, en la Parte 2, les muestro
que Design Compiler de verdad sintetizó esto como celdas triestado
reales de la librería, no lo colapsó a un mux."

## 5. Verificación Parte 1 — demostración en vivo (2 min)

**Abrir:** la Ventana de Vivado #1 (ya abierta de antemano).

**Decir:**
"Esto ya lo tengo corrido de antes: es la simulación real de
`alu_plus` con Vivado, 35 casos de prueba, cada uno comparado contra
un modelo de referencia calculado con los operadores nativos de
SystemVerilog — no contra mi propio Kogge-Stone ni mi propio divisor,
porque si reimplementara la misma lógica ahí, un error se repetiría
en los dos lados y el testbench nunca lo detectaría. Acá se ven las
señales: `a`, `b`, el código de operación, el `result`, y las cuatro
banderas, cambiando con cada caso — sumas, restas con acarreo y sin
él, overflow positivo y negativo, las ocho operaciones de
`aluControl` con el mismo par de operandos, y los casos de división
entre cero. Abajo en la consola dice `RESULTADO: 35 PASS, 0 FAIL`.

"Y esto mismo lo verifiqué también instanciando la arquitectura a 16 y
32 bits, sin tocar un solo archivo de `src/` — 10 de 10 casos más,
incluido un overflow real a 32 bits. Eso confirma que la
parametrización en `WIDTH` no es solo un parámetro que está ahí sin
usarse."

---

# PARTE 2 — Síntesis y diseño físico (Design Compiler / IC Compiler II)

## 6. El envoltorio síncrono (2 min)

**Abrir:** `parte2/rtl/alu_plus_sync.sv`.

**Decir:**
"Para sintetizar hace falta un sistema síncrono real, no lógica
puramente combinacional suelta. Armé un envoltorio: un registro de
entrada que captura `a`, `b` y `aluControl` en el flanco de reloj, la
ALU+ combinacional de la Parte 1 adentro sin tocarla, y un registro de
salida que captura el resultado y las banderas — latencia de 2 ciclos
entre que entra un dato y sale el resultado. El reset es síncrono,
porque es más fácil de cerrar timing en un ASIC que uno asíncrono."

**Abrir:** la Ventana de Vivado #2 (ya abierta de antemano).

**Decir:**
"Y acá, corrido de antes también: la simulación de ese envoltorio con
Vivado, a 16 bits. Se ve el reloj, el reset, las entradas registradas
y las salidas registradas, con ese corrimiento de 2 ciclos que
mencioné. Abajo dice `RESULTADO (sync): 5 PASS, 0 FAIL`. Esto no
reemplaza la verificación que pide el PDF con VCS — esa la corrí
después, de verdad, en el servidor del curso, con el mismo resultado:
5 de 5. Ahí no tenía Vivado disponible, así que primero confirmé la
lógica acá antes de gastar tiempo de servidor."

## 7. Síntesis con Design Compiler (2.5 min)

**Abrir:** `parte2/docs/00-estado.md`.

**Decir:**
"Esta parte corrió contra el PDK real que da la universidad: 150
nanómetros de GlobalFoundries, con la librería de celdas M31. No fue
trivial llegar hasta acá — la librería física venía en un formato que
IC Compiler II no reconocía directamente, y tuve que investigar en el
manual real del comando en vez de asumir que no se podía, hasta
encontrar la forma correcta de dárselo. Eso lo cuento con más detalle
en la Parte 2, item de IC Compiler. Por ahora, síntesis."

**Abrir:** `parte2/reportes/report_qor.txt` (o `report_timing.txt`).

**Decir:**
"Este es el reporte real que escupió Design Compiler corriendo en el
servidor, no un número que yo escribí. El diseño final: 1796 celdas,
18477.85 micrómetros cuadrados de área, reloj de 40 nanosegundos — 25
megahertz — con 4.43 nanosegundos de margen positivo, cero caminos
violados. El divisor es, por lejos, el bloque más caro: casi el 67%
de toda el área del diseño, porque son 16 etapas de resta encadenadas,
cada una esperando a la anterior — ese es justo el camino crítico:
empieza en el registro de entrada de `b`, atraviesa todo el divisor y
el árbol de mux, y termina en el registro de la bandera Zero."

## 8. El bus triestado, sintetizado de verdad (1.5 min)

**Abrir:** `parte2/docs/04-triestado.md`.

**Decir:**
"Esto responde justo lo que pide el PDF sobre qué pasó con el bus
triestado al sintetizar. El log real de Design Compiler dice
explícitamente 'Inferred tri-state devices' — no lo colapsó a un mux
equivalente, lo mapeó a celdas triestado reales de la librería:
32 instancias de `TRIINVX1AS7`, 16 por cada rama, AND y OR, una por
bit del bus de 16 bits. Y no afecta el camino crítico para nada,
porque ese bus solo participa cuando la operación es AND u OR —
operaciones de un solo nivel lógico, muy lejos de los 16 niveles del
divisor."

## 9. IC Compiler II: del floorplan al GDSII (3 min)

**Abrir:** `parte2/docs/00-estado.md` (desplazarse a la sección del
flujo de IC Compiler II completo).

**Decir:**
"Con la síntesis lista, el siguiente paso fue el diseño físico
completo: floorplan, colocación, árbol de reloj, ruteo, y exportar el
GDSII — el archivo que de verdad se manda a fabricar un chip. En el
camino aparecieron bloqueos reales, no de libro de texto. El primero:
la librería física de M31 venía en un formato viejo que esta versión
de IC Compiler II no sabía convertir directamente; la solución no fue
inventar un comando, fue leer el manual completo de la herramienta
hasta encontrar que se le podía dar directamente el archivo LEF de las
celdas, y ella arma la librería que necesita sola. El segundo: con la
densidad de celdas que probé primero, el floorplan no legalizaba por
las celdas de conexión a alimentación que hay que intercalar cada
cierta distancia; bajando la densidad y espaciando más esas celdas,
legalizó sin problema. Y en el camino aparecieron varias diferencias
reales entre esta librería y los nombres genéricos que traía el script
de ejemplo: las capas de metal se llaman distinto, el nombre de la
celda de conexión es distinto, y los pines de alimentación de las
celdas no se llaman igual que la red lógica del diseño — hubo que
corregir cada una contra la librería real, no contra lo que asumía el
script."

## 10. Discusión y resultado final (2 min)

**Abrir:** `parte2/docs/05-discusion.md`.

**Decir:**
"Algo que no sabía de antemano y confirmé probando en la práctica:
relajar el período de reloj sí ayuda, pero no de forma proporcional.
Probé 20, 24, 25 y 30 nanosegundos, corriendo síntesis y diseño físico
completos cada vez, y el margen se quedó pegado a casi cero en los
cuatro — porque estas herramientas optimizan para cumplir justo la
restricción, no para dejar margen de sobra: cualquier espacio extra lo
gastan achicando celdas para ahorrar área. Recién a 40 nanosegundos el
optimizador se quedó sin más celdas para achicar, y ahí sí el margen
positivo se mantuvo: 4.43 nanosegundos en Design Compiler, 0.81
nanosegundos después del ruteo real en IC Compiler II. Cero
violaciones de setup, cero de hold, verificaciones de legalidad y de
conexión de alimentación limpias."

**Abrir:** el landing del repositorio (de nuevo, la imagen del layout).

**Decir:**
"Y este es el resultado físico real: el layout que exportó IC
Compiler II, renderizado directo del GDSII — las rutas, las vías y la
malla de alimentación que se ven acá salieron de la herramienta, no
son un dibujo mío."

## 11. Cierre (1 min)

**Decir:**
"Eso es todo el flujo: de la arquitectura en SystemVerilog, pasando
por la verificación con Vivado, hasta un GDSII real sobre el PDK de la
universidad, con todos los bloqueos que aparecieron en el camino
resueltos de verdad y no inventados. Todo el código, los reportes
reales y la documentación completa están en el repositorio. Gracias."
