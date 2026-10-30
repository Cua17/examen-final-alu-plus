# Tratamiento del bus triestado en síntesis (PENDIENTE)

> Pendiente de completar con los reportes reales de `synth_dc.tcl` — ver
> [`00-estado.md`](00-estado.md). El PDF (Parte 2, item 4) pide explicar
> "cómo se transformaron los bloques del RTL, incluyendo el tratamiento de
> los buses triestado" — esta sección responde eso puntualmente para
> `and_or_bus` ([`docs/04-flags-triestado.md`](../../docs/04-flags-triestado.md)
> en la Parte 1 explica por qué existe ese bus).

Preguntas a responder con los reportes reales de Design Compiler:

1. ¿`compile_ultra` mapeó `and_or_bus` a celdas triestado reales de la
   librería M31, o lo colapsó a un mux 2:1 equivalente? (revisar la netlist
   sintetizada, `grep -i "tri\|bufif\|notif"` sobre
   `netlist/alu_plus_sync_synth.v`, y/o el log de síntesis buscando
   warnings sobre "tristate"/"multiple drivers").
2. Si lo colapsó a mux: ¿qué mensaje/warning dio `compile_ultra` al
   resolver los dos `assign` de `and_or_bus`? ¿Cambió el área esperada vs.
   un diseño que desde el RTL ya usara un mux explícito en vez de
   triestado?
3. Si usó celdas triestado reales: ¿cuántas celdas `BUFIF`/`tristate` de la
   librería M31 aparecen en `report_area -hierarchy` asociadas a
   `and_or_bus`, y qué impacto tienen en el camino crítico
   (`report_timing`) comparado con el resto del diseño?
4. ¿Tuvo DC algún problema o advertencia por el bus con múltiples
   manejadores (`and_or_bus`) durante `elaborate`/`link`? Si sí, copiar el
   mensaje exacto acá.
