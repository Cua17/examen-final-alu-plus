`timescale 1ns / 1ps

// ALU+ = ALU clasica (AND/OR/ADD/SUB) vista en clase, extendida con
// division (asignacion de este examen) y un codigo reservado para
// multiplicacion (asignado a otros companeros, no implementado aqui).
//
// ALUControl paso de 2 a 3 bits al extender la ALU (item 5 del PDF):
//   000 AND   001 OR   010 ADD   011 SUB      <- ALU original (bit2=0)
//   100 MUL (reservado, no asignado a Cua)    <- extension (bit2=1)
//   101 DIV (cociente)   110 DIV (residuo)
//   111 Todos los bits en 0
module alu_plus #(
    parameter integer WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [2:0]       aluControl,
    output logic [WIDTH-1:0] result,
    output logic             n,  // Negative
    output logic             z,  // Zero
    output logic             c,  // Carry (solo valido en ADD/SUB)
    output logic             v   // oVerflow (solo valido en ADD/SUB)
);

    localparam logic [2:0] OP_AND  = 3'b000;
    localparam logic [2:0] OP_OR   = 3'b001;
    localparam logic [2:0] OP_ADD  = 3'b010;
    localparam logic [2:0] OP_SUB  = 3'b011;
    localparam logic [2:0] OP_MUL  = 3'b100;
    localparam logic [2:0] OP_DIV  = 3'b101;
    localparam logic [2:0] OP_REM  = 3'b110;
    localparam logic [2:0] OP_ZERO = 3'b111;

    logic             is_sub;
    logic             is_addsub;
    logic [WIDTH-1:0] sum;
    logic             cout;
    logic [WIDTH-1:0] quotient, remainder;
    logic             b_sign_in_add;

    // bus triestado: SOLO AND u OR manejan esta señal, y solo cuando su
    // operacion fue invocada (item 6 del PDF). El resto del tiempo cada
    // assign suelta el bus en alta impedancia, asi que AND/OR no se calculan
    // "de fondo" cuando la ALU esta haciendo otra cosa -- a diferencia de la
    // ALU original, donde ambas salidas se calculaban siempre y solo el mux
    // final elegia cual pasar. Discusion de como sintetiza esto en
    // ../parte2/docs/04-triestado.md.
    tri [WIDTH-1:0] and_or_bus;
    assign and_or_bus = (aluControl == OP_AND) ? (a & b) : {WIDTH{1'bz}};
    assign and_or_bus = (aluControl == OP_OR)  ? (a | b) : {WIDTH{1'bz}};

    assign is_sub    = (aluControl == OP_SUB);
    assign is_addsub = (aluControl == OP_ADD) || (aluControl == OP_SUB);

    prefix_adder #(.WIDTH(WIDTH)) u_adder (
        .a    (a),
        .b    (b),
        .sub  (is_sub),
        .sum  (sum),
        .cout (cout)
    );

    array_divider #(.WIDTH(WIDTH)) u_divider (
        .dividend  (a),
        .divisor   (b),
        .quotient  (quotient),
        .remainder (remainder)
    );

    // mux final de 8:1, armado como arbol de 3 niveles de mux2 (item 2 del
    // PDF: "el mux debe implementarse como RTL nativo... con el operador
    // ternario"), indexado directo por el valor binario de aluControl.
    // Nivel A agrupa por pares (bit0), Nivel B por aluControl[1], Nivel C
    // (el resultado final) por aluControl[2].
    logic [WIDTH-1:0] lvlA0, lvlA1, lvlA2, lvlA3;
    logic [WIDTH-1:0] lvlB0, lvlB1;

    // u_a0 recibe and_or_bus en sus dos entradas a proposito: el trabajo de
    // elegir entre AND y OR ya lo hizo el bus triestado de arriba (ahi es
    // donde de verdad se prende una compuerta u otra), asi que para este
    // mux cualquiera de las dos ramas selecciona el mismo valor ya
    // resuelto -- no es un error, es que no hay un segundo "AND puro" y
    // "OR puro" calculados en paralelo para elegir entre ellos.
    mux2 #(.WIDTH(WIDTH)) u_a0 (.d0(and_or_bus), .d1(and_or_bus), .s(aluControl[0]), .y(lvlA0)); // AND/OR
    mux2 #(.WIDTH(WIDTH)) u_a1 (.d0(sum),        .d1(sum),        .s(aluControl[0]), .y(lvlA1)); // ADD/SUB
    mux2 #(.WIDTH(WIDTH)) u_a2 (.d0('0),         .d1(quotient),   .s(aluControl[0]), .y(lvlA2)); // MUL/DIV
    mux2 #(.WIDTH(WIDTH)) u_a3 (.d0(remainder),  .d1('0),         .s(aluControl[0]), .y(lvlA3)); // REM/ZERO

    mux2 #(.WIDTH(WIDTH)) u_b0 (.d0(lvlA0), .d1(lvlA1), .s(aluControl[1]), .y(lvlB0));
    mux2 #(.WIDTH(WIDTH)) u_b1 (.d0(lvlA2), .d1(lvlA3), .s(aluControl[1]), .y(lvlB1));

    mux2 #(.WIDTH(WIDTH)) u_c0 (.d0(lvlB0), .d1(lvlB1), .s(aluControl[2]), .y(result));

    // b_sign_in_add = signo de B tal como entra realmente al sumador
    // (invertido si es resta) -- con esto, una sola formula de overflow
    // sirve para ADD y SUB (ver docs/03-flags.md)
    assign b_sign_in_add = is_sub ? ~b[WIDTH-1] : b[WIDTH-1];

    assign n = result[WIDTH-1];
    assign z = (result == '0);
    assign c = is_addsub ? cout : 1'b0;
    assign v = is_addsub
               ? ((a[WIDTH-1] == b_sign_in_add) && (sum[WIDTH-1] != a[WIDTH-1]))
               : 1'b0;

endmodule
