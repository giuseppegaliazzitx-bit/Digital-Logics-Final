// ============================================================
// Module: testbench
// Project: Lightsaber Control Circuit
// Cohort:  Halo 2 (2004)
// Members: Giuseppe Galiazzi, Ricky Lu, Mikael Rehman,
//          Mohamed Ibrahim, Samerawet Gorfe, Faiz Aye, Said Elsaadi
// Course:  CS 4341 - Spring 2026
//
// Description:
//   Behavioral testbench. Drives the breadboard DUT with a clock
//   and a scripted sequence of 29 test commands covering all 10
//   valid opcodes, error detection, and edge cases.
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
reg  [7:0] data_in;

wire [7:0] blade_length;
wire [7:0] blade_color;
wire [7:0] blade_count;
wire [7:0] error_reg;
wire       power_status;
wire       lock_status;

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
    .error_reg   (error_reg),
    .power_status(power_status),
    .lock_status (lock_status)
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
        $display("  DATA_IN        : %08b  (decimal %0d)", data_in, data_in);
        $display("  [OUTPUT] blade_length  = %08b  (%0d)", blade_length, blade_length);
        $display("  [OUTPUT] blade_color   = %08b  (%0d)", blade_color,  blade_color);
        $display("  [OUTPUT] blade_count   = %08b  (%0d)", blade_count,  blade_count);
        $display("  [STATUS] power_status  = %0b  (%s)",  power_status,
                  power_status ? "ON" : "OFF");
        $display("  [STATUS] lock_status   = %0b  (%s)",  lock_status,
                  lock_status  ? "LOCKED" : "UNLOCKED");
        $display("  [ERROR]  error_reg     = %08b", error_reg);
        if (error_reg[0]) $display("    >> ERR[0]: Command received while system is powered off");
        if (error_reg[1]) $display("    >> ERR[1]: Operation attempted while system is locked");
        if (error_reg[2]) $display("    >> ERR[2]: Blade length decrement underflow (was 0)");
        if (error_reg[3]) $display("    >> ERR[3]: Blade length increment overflow (was 255)");
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
    input [7:0]   data;
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
    $display("  Project Part 2  |  CS 4341 Spring 2026");
    $display("  Cohort: Halo 2 (2004)");
    $display("  Members: Giuseppe Galiazzi, Ricky Lu, Mikael Rehman,");
    $display("           Mohamed Ibrahim, Samerawet Gorfe, Faiz Aye,");
    $display("           Said Elsaadi");
    $display("=================================================================");
    $display("");

    // ---- RESET --------------------------------------------------
    $display(">>> APPLYING SYNCHRONOUS RESET (2 cycles)");
    $display(">>> All registers clearing to 0...");
    $display("");
    reset   = 1;
    opcode  = 4'b0000;
    data_in = 8'h00;
    @(posedge clk); #1;
    @(posedge clk); #1;
    reset = 0;
    $display(">>> Reset released. System ready.");
    $display("");

    // ---- TEST 1: Command while powered off ----------------------
    $display(">>> TEST 1: Set length while POWERED OFF -> expect ERR[0]");
    send_cmd(4'b0010, 8'd50, 1);

    // ---- TEST 2: Power ON ---------------------------------------
    $display(">>> TEST 2: Power ON (opcode 0001)");
    send_cmd(4'b0001, 8'h00, 2);

    // ---- TEST 3: Clear ERR[0] -----------------------------------
    $display(">>> TEST 3: Reset error register (opcode 1001)");
    send_cmd(4'b1001, 8'h00, 3);

    // ---- TEST 4: Set blade length = 50 -------------------------
    $display(">>> TEST 4: Set blade length = 50 (opcode 0010)");
    send_cmd(4'b0010, 8'd50, 4);

    // ---- TEST 5-7: Increment blade length -----------------------
    $display(">>> TEST 5: Increment length -> 51 (opcode 0011)");
    send_cmd(4'b0011, 8'h00, 5);

    $display(">>> TEST 6: Increment length -> 52 (opcode 0011)");
    send_cmd(4'b0011, 8'h00, 6);

    $display(">>> TEST 7: Increment length -> 53 (opcode 0011)");
    send_cmd(4'b0011, 8'h00, 7);

    // ---- TEST 8: Decrement blade length -------------------------
    $display(">>> TEST 8: Decrement length -> 52 (opcode 0100)");
    send_cmd(4'b0100, 8'h00, 8);

    // ---- TEST 9: Set blade color --------------------------------
    $display(">>> TEST 9: Set blade color = 3/Green (opcode 0101)");
    send_cmd(4'b0101, 8'd3, 9);

    // ---- TEST 10: Set blade count -------------------------------
    $display(">>> TEST 10: Set blade count = 2 (opcode 0110)");
    send_cmd(4'b0110, 8'd2, 10);

    // ---- TEST 11: Lock system -----------------------------------
    $display(">>> TEST 11: Lock system (opcode 0111)");
    send_cmd(4'b0111, 8'h00, 11);

    // ---- TEST 12: Op while locked -> ERR[1] --------------------
    $display(">>> TEST 12: Set length while LOCKED -> expect ERR[1]");
    send_cmd(4'b0010, 8'd99, 12);

    // ---- TEST 13: Unlock system ---------------------------------
    $display(">>> TEST 13: Unlock system (opcode 1000)");
    send_cmd(4'b1000, 8'h00, 13);

    // ---- TEST 14: Reset error -----------------------------------
    $display(">>> TEST 14: Reset error register (opcode 1001)");
    send_cmd(4'b1001, 8'h00, 14);

    // ---- TEST 15-16: Underflow ----------------------------------
    $display(">>> TEST 15: Set blade length = 0 (opcode 0010)");
    send_cmd(4'b0010, 8'd0, 15);

    $display(">>> TEST 16: Decrement from 0 -> expect ERR[2] underflow");
    send_cmd(4'b0100, 8'h00, 16);

    // ---- TEST 17: Reset error -----------------------------------
    $display(">>> TEST 17: Reset error register (opcode 1001)");
    send_cmd(4'b1001, 8'h00, 17);

    // ---- TEST 18-19: Overflow -----------------------------------
    $display(">>> TEST 18: Set blade length = 255 (opcode 0010)");
    send_cmd(4'b0010, 8'd255, 18);

    $display(">>> TEST 19: Increment from 255 -> expect ERR[3] overflow");
    send_cmd(4'b0011, 8'h00, 19);

    // ---- TEST 20: Reset error -----------------------------------
    $display(">>> TEST 20: Reset error register (opcode 1001)");
    send_cmd(4'b1001, 8'h00, 20);

    // ---- TEST 21-22: Invalid opcodes ----------------------------
    $display(">>> TEST 21: Invalid opcode 1010 -> expect ERR[4]");
    send_cmd(4'b1010, 8'h00, 21);

    $display(">>> TEST 22: Invalid opcode 1111 -> expect ERR[4] persists");
    send_cmd(4'b1111, 8'hFF, 22);

    // ---- TEST 23: Reset error -----------------------------------
    $display(">>> TEST 23: Reset error register (opcode 1001)");
    send_cmd(4'b1001, 8'h00, 23);

    // ---- TEST 24-28: Multi-op sequence --------------------------
    $display(">>> TEST 24: Set blade length = 100");
    send_cmd(4'b0010, 8'd100, 24);

    $display(">>> TEST 25: Set blade color = 7 (white)");
    send_cmd(4'b0101, 8'd7, 25);

    $display(">>> TEST 26: Set blade count = 1");
    send_cmd(4'b0110, 8'd1, 26);

    $display(">>> TEST 27: Increment length -> 101");
    send_cmd(4'b0011, 8'h00, 27);

    $display(">>> TEST 28: Increment length -> 102");
    send_cmd(4'b0011, 8'h00, 28);

    // ---- TEST 29: Power OFF -------------------------------------
    $display(">>> TEST 29: Power OFF (opcode 0000)");
    send_cmd(4'b0000, 8'h00, 29);

    $display("=================================================================");
    $display("  SIMULATION COMPLETE - All test cases finished.");
    $display("=================================================================");
    $finish;
end

endmodule
