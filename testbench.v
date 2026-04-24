`timescale 1ns/1ps

module testbench;

reg        clk;
reg        reset;
reg  [3:0] opcode;
reg  [31:0] data_in;

wire [31:0] blade_length;
wire [7:0]  blade_color;
wire [7:0]  blade_count;
wire [7:0]  error_reg;
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
    input [31:0]  data;
    begin
        opcode  = op;
        data_in = data;
        @(posedge clk);
        #1;
    end
endtask

task verify;
    input [31:0] expected_length;
    input [7:0]  expected_color;
    input [7:0]  expected_count;
    input [7:0]  expected_error;
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
    $display("  LIGHTSABER CONTROL CIRCUIT - STRUCTURAL OVERHAUL");
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
    verify(32'd0, 8'd0, 8'd0, 8'd0, 1'b1, 1'b0);
    send_opcode(4'b0000, 32'h0);
    verify(32'd0, 8'd0, 8'd0, 8'd0, 1'b0, 1'b0);
    $display("");

    // Test 0001: Power ON
    $display("TEST 0001: Power ON");
    send_opcode(4'b0001, 32'h0);
    verify(32'd0, 8'd0, 8'd0, 8'd0, 1'b1, 1'b0);
    $display("");

    // Test 0010: Set Blade Length
    $display("TEST 0010: Set Blade Length");
    send_opcode(4'b0010, 32'd1);
    // Note error expected assumes ERROR_MUX passes data_in whenever not resetting
    verify(32'd1, 8'd0, 8'd0, 8'd1, 1'b1, 1'b0);
    $display("");

    $display("=================================================================");
    $display("  TESTS COMPLETE");
    $display("=================================================================");
    $finish;
end

endmodule
