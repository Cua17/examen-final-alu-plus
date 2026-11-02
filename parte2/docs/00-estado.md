# Estado de la Parte 2 (Physical Design + Synopsys)

**Corrección sobre la corrección:** en una iteración anterior de este
documento dije que el PDF estaba equivocado y que el PDK real era SkyWater
sky130, basándome en unos scripts `.tcl` de un proyecto anterior de otro
estudiante (`ProyectoCPU_F`) que encontré en el material de apoyo de Drive.
**Eso fue un error mío** — esos scripts eran de un curso/proyecto distinto
que efectivamente usaba sky130, pero no son el PDK de ESTE examen. El
2026-10-31 el usuario compartió el ZIP real del PDK que da el catedrático
(`GF-20261031T234429Z-1-001.zip`, ~958 MB) y es, efectivamente, el **PDK de
GlobalFoundries 150nm ("150MCU")** — el PDF tenía razón desde el
principio. Confirmado: `pdk-150MCU-V1.0_0.0_PlaceRoute_ICC2/` con techfiles
`gf150mcu_*_7t_M31_ndm.tf` (named "7t_M31" = compatible con celdas M31 de
7 tracks), mapas StarRCXT, TLUPlus, y el manual oficial
`APN-000299_3_150MCU_Digital_Design_Quick_Start_Guide.pdf` incluido en el
mismo ZIP.

**Pieza que todavía falta — librería de celdas M31:** el ZIP de GF trae el
PDK de **proceso** (reglas físicas, techfiles de ICC2, parásitos) pero
**no** la librería de celdas estándar M31 en sí (los `.lib`/`.db` de
Liberty que necesita Design Compiler para `target_library`, ni las vistas
físicas NDM/LEF de las celdas que necesita ICC2 para el floorplan real).
Esto no es un descuido del catalogo — la guía oficial de GF
(`APN-000299`, tabla "150MCU IPs") lo dice explícitamente: **"M31 IPs can
be downloaded from the vendor's website"** — es un paquete separado, de
M31 (www.m31tech.com), no de GF. Falta conseguir ese paquete (o que el
profesor/ayudante indique de dónde bajarlo) antes de poder correr
`dc_shell-t` de verdad.

**Actualización 2026-11-01 — librería M31 recibida:** el ayudante del
catedrático envió por WhatsApp el ZIP de M31 (confirmado por audio,
transcrito por el usuario — ver resumen abajo), y resultó ser
`M31LLSC733GL150MS` (7-Track SVT Low Leakage, dominio 3.3V — la variante
digital normal; existe también `M31LLSC750GL150MS` para 5V/IO, no aplica a
un bloque lógico puro). Integridad verificada (`unzip -t`, sin errores,
2.1 GB, 91 archivos). Trae Liberty (`nldm`/`nldm_db`, `ccs`/`ccs_db`) en
8 corners PVT, vistas físicas Milkyway, LEF, modelos Verilog, símbolos.

`scripts/synth_dc.tcl` y `scripts/impl_icc2.tcl` ya están **reescritos**
para GF150MCU + M31LLSC733GL150MS (corner típico 25°C/TT/3.3V):

- DC: `target_library` apunta al `.db` típico de M31 ya extraído
  localmente (`M31LLSC733GL150MS_25CTT3P3_ctyp_nldm.db`).
- ICC2: `TECH_FILE`/`MAP_FILE`/TLUPlus apuntan al techfile de GF con la
  variante de metal stack `1p5m_1tm_9k_sp_sm_OPTB` (5 metales — elegida
  por tener más capas de ruteo disponibles entre las opciones del PDK, no
  por indicación del profesor; **AJUSTAR** si él especifica otra).
- Período de reloj de partida subido a 20 ns (antes 10 ns, que era para
  sky130) porque GF150nm es un proceso mucho más lento que un nodo
  moderno — sigue siendo un placeholder, no un número medido.

