// ============================================================
// Module: testbench_friend
// Description: Testbench matching friend's test suite exactly
//              Tests all 16 opcodes according to specification
// ============================================================
`timescale 1ns/1ps

module testbench_friend;

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
// DEVICE UNDER TEST
// ============================================================
breadboard_friend DUT (
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
// CLOCK GENERATION
// ============================================================
initial clk = 0;
always #5 clk = ~clk;

// ============================================================
// DISPLAY TASK
// ============================================================
task show_state;
    input integer test_num;
    input [31:0] expected_length;
    input [7:0]  expected_color;
    input [7:0]  expected_count;
    input [7:0]  expected_error;
    begin
        $display("=== TEST %0d ===", test_num);
        $display("Opcode: %04b, Data_in: %d", opcode, data_in);
        $display("Expected: length=%d, color=%d, count=%d, error=%d", 
                 expected_length, expected_color, expected_count, expected_error);
        $display("Actual:   length=%d, color=%d, count=%d, error=%d", 
                 blade_length, blade_color, blade_count, error_reg);
        if (blade_length == expected_length && 
            blade_color == expected_color && 
            blade_count == expected_count && 
            error_reg == expected_error) begin
            $display("✅ PASS");
        end else begin
            $display("❌ FAIL");
        end
        $display("");
    end
endtask

// ============================================================
// MAIN TEST SEQUENCE
// ============================================================
initial begin
    $display("=================================================");
    $display("FRIEND'S SYSTEM TEST SUITE - All 16 Opcodes");
    $display("=================================================");
    $display("");

    // Reset system
    reset = 1;
    opcode = 4'b0000;
    data_in = 32'h0;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
    $display("System reset complete");
    $display("");

    // Test 0000 - Power OFF
    $display("TEST 0000 - Power OFF");
    // First power on
    opcode = 4'b0001;
    @(posedge clk);
    #1;
    // Then power off
    opcode = 4'b0000;
    @(posedge clk);
    #1;
    show_state(0, 0, 0, 0, 0);

    // Test 0001 - Power ON
    $display("TEST 0001 - Power ON");
    opcode = 4'b0001;
    @(posedge clk);
    #1;
    show_state(1, 0, 0, 0, 0);

    // Test 0010 - Set Blade Length (value = 1)
    $display("TEST 0010 - Set Blade Length");
    data_in = 32'd1;
    opcode = 4'b0010;
    @(posedge clk);
    #1;
    show_state(2, 1, 0, 0, 0);

    // Test 0011 - Increment Length (1 -> 2)
    $display("TEST 0011 - Increment Length");
    data_in = 32'h0;
    opcode = 4'b0011;
    @(posedge clk);
    #1;
    show_state(3, 2, 0, 0, 0);

    // Test 0100 - Decrement Length (2 -> 1)
    $display("TEST 0100 - Decrement Length");
    opcode = 4'b0100;
    @(posedge clk);
    #1;
    show_state(4, 1, 0, 0, 0);

    // Test 0101 - Set Blade Color (value = 3)
    $display("TEST 0101 - Set Blade Color");
    data_in = 32'd3;
    opcode = 4'b0101;
    @(posedge clk);
    #1;
    show_state(5, 1, 3, 0, 0);

    // Test 0110 - Set Blade Count (value = 4)
    $display("TEST 0110 - Set Blade Count");
    data_in = 32'd4;
    opcode = 4'b0110;
    @(posedge clk);
    #1;
    show_state(6, 1, 3, 4, 0);

    // Test 0111 - Lock System
    $display("TEST 0111 - Lock System");
    data_in = 32'h0;
    opcode = 4'b0111;
    @(posedge clk);
    #1;
    show_state(7, 1, 3, 4, 0);

    // Test 1000 - Unlock System
    $display("TEST 1000 - Unlock System");
    opcode = 4'b1000;
    @(posedge clk);
    #1;
    show_state(8, 1, 3, 4, 0);

    // Test 1001 - Reset Errors
    $display("TEST 1001 - Reset Errors");
    // First set an error
    data_in = 32'd1;
    opcode = 4'b1110;
    @(posedge clk);
    #1;
    // Then reset
    opcode = 4'b1001;
    @(posedge clk);
    #1;
    show_state(9, 1, 3, 4, 0);

    // Test 1010 - Toggle Power
    $display("TEST 1010 - Toggle Power");
    // Power on first
    opcode = 4'b0001;
    @(posedge clk);
    #1;
    // Toggle to off
    opcode = 4'b1010;
    @(posedge clk);
    #1;
    show_state(10, 1, 3, 4, 0);
    // Toggle back on
    opcode = 4'b1010;
    @(posedge clk);
    #1;
    show_state(11, 1, 3, 4, 0);

    // Test 1011 - Double Length (4 -> 8)
    $display("TEST 1011 - Double Length");
    data_in = 32'd4;
    opcode = 4'b0010;
    @(posedge clk);
    #1;
    opcode = 4'b1011;
    @(posedge clk);
    #1;
    show_state(12, 8, 3, 4, 0);

    // Test 1100 - Clear Length (8 -> 0)
    $display("TEST 1100 - Clear Length");
    data_in = 32'd8;
    opcode = 4'b0010;
    @(posedge clk);
    #1;
    opcode = 4'b1100;
    @(posedge clk);
    #1;
    show_state(13, 0, 3, 4, 0);

    // Test 1101 - Maximize Length
    $display("TEST 1101 - Maximize Length");
    opcode = 4'b1101;
    @(posedge clk);
    #1;
    show_state(14, 32'hFFFFFFFF, 3, 4, 0);

    // Test 1110 - Set Error (value = 1)
    $display("TEST 1110 - Set Error");
    data_in = 32'd1;
    opcode = 4'b1110;
    @(posedge clk);
    #1;
    show_state(15, 32'hFFFFFFFF, 3, 4, 1);

    // Test 1111 - Invert Length (15 -> inverted)
    $display("TEST 1111 - Invert Length");
    // Reset and set length to 15 first
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
    #5;  // Extra delay to ensure reset is fully released
    
    data_in = 32'd15;
    opcode = 4'b0010;
    @(posedge clk);
    #1;
    $display("Set length to 15: blade_length = %d", blade_length);
    
    opcode = 4'b1111;
    @(posedge clk);
    #1;
    // Expected: all 1s except last 4 bits = ...11110000
    $display("DEBUG: Before invert length = %d", blade_length);
    $display("DEBUG: After invert length = %d", blade_length);
    $display("DEBUG: length_enable = %b", DUT.length_enable);
    $display("DEBUG: mux_sel = %b", DUT.mux_sel);
    $display("DEBUG: length_not_out = %d", DUT.length_not_out);
    show_state(16, 32'hFFFFFFF0, 3, 4, 1);

    // Reset Test
    $display("RESET TEST - Clear all registers");
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
    #1;
    show_state(17, 0, 0, 0, 0);

    $display("=================================================");
    $display("TEST SUITE COMPLETE");
    $display("=================================================");
    $finish;
end

endmodule
