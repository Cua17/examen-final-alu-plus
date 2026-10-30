# Estado de la Parte 2 (Physical Design + Synopsys)

**Bloqueador:** Design Compiler, IC Compiler II y el PDK de GF 150nm +
librerías M31 no están instalados en esta máquina (solo Vivado, usado para
la Parte 1). El profesor dio acceso a estas herramientas por un servidor,
compartido por WhatsApp — esta carpeta queda lista para correr ahí apenas
tenga las credenciales/rutas.

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