**Punto sin resolver, marcado en el script:** la librería física de M31
viene en formato Milkyway clásico
(`M31LLSC733GL150MS.00.03.000.milkyway.tgz`), pero ICC2 (versión
Y-2026.03-SP2 del servidor) normalmente espera NDM. Hace falta, ya en el
servidor, confirmar el comando de conversión Milkyway→NDM (o si esta
versión de ICC2 acepta Milkyway directo vía `-milkyway_ref_libs`) antes de
poder correr `impl_icc2.tcl` de verdad — no se inventó el nombre del
comando sin confirmarlo contra la instalación real.

**Transcripción del audio del ayudante (resumen, vía el usuario):**
confirma el flujo de dos librerías (GF = dimensiones/proceso, M31 =
celdas — hay una de memoria y una de circuito, la de circuito es la que
mandó), indica crear una carpeta `m31` dentro del proyecto de la ALU en el
servidor y desempaquetar los `.tar` ahí, y aclara que el testbench para
Synopsys (VCS/Verdi) tiene que ser distinto al de Vivado — coincide con lo
que ya teníamos planeado (ver pendientes en el README).

## Subida de archivos al servidor (bloqueada por VPN)

El 2026-10-31/11-01 la VPN (`lab-bd`) dejó de responder (el túnel
WireGuard sigue "Up" en Windows pero no hay respuesta del servidor —
probablemente un problema puntual del lado de la universidad). Mientras
tanto, ya se dejó preparado localmente (en el scratchpad de la sesión)
todo lo necesario para subir en cuanto vuelva:

- `GF_PDK/icc2_techfiles/` — techfiles + TLUPlus de ICC2 del PDK de GF
  (~5 MB, ya extraídos del ZIP de 958 MB, sin el resto de paquetes que no
  hacen falta para este flujo — LVS, modelos SPICE, PEX completo,
  Virtuoso).
- `m31_733/` — de la librería M31LLSC733GL150MS: el `.lib` y `.db` típico
  (corner 25°C/TT/3.3V), `milkyway.tgz`, `milkyway_techfiles.tgz`,
  `verilog.tgz`, `lef.tgz`, `lef_techfiles.tgz`.

Destino planeado en el servidor: `/home/cuax/bootcamp_data/ExamenFinal_ALU/GF_PDK/`
y `/home/cuax/bootcamp_data/ExamenFinal_ALU/m31/` (tal como indicó el
ayudante — carpeta `m31` dentro del proyecto de la ALU).

## 2026-11-02 — Síntesis DC corrida con éxito

La VPN volvió (el catedrático la arregló), se subió todo al servidor y
`dc_shell-t -f synth_dc.tcl` corrió **completo, sin errores**, cumpliendo
timing (WNS/TNS = 0.00, 0 violaciones). Resultados completos con números
reales en [`05-discusion.md`](05-discusion.md) y
[`04-triestado.md`](04-triestado.md) (bus triestado → 32 celdas
`TRIINVX1AS7` reales, confirmado en la netlist). Reportes, log y netlist
ya bajados a `parte2/reportes/` y `parte2/netlist/` en este repo.

**Bloqueo confirmado para ICC2 (no para DC):** la librería física M31
(`M31LLSC733GL150MS.00.03.000.milkyway.tgz`) está en formato Milkyway
clásico (carpetas `CEL`/`FRAM`/`lib*`, típico de Milkyway). Se verificó
directamente dentro de `icc2_shell` (versión Y-2026.03-SP2 instalada en
el servidor) que **no existe ningún comando de conversión ni soporte
Milkyway**: `info commands *milkyway*` y `*ndm*` no devuelven nada
relevante, y tampoco hay instalación de ICC1 clásico en el servidor
(`/usr/synopsys/` solo tiene `icc2`, no `icc`). Sin una versión NDM de la
librería física M31, `impl_icc2.tcl` no puede correr.

**Siguiente paso:** preguntarle al profesor/ayudante si existe una
versión NDM de `M31LLSC733GL150MS` (o un paso de conversión que no
encontramos en esta instalación) — no es algo que se pueda resolver
localmente inventando un comando.

## Verificación con VCS — HECHO

