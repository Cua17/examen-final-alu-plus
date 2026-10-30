`timescale 1ns / 1ps

// Testbench autoverificable para alu_plus (WIDTH=8 por default). Cada check
// compara contra un modelo de referencia calculado con operadores nativos
// de SystemVerilog (no reimplementa Kogge-Stone ni el divisor en arreglo:
// si lo hiciera, un error de logica se repetiria igual en el "modelo" y en
// el RTL, y el testbench nunca lo detectaria).
module testbench;

    localparam integer WIDTH = 8;

    logic [WIDTH-1:0] a, b;
    logic [2:0]       aluControl;
    logic [WIDTH-1:0] result;
    logic             n, z, c, v;

    int pass_count = 0;
    int fail_count = 0;

    alu_plus #(.WIDTH(WIDTH)) dut (
        .a          (a),
        .b          (b),
        .aluControl (aluControl),
        .result     (result),
        .n          (n),
        .z          (z),
        .c          (c),
        .v          (v)
    );

    // ------------------------------------------------------------------
    // Modelo de referencia
    // ------------------------------------------------------------------
    task automatic check_alu(
        input string          tag,
        input logic [WIDTH-1:0] av,
        input logic [WIDTH-1:0] bv,
        input logic [2:0]       ctrl
    );
        logic [WIDTH-1:0]   exp_result;
        logic               exp_n, exp_z, exp_c, exp_v;
        logic [WIDTH:0]     wide_add, wide_sub;
        int                 signed_a, signed_b, signed_sum;
        logic               ok;

        a = av; b = bv; aluControl = ctrl;
        #1;

        wide_add = {1'b0, av} + {1'b0, bv};
        wide_sub = {1'b0, av} - {1'b0, bv};
        signed_a = $signed(av);
        signed_b = $signed(bv);

        unique case (ctrl)
            3'b000: exp_result = av & bv;
            3'b001: exp_result = av | bv;
            3'b010: exp_result = wide_add[WIDTH-1:0];
            3'b011: exp_result = wide_sub[WIDTH-1:0];
            3'b100: exp_result = '0;
            3'b101: exp_result = (bv == '0) ? '1 : (av / bv);
            3'b110: exp_result = (bv == '0) ? '1 : (av % bv);
            3'b111: exp_result = '0;
            default: exp_result = '0;
        endcase

        exp_n = exp_result[WIDTH-1];
        exp_z = (exp_result == '0);

        if (ctrl == 3'b010) begin
            exp_c = wide_add[WIDTH];
            signed_sum = signed_a + signed_b;
        end else if (ctrl == 3'b011) begin
            exp_c = ~wide_sub[WIDTH];        // no hubo "prestamo" = C=1 (convencion ARM)
            signed_sum = signed_a - signed_b;
        end else begin
            exp_c = 1'b0;
            signed_sum = 0;
        end

        if (ctrl == 3'b010 || ctrl == 3'b011)
            exp_v = (signed_sum > (2 ** (WIDTH - 1)) - 1) || (signed_sum < -(2 ** (WIDTH - 1)));
        else
            exp_v = 1'b0;

        ok = (result === exp_result) && (n === exp_n) && (z === exp_z)
             && (c === exp_c) && (v === exp_v);

        if (ok) begin
            pass_count++;
            $display("PASS - %s - a=%0d b=%0d ctrl=%03b -> result=%0d NZCV=%b%b%b%b",
                      tag, av, bv, ctrl, result, n, z, c, v);
        end else begin
            fail_count++;
            $display("FAIL - %s - a=%0d b=%0d ctrl=%03b -> result=%0d (esperado %0d) NZCV=%b%b%b%b (esperado %b%b%b%b)",
                      tag, av, bv, ctrl, result, exp_result, n, z, c, v, exp_n, exp_z, exp_c, exp_v);
        end
    endtask

    initial begin
        // --- AND / OR ---
        check_alu("A0-and",        8'h0F, 8'hF0, 3'b000);
        check_alu("A1-and-zero",   8'hAA, 8'h00, 3'b000);
        check_alu("A2-and-allone", 8'hFF, 8'hFF, 3'b000);
        check_alu("A3-or",         8'h0F, 8'hF0, 3'b001);
        check_alu("A4-or-zero",    8'h00, 8'h00, 3'b001);
        check_alu("A5-or-allone",  8'hFF, 8'h00, 3'b001);

        // --- ADD ---
        check_alu("B0-add-simple",    8'd10, 8'd20, 3'b010);
        check_alu("B1-add-carry",     8'hFF, 8'h01, 3'b010); // genera carry, result=0
        check_alu("B2-add-zero",      8'h00, 8'h00, 3'b010);
        check_alu("B3-add-ovf-pos",   8'h7F, 8'h01, 3'b010); // 127+1 -> overflow signed
        check_alu("B4-add-neg",       8'h80, 8'h80, 3'b010); // -128 + -128 -> overflow signed

        // --- SUB ---
        check_alu("C0-sub-simple",    8'd20, 8'd5,  3'b011);
        check_alu("C1-sub-equal",     8'd42, 8'd42, 3'b011); // Z=1
        check_alu("C2-sub-borrow",    8'd5,  8'd20, 3'b011); // a<b, C=0 (hubo prestamo)
        check_alu("C3-sub-ovf",       8'h80, 8'h01, 3'b011); // -128 - 1 -> overflow signed

        // --- MUL reservado (no asignado, debe dar 0) ---
        check_alu("D0-mul-reservado", 8'd6, 8'd7, 3'b100);

        // --- DIV (cociente) ---
        check_alu("E0-div-exact",     8'd20, 8'd5, 3'b101);
        check_alu("E1-div-resto",     8'd17, 8'd5, 3'b101);
        check_alu("E2-div-por-uno",   8'd200, 8'd1, 3'b101);
        check_alu("E3-div-a-menor",   8'd3, 8'd10, 3'b101); // cociente 0
        check_alu("E4-div-por-cero",  8'd42, 8'd0, 3'b101); // convencion: todo unos

        // --- DIV (residuo) ---
        check_alu("F0-rem-exact",     8'd20, 8'd5, 3'b110); // residuo 0
        check_alu("F1-rem-resto",     8'd17, 8'd5, 3'b110); // residuo 2
        check_alu("F2-rem-a-menor",   8'd3, 8'd10, 3'b110); // residuo 3
        check_alu("F3-rem-por-cero",  8'd42, 8'd0, 3'b110); // convencion: todo unos

        // --- ZERO ---
        check_alu("G0-zero",          8'hFF, 8'hFF, 3'b111);
        check_alu("G1-zero-otros",    8'd0,  8'd0,  3'b111);

        // --- barrido adicional: todas las combinaciones de ctrl con un par fijo ---
        for (int cc = 0; cc < 8; cc++) begin
            check_alu($sformatf("H%0d-barrido", cc), 8'd91, 8'd13, cc[2:0]);
        end

        $display("==================================================");
        $display("RESULTADO: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0)
            $display("TESTBENCH: PASS");
        else
            $display("TESTBENCH: FAIL");
        $display("==================================================");

        $finish;
    end

endmodule
