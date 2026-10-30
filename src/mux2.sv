`timescale 1ns / 1ps

// Mux 2:1 generico, parametrizado en ancho, implementado con el operador
// ternario (mapea directo a un mux nativo en sintesis, en vez de describir
// compuertas AND/OR/NOT a mano). Mismo espiritu que HDL Example 4.34 del
// libro (mux N:1 parametrizado), pero reducido al caso 2:1 que pide el PDF.
module mux2 #(
    parameter integer WIDTH = 8
) (
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,
    input  logic             s,
    output logic [WIDTH-1:0] y
);

    assign y = s ? d1 : d0;

endmodule
