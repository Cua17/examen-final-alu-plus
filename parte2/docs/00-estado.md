# Estado de la Parte 2 (Physical Design + Synopsys)

**Corrección importante sobre la librería/PDK:** el PDF del examen dice
"PDK de GF (www.gf.com) para nodo de 150nm y las librerías standard de M31
(www.m31tech.com)", pero el material de apoyo real que el profesor compartió
en Drive (carpeta "DC y ICC2", ver abajo) usa **SkyWater sky130**
(`sky130_fd_sc_hd`, PDK open-source de Google+SkyWater) — confirmado en los
scripts `.tcl` reales del curso (`target_library
sky130_fd_sc_hd__ss_100C_1v40.db`, capas `li1`/`met1`..`met5`, no `metal5`/
`metal6`). Todos los scripts de esta carpeta (`scripts/synth_dc.tcl`,
`scripts/impl_icc2.tcl`) ya están escritos para sky130, no para GF/M31.

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

## Acceso al servidor (VPN + SSH)

- **VPN**: WireGuard, túnel `lab-bd` ya configurado e instalado en esta
  máquina (`C:\Program Files\WireGuard`), servicio `WireGuardTunnel$lab-bd`
  corriendo. Mi IP dentro del túnel: `10.252.1.24/24`. El servidor responde
  ping en `10.252.1.11`.
- **SSH**: usuario `cuax`, contraseña inicial `changeme123.` (la dio el
  profesor). **El servidor fuerza cambio de contraseña en el primer login**
  ("You are required to change your password immediately (administrator
  enforced)") — esto requiere una sesión interactiva con pty, no un solo
  comando por SSH.
- **Mensajes de WhatsApp anteriores** (antes de los datos de arriba, según
  el usuario pueden estar desactualizados): usuarios
  `chuleta cua chamo pili alas`, clave `uni2026` para todos, IP del server
  una vez conectado a WireGuard `10.252.1.11` (coincide con el `10.252.1.11`
  de arriba), y dos IPs adicionales mencionadas: `172.18.4.119` y
  `172.18.4.11` (no probadas — podrían ser direcciones internas solo
  alcanzables ya dentro del servidor, o alternativas si `10.252.1.11` no
  responde).

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
