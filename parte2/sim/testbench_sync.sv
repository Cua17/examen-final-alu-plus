`timescale 1ns / 1ps

// Chequeo funcional de alu_plus_sync (WIDTH=16) antes de subirlo al
// servidor con VCS/Verdi (item 1, Parte 2). Corrido aqui con xsim porque
// VCS/Verdi no estan instalados en esta maquina -- esto NO reemplaza la
// verificacion pedida con VCS/Verdi, solo confirma que la logica (latencia
// de 2 ciclos: registro de entrada -> ALU comb. -> registro de salida) esta
// bien antes de gastar tiempo de servidor en ella. Ver parte2/docs/.
module testbench_sync;

    localparam integer WIDTH = 16;
    localparam time    CLK_PERIOD = 10ns;

    logic              clk = 0;
    logic              reset;
    logic [WIDTH-1:0]  a_in, b_in;
    logic [2:0]        aluControl_in;
    logic [WIDTH-1:0]  result_out;
    logic              n_out, z_out, c_out, v_out;

    int pass_count = 0;
    int fail_count = 0;

    alu_plus_sync #(.WIDTH(WIDTH)) dut (.*);

    always #(CLK_PERIOD/2) clk = ~clk;

    task automatic apply_and_check(
        input string           tag,
        input logic [WIDTH-1:0] av,
        input logic [WIDTH-1:0] bv,
        input logic [2:0]       ctrl,
        input logic [WIDTH-1:0] expected
    );
        @(posedge clk);
        a_in = av; b_in = bv; aluControl_in = ctrl;
        @(posedge clk); // registro de entrada captura a_in/b_in/ctrl
        @(posedge clk); // registro de salida captura el resultado comb.
        #1;
        if (result_out === expected) begin
            pass_count++;
            $display("PASS - %s - result_out=%0d", tag, result_out);
        end else begin
            fail_count++;
            $display("FAIL - %s - result_out=%0d (esperado %0d)", tag, result_out, expected);
        end
    endtask

    initial begin
        reset = 1;
        a_in = '0; b_in = '0; aluControl_in = '0;
        repeat (2) @(posedge clk);
        reset = 0;

        apply_and_check("S0-add",  16'd100, 16'd23, 3'b010, 16'd123);
        apply_and_check("S1-sub",  16'd100, 16'd23, 3'b011, 16'd77);
        apply_and_check("S2-div",  16'd100, 16'd7,  3'b101, 16'd100/16'd7);
        apply_and_check("S3-rem",  16'd100, 16'd7,  3'b110, 16'd100%16'd7);
        apply_and_check("S4-and",  16'hFF00, 16'h0FF0, 3'b000, 16'h0F00);

        $display("==================================================");
        $display("RESULTADO (sync): %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0)
            $display("TESTBENCH_SYNC: PASS");
        else
            $display("TESTBENCH_SYNC: FAIL");
        $display("==================================================");

        $finish;
    end

endmodule
