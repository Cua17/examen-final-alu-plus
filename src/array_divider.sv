`timescale 1ns / 1ps

// Divisor en arreglo (array divider), combinacional, parametrizado en
// ancho. Asignacion de extension para este examen: "Cua, Chamo y Pili:
// Divisor" (ver docs/01-alu-estructura.md). Division entera sin signo.
//
// Mismo principio estructural que un multiplicador en arreglo (una celda
// por bit, en cascada), pero cada celda hace "shift + resta de prueba +
// restaurar si el resultado se hizo negativo" en vez de "shift + suma
// condicional". Es la version combinacional (totalmente desenrollada) del
// algoritmo de division restauradora que se ve en clase para un divisor
// secuencial bit a bit.
module array_divider #(
    parameter integer WIDTH = 8
) (
    input  logic [WIDTH-1:0] dividend,
    input  logic [WIDTH-1:0] divisor,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder
);

    // rem[0] = residuo parcial antes de procesar ningun bit (0)
    // rem[WIDTH] = residuo final, despues de procesar los WIDTH bits del
    // dividendo de mas significativo a menos significativo
    logic [WIDTH:0] rem [0:WIDTH];
    logic [WIDTH-1:0] quotient_raw;

    assign rem[0] = '0;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : stage
            logic [WIDTH:0] shifted;
            logic [WIDTH:0] trial;

            // desplaza el residuo parcial un bit a la izquierda y mete el
            // siguiente bit del dividendo (MSB primero)
            assign shifted = {rem[i][WIDTH-1:0], dividend[WIDTH-1-i]};
            // resta de prueba: si "pide prestado" (bit WIDTH en 1), no cabia
            assign trial = shifted - {1'b0, divisor};

            assign quotient_raw[WIDTH-1-i] = ~trial[WIDTH];
            // si no cupo, restaura el residuo (se queda con "shifted"); si
            // cupo, el residuo nuevo es la resta ya hecha
            assign rem[i+1] = trial[WIDTH] ? shifted : trial;
        end
    endgenerate

    // division por cero: convencion de error = todo unos en cociente y
    // residuo (documentado en docs/02-divisor.md), evita un resultado
    // indefinido silencioso
    assign quotient  = (divisor == '0) ? '1 : quotient_raw;
    assign remainder = (divisor == '0) ? '1 : rem[WIDTH][WIDTH-1:0];

endmodule
