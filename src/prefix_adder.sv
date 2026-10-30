`timescale 1ns / 1ps

// Prefix adder (Kogge-Stone), parametrizado en ancho (WIDTH debe ser
// potencia de 2: 8 por default, instanciable a 16/32 sin tocar esta
// arquitectura). Asignacion de sumador para este examen: "Cua, Chuleta y
// Pili: Prefix Adder" (ver docs/01-alu-estructura.md).
//
// Idea: en vez de propagar el carry bit a bit (rizado) o calcularlo todo de
// una sola vez como el CLA, Kogge-Stone combina pares de generar/propagar en
// log2(WIDTH) etapas, cada una a distancia 2^etapa, hasta tener el
// generar/propagar acumulado desde el bit 0 hasta cada bit i. De ahi sale el
// carry de entrada a cada bit en tiempo log2(WIDTH) en vez de O(WIDTH).
//
// sub=1 resta (A - B) invirtiendo B y metiendo cin=1 (complemento a 2),
// igual que el truco clasico de ALUControl0 en la ALU vista en clase.
module prefix_adder #(
    parameter integer WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             sub,
    output logic [WIDTH-1:0] sum,
    output logic             cout
);

    localparam integer STAGES = $clog2(WIDTH);

    logic [WIDTH-1:0] bb;
    logic              cin;

    // g[0]/p[0]: generar/propagar bit a bit, antes de cualquier etapa prefix
    // g[STAGES]/p[STAGES]: generar/propagar acumulado 0..i, listo para carry
    logic [WIDTH-1:0] g [0:STAGES];
    logic [WIDTH-1:0] p [0:STAGES];
    logic [WIDTH-1:0] carry;

    assign bb  = sub ? ~b : b;
    assign cin = sub;

    assign g[0] = a & bb;
    assign p[0] = a ^ bb;

    genvar s, i;
    generate
        for (s = 0; s < STAGES; s = s + 1) begin : stage
            localparam integer DIST = 1 << s;
            for (i = 0; i < WIDTH; i = i + 1) begin : bit_
                if (i >= DIST) begin : combine
                    // combina el par (g,p) de este bit con el que esta a
                    // DIST posiciones atras: "si no genero yo, pero propago,
                    // heredo el generar de mas atras"
                    assign g[s+1][i] = g[s][i] | (p[s][i] & g[s][i-DIST]);
                    assign p[s+1][i] = p[s][i] & p[s][i-DIST];
                end else begin : passthrough
                    assign g[s+1][i] = g[s][i];
                    assign p[s+1][i] = p[s][i];
                end
            end
        end
    endgenerate

    // carry de entrada al bit i = generar acumulado 0..i-1, mas el cin
    // original si todos esos bits son propagadores (no generan ni matan)
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : carry_
            assign carry[i] = g[STAGES][i] | (p[STAGES][i] & cin);
        end
    endgenerate

    assign sum[0]         = p[0][0] ^ cin;
    assign sum[WIDTH-1:1] = p[0][WIDTH-1:1] ^ carry[WIDTH-2:0];
    assign cout           = carry[WIDTH-1];

endmodule
