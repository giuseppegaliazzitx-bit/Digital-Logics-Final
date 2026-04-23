// ============================================================
// Module: testbench
// Project: Lightsaber Control Circuit
// Cohort:  Halo 2 (2004)
// Members: Giuseppe Galiazzi, Ricky Lu, Mikael Rehman,
//          Mohamed Ibrahim, Samerawit Gorfe, Faiz Aye, Said Elsaadi
// Course:  CS 4341 - Spring 2026
//
// Description:
//   Behavioral testbench. Drives the breadboard DUT with a clock
//   and a scripted sequence of test commands covering all 16
//   opcodes, error detection, and edge cases.
//
//   Per assignment output requirements, each cycle displays:
//     - The current opcode loaded
//     - The current input values
//     - The current output values
//     - Any active error codes or status messages
// ============================================================
`timescale 1ns/1ps

module testbench;

// ============================================================
// TESTBENCH SIGNALS
// ============================================================
reg        clk;
reg        reset;
reg  [3:0] opcode;
reg  [31:0] data_in;

wire [31:0] blade_length;
wire [7:0]  blade_color;
wire [7:0]  blade_count;
wire [7:0]  error_reg;

// ============================================================
// DEVICE UNDER TEST — BREADBOARD
// ============================================================
breadboard DUT (
    .clk         (clk),
    .reset       (reset),
    .opcode      (opcode),
    .data_in     (data_in),
    .blade_length(blade_length),
    .blade_color (blade_color),
    .blade_count (blade_count),
    .error_reg   (error_reg)
);

// ============================================================
// CLOCK: 10 ns period (100 MHz)
// ============================================================
initial clk = 0;
always  #5 clk = ~clk;

// ============================================================
// DISPLAY TASK — called after each clock edge
// ============================================================
task show_state;
    input integer test_num;
    begin
        $display("--- Test %0d ---", test_num);
        $display("  OPCODE LOADED  : %04b  (decimal %0d)", opcode, opcode);
        $display("  DATA_IN        : %032b  (decimal %0d)", data_in, data_in);
        $display("  [OUTPUT] blade_length  = %032b  (%0d)", blade_length, blade_length);
        $display("  [OUTPUT] blade_color   = %08b  (%0d)", blade_color,  blade_color);
        $display("  [OUTPUT] blade_count   = %08b  (%0d)", blade_count,  blade_count);
        $display("  [ERROR]  error_reg     = %08b", error_reg);
        if (error_reg[0]) $display("    >> ERR[0]: Command received while system is powered off");
        if (error_reg[1]) $display("    >> ERR[1]: Operation attempted while system is locked");
        if (error_reg[4]) $display("    >> ERR[4]: Invalid opcode received (reserved 1010-1111)");
        if (error_reg == 8'h00) $display("    >> [OK] No errors");
        $display("");
    end
endtask

// ============================================================
// SEND COMMAND TASK
// ============================================================
task send_cmd;
    input [3:0]   op;
    input [31:0]  data;
    input integer test_num;
    begin
        opcode  = op;
        data_in = data;
        @(posedge clk);
        #1;
        show_state(test_num);
    end
endtask

// ============================================================
// TEST SEQUENCE
// ============================================================
initial begin
    $display("=================================================================");
    $display("  LIGHTSABER CONTROL CIRCUIT - SIMULATION OUTPUT");
    $display("  Full 16-bit Opcode Test  |  CS 4341 Spring 2026");
    $display("  Cohort: Halo 2 (2004)");
    $display("  Members: Giuseppe Galiazzi, Ricky Lu, Mikael Rehman,");
    $display("           Mohamed Ibrahim, Samerawit Gorfe, Faiz Aye,");
    $display("           Said Elsaadi");
    $display("=================================================================");
    $display("");

    // ---- RESET --------------------------------------------------
    $display(">>> APPLYING SYNCHRONOUS RESET (2 cycles)");
    $display(">>> All registers clearing to 0...");
    $display("");
    reset   = 1;
    opcode  = 4'b0000;
    data_in = 32'h0;
    @(posedge clk); #1;
    @(posedge clk); #1;
    reset = 0;
    $display(">>> Reset released. System ready.");
    $display("");

    // ---- TEST 1: Command while powered off ----------------------
    $display(">>> TEST 1: Set length while POWERED OFF -> expect ERR[0]");
    send_cmd(4'b0010, 32'd50, 1);

    // ---- TEST 2: Power ON ---------------------------------------
    $display(">>> TEST 2: Power ON (opcode 0001)");
    send_cmd(4'b0001, 32'h0, 2);

    // ---- TEST 3: Clear ERR[0] -----------------------------------
    $display(">>> TEST 3: Reset error register (opcode 1001)");
    send_cmd(4'b1001, 32'h0, 3);

    // ---- TEST 4: Set blade length = 100 -------------------------
    $display(">>> TEST 4: Set blade length = 100 (opcode 0010)");
    send_cmd(4'b0010, 32'd100, 4);

    // ---- TEST 5: Increment blade length -------------------------
    $display(">>> TEST 5: Increment length -> 101 (opcode 0011)");
    send_cmd(4'b0011, 32'h0, 5);

    // ---- TEST 6: Decrement blade length -------------------------
    $display(">>> TEST 6: Decrement length -> 100 (opcode 0100)");
    send_cmd(4'b0100, 32'h0, 6);

    // ---- TEST 7: Set blade color --------------------------------
    $display(">>> TEST 7: Set blade color = 5 (opcode 0101)");
    send_cmd(4'b0101, 32'd5, 7);

    // ---- TEST 8: Set blade count -------------------------------
    $display(">>> TEST 8: Set blade count = 3 (opcode 0110)");
    send_cmd(4'b0110, 32'd3, 8);

    // ---- TEST 9: Lock system -----------------------------------
    $display(">>> TEST 9: Lock system (opcode 0111)");
    send_cmd(4'b0111, 32'h0, 9);

    // ---- TEST 10: Op while locked -> ERR[1] --------------------
    $display(">>> TEST 10: Set length while LOCKED -> expect ERR[1]");
    send_cmd(4'b0010, 32'd200, 10);

    // ---- TEST 11: Unlock system ---------------------------------
    $display(">>> TEST 11: Unlock system (opcode 1000)");
    send_cmd(4'b1000, 32'h0, 11);

    // ---- TEST 12: Reset error -----------------------------------
    $display(">>> TEST 12: Reset error register (opcode 1001)");
    send_cmd(4'b1001, 32'h0, 12);

    // ---- TEST 13: Toggle Power ----------------------------------
    $display(">>> TEST 13: Toggle Power (opcode 1010)");
    send_cmd(4'b1010, 32'h0, 13);

    // ---- TEST 14: Toggle Power back ON -------------------------
    $display(">>> TEST 14: Toggle Power back ON (opcode 1010)");
    send_cmd(4'b1010, 32'h0, 14);

    // ---- TEST 15: Double Length ---------------------------------
    $display(">>> TEST 15: Double Length (opcode 1011)");
    send_cmd(4'b1011, 32'h0, 15);

    // ---- TEST 16: Clear Length ----------------------------------
    $display(">>> TEST 16: Clear Length (opcode 1100)");
    send_cmd(4'b1100, 32'h0, 16);

    // ---- TEST 17: Set length again for next tests ---------------
    $display(">>> TEST 17: Set blade length = 1000 (opcode 0010)");
    send_cmd(4'b0010, 32'd1000, 17);

    // ---- TEST 18: Maximize Length -------------------------------
    $display(">>> TEST 18: Maximize Length (opcode 1101)");
    send_cmd(4'b1101, 32'h0, 18);

    // ---- TEST 19: Invert Length --------------------------------
    $display(">>> TEST 19: Invert Length (opcode 1111)");
    send_cmd(4'b1111, 32'h0, 19);

    // ---- TEST 20: Set Error ------------------------------------
    $display(">>> TEST 20: Set Error (opcode 1110)");
    send_cmd(4'b1110, 32'h85, 20);

    // ---- TEST 21: Reset error -----------------------------------
    $display(">>> TEST 21: Reset error register (opcode 1001)");
    send_cmd(4'b1001, 32'h0, 21);

    // ---- TEST 22: Power OFF -------------------------------------
    $display(">>> TEST 22: Power OFF (opcode 0000)");
    send_cmd(4'b0000, 32'h0, 22);

    // ---- TEST 23: Try command while powered off ----------------
    $display(">>> TEST 23: Try increment while powered off -> ERR[0]");
    send_cmd(4'b0011, 32'h0, 23);

    $display("=================================================================");
    $display("  SIMULATION COMPLETE - All 16 opcodes tested.");
    $display("=================================================================");
    $finish;
end

endmodule
