`timescale 1ns / 1ps

// Prueba de humo de la parametrizacion: instancia la MISMA arquitectura
// (alu_plus) a 16 y 32 bits sin tocar un solo archivo de src/, y corre un
// puñado de casos dirigidos en cada ancho. No reemplaza al testbench
// principal (sim/testbench.sv, WIDTH=8, 35 checks) -- solo demuestra que
// "instanciar la ALU de 16 o 32 bits sin cambiar la arquitectura" (PDF,
// Parte 1) realmente funciona, incluyendo el prefix adder (log2(WIDTH)
// etapas) y el divisor en arreglo (WIDTH etapas).
module testbench_widths;

    int pass_count = 0;
    int fail_count = 0;

    // ---------------- WIDTH = 16 ----------------
    localparam integer W16 = 16;
    logic [W16-1:0] a16, b16, result16;
    logic [2:0]     ctrl16;
    logic           n16, z16, c16, v16;

    alu_plus #(.WIDTH(W16)) dut16 (
        .a(a16), .b(b16), .aluControl(ctrl16),
        .result(result16), .n(n16), .z(z16), .c(c16), .v(v16)
    );

    // ---------------- WIDTH = 32 ----------------
    localparam integer W32 = 32;
    logic [W32-1:0] a32, b32, result32;
    logic [2:0]     ctrl32;
    logic           n32, z32, c32, v32;

    alu_plus #(.WIDTH(W32)) dut32 (
        .a(a32), .b(b32), .aluControl(ctrl32),
        .result(result32), .n(n32), .z(z32), .c(c32), .v(v32)
    );

    task automatic report(input string tag, input bit ok);
        if (ok) begin
            pass_count++;
            $display("PASS - %s", tag);
        end else begin
            fail_count++;
            $display("FAIL - %s", tag);
        end
    endtask

    initial begin
        // ---- WIDTH=16 ----
        a16 = 16'd1000; b16 = 16'd1;   ctrl16 = 3'b010; #1; // ADD
        report("W16-add", result16 === 16'd1001);

        a16 = 16'hFFFF; b16 = 16'd1;   ctrl16 = 3'b010; #1; // ADD con carry
        report("W16-add-carry", (result16 === 16'd0) && c16);

        a16 = 16'd50000; b16 = 16'd7;  ctrl16 = 3'b101; #1; // DIV cociente
        report("W16-div", result16 === (16'd50000 / 16'd7));

        a16 = 16'd50000; b16 = 16'd7;  ctrl16 = 3'b110; #1; // DIV residuo
        report("W16-rem", result16 === (16'd50000 % 16'd7));

        a16 = 16'hABCD; b16 = 16'h1234; ctrl16 = 3'b011; #1; // SUB
        report("W16-sub", result16 === (16'hABCD - 16'h1234));

        // ---- WIDTH=32 ----
        a32 = 32'd1_000_000; b32 = 32'd1; ctrl32 = 3'b010; #1; // ADD
        report("W32-add", result32 === 32'd1_000_001);

        a32 = 32'hFFFFFFFF; b32 = 32'd1;  ctrl32 = 3'b010; #1; // ADD con carry
        report("W32-add-carry", (result32 === 32'd0) && c32);

        a32 = 32'd1_000_003; b32 = 32'd7; ctrl32 = 3'b101; #1; // DIV cociente
        report("W32-div", result32 === (32'd1_000_003 / 32'd7));

        a32 = 32'd1_000_003; b32 = 32'd7; ctrl32 = 3'b110; #1; // DIV residuo
        report("W32-rem", result32 === (32'd1_000_003 % 32'd7));

        a32 = 32'h8000_0000; b32 = 32'h8000_0000; ctrl32 = 3'b010; #1; // overflow signed
        report("W32-add-overflow", v32 === 1'b1);

        $display("==================================================");
        $display("RESULTADO (anchos 16/32): %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0)
            $display("TESTBENCH_WIDTHS: PASS");
        else
            $display("TESTBENCH_WIDTHS: FAIL");
        $display("==================================================");

        $finish;
    end

endmodule
