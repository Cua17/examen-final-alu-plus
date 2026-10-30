`timescale 1ns / 1ps

// Envoltorio sincrono de alu_plus para la Parte 2 (item 1 del PDF):
// registros de entrada y de salida alrededor de la ALU+ combinacional, para
// tener un sistema sincrono real antes de sintetizar. Reset sincrono (mas
// facil de cerrar timing en ASIC que uno asincrono, y es lo que pide
// "sistema sincrono" aqui -- a diferencia del reset asincrono de P3 que era
// para un boton fisico en la Basys3).
module alu_plus_sync #(
    parameter integer WIDTH = 16
) (
    input  logic             clk,
    input  logic             reset,
    input  logic [WIDTH-1:0] a_in,
    input  logic [WIDTH-1:0] b_in,
    input  logic [2:0]       aluControl_in,
    output logic [WIDTH-1:0] result_out,
    output logic             n_out,
    output logic             z_out,
    output logic             c_out,
    output logic             v_out
);

    logic [WIDTH-1:0] a_reg, b_reg;
    logic [2:0]       ctrl_reg;
    logic [WIDTH-1:0] result_comb;
    logic              n_comb, z_comb, c_comb, v_comb;

    // registro de entrada
    always_ff @(posedge clk) begin
        if (reset) begin
            a_reg    <= '0;
            b_reg    <= '0;
            ctrl_reg <= '0;
        end else begin
            a_reg    <= a_in;
            b_reg    <= b_in;
            ctrl_reg <= aluControl_in;
        end
    end

    alu_plus #(.WIDTH(WIDTH)) u_alu (
        .a          (a_reg),
        .b          (b_reg),
        .aluControl (ctrl_reg),
        .result     (result_comb),
        .n          (n_comb),
        .z          (z_comb),
        .c          (c_comb),
        .v          (v_comb)
    );

    // registro de salida
    always_ff @(posedge clk) begin
        if (reset) begin
            result_out <= '0;
            n_out      <= 1'b0;
            z_out      <= 1'b0;
            c_out      <= 1'b0;
            v_out      <= 1'b0;
        end else begin
            result_out <= result_comb;
            n_out      <= n_comb;
            z_out      <= z_comb;
            c_out      <= c_comb;
            v_out      <= v_comb;
        end
    end

endmodule