`vcs -full64 -sverilog` compiló `testbench_sync.sv` sin errores y corrió
limpio en el servidor: **5/5 PASS** (mismo resultado que `xsim` en
Vivado) — log completo en `parte2/reportes/vcs_sync.log`. Queda
pendiente abrir el diseño en **Verdi** (visor de formas de onda) durante
la grabación del video — eso es parte de la presentación, no algo que
haga falta pre-generar.

**Bloqueador:** Design Compiler, IC Compiler II y el PDK sky130 no están
instalados en esta máquina (solo Vivado, usado para la Parte 1). El acceso
es por un servidor universitario vía WireGuard — ver más abajo.

## Material de apoyo del profesor (Google Drive)

Carpeta compartida: "DC y ICC2" (https://drive.google.com/drive/folders/1Dr6vblhtOHCeJNhAJ7BjxF5LPLELNGjz).
Contenido revisado:

- `DC_ICC2_presentacion.pdf` — presentación conceptual del flujo RTL → DC →
  ICC2 → signoff (qué hace cada herramienta, reportes clave, estrategias
  Baseline/PPA1/PPA2). Usada para entender el flujo, no da rutas de PDK.
- `TCL_DC_ICC2_originales_y_comentados.zip` — scripts reales de un proyecto
  anterior del curso ("ProyectoCPU_F", sky130_fd_sc_hd). De ahí salieron
  los comandos y la estructura real que usan `scripts/synth_dc.tcl` y
  `scripts/impl_icc2.tcl` en esta carpeta (setup de librerías,
  `compile_ultra -scan -no_autoungroup`, floorplan con tracks/PG mesh/tap
  cells, flujo `place_opt → clock_opt → route_auto → route_opt` con
  reportes por etapa).
- Dos `.mov` (`DC_presentacion.mov`, `ICC2_presentacion.mov`) — grabaciones
  de la presentación, no revisadas a fondo (son video, no texto) — revisar
  si hace falta más detalle antes de correr en el servidor.

**Importante:** `DESIGN_REF_PATH` en los scripts originales apunta a
`/home/synuser19/bootcamp_data/ProyectoCPU_F` — ese es el `$HOME` de OTRO
estudiante (`synuser19`), de un proyecto anterior. En
`scripts/synth_dc.tcl`/`scripts/impl_icc2.tcl` de esta carpeta se puso
`/home/cuax/bootcamp_data/ExamenFinal_ALU` como punto de partida (marcado
`# AJUSTAR`) — **falta confirmar en el servidor** cuál es el `$HOME` real
de `cuax` y si `bootcamp_data/` existe ahí o es una ruta compartida
distinta.

## Acceso al servidor (VPN + SSH) — RESUELTO

- **VPN**: WireGuard, túnel `lab-bd` ya configurado e instalado en esta
  máquina (`C:\Program Files\WireGuard`), servicio `WireGuardTunnel$lab-bd`
  corriendo. Mi IP dentro del túnel: `10.252.1.24/24`. El servidor responde
  ping en `10.252.1.11`.
- **SSH**: usuario `cuax`. El cambio de contraseña obligatorio del primer
  login (`changeme123.` → nueva) ya se completó a mano (2026-10-29). Acceso
  por SSH confirmado y funcionando.
- Herramientas confirmadas en el PATH del servidor (vía
  `/usr/local/share/synopsys.conf`, cargado desde `.bashrc`):
  `dc_shell` / `dc_shell-t` en `/usr/synopsys/syn/X-2025.06-SP5-5/bin/`,
  `icc2_shell` en `/usr/synopsys/icc2/Y-2026.03-SP2/bin/`. Licencia vía
  `SNPSLMD_LICENSE_FILE=27020@synopsys-unis`.

## Nuevo bloqueador: falta el PDK sky130 en el `$HOME` de `cuax`

`$HOME` real de `cuax` es `/home/cuax` — **no existe `bootcamp_data/` ahí**.
Búsqueda exhaustiva en todo el filesystem del servidor (`/`, `/home`,
`/var`, `/boot` — los únicos montados) por `sky130`, `.ndm`, PDK, etc.: cero
resultados fuera de las librerías genéricas de Synopsys (`gtech`,
`dw_foundation`, `standard` — no son el PDK de la fundición). El PDK sky130
real que usaba el proyecto anterior (`ProyectoCPU_F`) vivía en
`/home/synuser19/bootcamp_data/...`, pero los `/home/*` de otros
estudiantes están en `700` (sin acceso), y `cuax` no pertenece a ningún
grupo compartido (`id` → solo `cuax(1020)`). No hay ningún punto de montaje
compartido (NFS/autofs) ni carpeta de datos pública en el servidor.

Conclusión: el PDK no es compartido a nivel de sistema — cada estudiante
parece tener (o haber recibido) su propia copia dentro de su `$HOME`, y a
`cuax` todavía no le ha llegado. Esto **no se puede resolver solo
investigando el servidor**; hace falta que el profesor indique cómo
obtenerlo (paquete/tarball, script de instalación, u otra carpeta de Drive
no revisada todavía). El servidor sí tiene salida a internet (confirmado
`curl`/`ping` a servicios externos), así que si el profesor da un enlace de
descarga directo, se puede traer sin problema.

## Qué está listo para correr tal cual

- [`rtl/alu_plus_sync.sv`](../rtl/alu_plus_sync.sv) — envoltorio síncrono
  (`WIDTH=16`, registros de entrada y salida) sobre la `alu_plus` de la
  Parte 1, verificado funcionalmente con `xsim`
  ([`docs/05-verificacion.md`](../../docs/05-verificacion.md), 5/5 PASS).
- [`scripts/constraints.sdc`](../scripts/constraints.sdc) — restricciones
  de timing, con el período de reloj marcado explícitamente como punto de
  partida a ajustar con el `report_timing` real (no quiero reportar un
  número de timing que no salió de una herramienta real).
- [`scripts/synth_dc.tcl`](../scripts/synth_dc.tcl) — flujo completo de
  síntesis (`analyze` → `elaborate` → `compile_ultra` → los 5 reportes que
  pide el PDF: `report_qor`, `report_timing`, `report_area`,
  `report_power`, `report_constraint -all_violators`), más exportar
  netlist/SDC/DDC para IC Compiler II.
- [`scripts/impl_icc2.tcl`](../scripts/impl_icc2.tcl) — flujo completo de
  diseño físico (`place_opt` → `clock_opt` → `route_auto` → `route_opt`,
  con reporte de QoR/timing después de cada etapa, verificaciones de
  legalidad/routing/alimentación, y exportación de GDSII).

## Qué falta para poder correrlos

1. **Acceso al servidor**: host/puerto, usuario/contraseña (o llave SSH), y
   si hace falta VPN antes de conectar.
2. **Rutas reales del PDK/librerías en el servidor** — ahora mismo
   `synth_dc.tcl`/`impl_icc2.tcl` tienen placeholders marcados `# AJUSTAR`
   en `RUTA_LIBS`, `target_library`, `symbol_library` y las rutas de
   `create_lib` — hay que reemplazarlos con los nombres reales que dio el
   profesor (o el script de `setup`/`source` que normalmente se corre antes
   de `dc_shell`/`icc2`, si existe uno).

## Qué hacer con esto una vez haya acceso

1. Copiar `src/`, `parte2/rtl/` y `parte2/scripts/` al servidor (o montar
   el repo ahí).
2. Completar los placeholders de librerías en `synth_dc.tcl`/`impl_icc2.tcl`.
3. Correr `dc_shell-t -f scripts/synth_dc.tcl`, revisar
   `reportes/report_timing.txt` — si el período de 20ns (50MHz) de
   `constraints.sdc` da mucho margen o no cumple, ajustarlo y volver a
   correr antes de pasar a ICC2.
4. Correr `icc2_shell -f scripts/impl_icc2.tcl`.
5. Completar las respuestas de la Discusión (item 7 del PDF) en
   [`05-discusion.md`](05-discusion.md) con los números reales de los
   reportes — no antes, para no inventar resultados.
6. Completar [`04-triestado.md`](04-triestado.md): cómo mapeó Design
   Compiler el bus triestado de `and_or_bus` (celda triestado real de la
   librería M31, o colapsado a mux equivalente).
