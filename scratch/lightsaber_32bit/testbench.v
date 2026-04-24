`timescale 1ns/1ps

module testbench;

reg        clk;
reg        reset;
reg  [3:0] opcode;
reg  [31:0] data_in;

wire [31:0] blade_length;
wire [31:0] blade_color;
wire [31:0] blade_count;
wire [31:0] error_reg;
wire        power_status;
wire        lock_status;

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

initial clk = 0;
always #5 clk = ~clk;

task send_opcode;
    input [3:0]   op;
    input [31:0]   data;
    begin
        opcode  = op;
        data_in = data;
        @(posedge clk);
        #1;
    end
endtask

task verify;
    input [31:0] expected_length;
    input [31:0] expected_color;
    input [31:0] expected_count;
    input [31:0] expected_error;
    input        expected_power;
    input        expected_lock;
    integer pass;
    begin
        pass = 1;
        if (blade_length !== expected_length) begin
            $display("  ✗ FAIL: blade_length = %0d, expected %0d", blade_length, expected_length);
            pass = 0;
        end
        if (blade_color !== expected_color) begin
            $display("  ✗ FAIL: blade_color = %0d, expected %0d", blade_color, expected_color);
            pass = 0;
        end
        if (blade_count !== expected_count) begin
            $display("  ✗ FAIL: blade_count = %0d, expected %0d", blade_count, expected_count);
            pass = 0;
        end
        if (error_reg !== expected_error) begin
            $display("  ✗ FAIL: error_reg = %0d, expected %0d", error_reg, expected_error);
            pass = 0;
        end
        if (power_status !== expected_power) begin
            $display("  ✗ FAIL: power_status = %0b, expected %0b", power_status, expected_power);
            pass = 0;
        end
        if (lock_status !== expected_lock) begin
            $display("  ✗ FAIL: lock_status = %0b, expected %0b", lock_status, expected_lock);
            pass = 0;
        end
        
        if (pass) $display("  ✓ PASS");
    end
endtask

initial begin
    $display("=================================================================");
    $display("  LIGHTSABER CONTROL CIRCUIT - FULL TEST SUITE");
    $display("  32-bit System | CS 4341 Spring 2026");
    $display("=================================================================");
    $display("");

    reset   = 1;
    opcode  = 4'b0000;
    data_in = 32'h00;
    @(posedge clk); #1;
    @(posedge clk); #1;
    reset = 0;
    @(posedge clk); #1;
    $display("");

    // Test 0000: Power OFF
    $display("TEST 0000: Power OFF");
    send_opcode(4'b0001, 32'h0);
    verify(32'd0, 32'd0, 32'd0, 32'd0, 1'b1, 1'b0);
    send_opcode(4'b0000, 32'h0);
    verify(32'd0, 32'd0, 32'd0, 32'd0, 1'b0, 1'b0);
    $display("");

    // Test 0001: Power ON
    $display("TEST 0001: Power ON");
    send_opcode(4'b0001, 32'h0);
    verify(32'd0, 32'd0, 32'd0, 32'd0, 1'b1, 1'b0);
    $display("");

    // Test 0010: Set Blade Length
    $display("TEST 0010: Set Blade Length");
    send_opcode(4'b0010, 32'd1);
    verify(32'd1, 32'd0, 32'd0, 32'd0, 1'b1, 1'b0);
    $display("");

    // Test 0011: Increment Length
    $display("TEST 0011: Increment Length");
    send_opcode(4'b0011, 32'h0);
    verify(32'd2, 32'd0, 32'd0, 32'd0, 1'b1, 1'b0);
    $display("");

    // Test 0100: Decrement Length
    $display("TEST 0100: Decrement Length");
    send_opcode(4'b0100, 32'h0);
    verify(32'd1, 32'd0, 32'd0, 32'd0, 1'b1, 1'b0);
    $display("");

    // Test 0101: Set Blade Color
    $display("TEST 0101: Set Blade Color");
    send_opcode(4'b0101, 32'd3);
    verify(32'd1, 32'd3, 32'd0, 32'd0, 1'b1, 1'b0);
    $display("");

    // Test 0110: Set Blade Count
    $display("TEST 0110: Set Blade Count");
    send_opcode(4'b0110, 32'd4);
    verify(32'd1, 32'd3, 32'd4, 32'd0, 1'b1, 1'b0);
    $display("");

    // Test 0111: Lock System
    $display("TEST 0111: Lock System");
    send_opcode(4'b0111, 32'h0);
    verify(32'd1, 32'd3, 32'd4, 32'd0, 1'b1, 1'b1);
    $display("");

    // Test 1000: Unlock System
    $display("TEST 1000: Unlock System");
    send_opcode(4'b1000, 32'h0);
    verify(32'd1, 32'd3, 32'd4, 32'd0, 1'b1, 1'b0);
    $display("");

    // Test 1001: Reset Errors
    $display("TEST 1001: Reset Errors");
    send_opcode(4'b1110, 32'd1);
    verify(32'd1, 32'd3, 32'd4, 32'd16, 1'b1, 1'b0);
    send_opcode(4'b1001, 32'h0);
    verify(32'd1, 32'd3, 32'd4, 32'd0, 1'b1, 1'b0);
    $display("");

    // Test 1010: Toggle Power
    $display("TEST 1010: Toggle Power");
    send_opcode(4'b0001, 32'h0);
    verify(32'd1, 32'd3, 32'd4, 32'd0, 1'b1, 1'b0);
    send_opcode(4'b1010, 32'h0);
    verify(32'd1, 32'd3, 32'd4, 32'd0, 1'b0, 1'b0);
    send_opcode(4'b1010, 32'h0);
    verify(32'd1, 32'd3, 32'd4, 32'd0, 1'b1, 1'b0);
    $display("");

    // Test 1011: Double Length
    $display("TEST 1011: Double Length");
    send_opcode(4'b0010, 32'd4);
    verify(32'd4, 32'd3, 32'd4, 32'd0, 1'b1, 1'b0);
    send_opcode(4'b1011, 32'h0);
    verify(32'd8, 32'd3, 32'd4, 32'd0, 1'b1, 1'b0);
    $display("");

    $display("=================================================================");
    $display("  ALL TESTS COMPLETE");
    $display("=================================================================");
    $finish;
end

endmodule
