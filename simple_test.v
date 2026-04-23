`timescale 1ns/1ps

module simple_test;

reg        clk;
reg        reset;
reg  [3:0] opcode;
reg  [31:0] data_in;

wire [31:0] blade_length;
wire [7:0]  blade_color;
wire [7:0]  blade_count;
wire [7:0]  error_reg;

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

initial clk = 0;
always #5 clk = ~clk;

initial begin
    $display("=== SIMPLE TEST ===");
    
    // Reset
    reset = 1;
    opcode = 4'b0000;
    data_in = 32'h0;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
    
    // Power ON
    opcode = 4'b0001;
    @(posedge clk);
    #1;
    $display("After Power ON: blade_length = %d", blade_length);
    $display("Power status: %b, Lock status: %b", DUT.power_status, DUT.lock_status);
    
    // Set length = 100
    opcode = 4'b0010;
    data_in = 32'd100;
    @(posedge clk);
    #1;
    $display("After Set Length 100: blade_length = %d, data_in = %d", blade_length, data_in);
    $display("active_dec[2] = %b", DUT.active_dec[2]);
    
    // Increment
    opcode = 4'b0011;
    data_in = 32'h0;
    @(posedge clk);
    #1;
    $display("After Increment: blade_length = %d", blade_length);
    
    // Double
    opcode = 4'b1011;
    @(posedge clk);
    #1;
    $display("After Double: blade_length = %d", blade_length);
    
    // Decrement - hold for 2 cycles
    opcode = 4'b0100;
    @(posedge clk);
    #1;
    $display("After Decrement cycle 1: blade_length = %d", blade_length);
    
    @(posedge clk);
    #1;
    $display("After Decrement cycle 2: blade_length = %d", blade_length);
    
    opcode = 4'b0000;
    @(posedge clk);
    #1;
    $display("After clear opcode: blade_length = %d", blade_length);
    
    // Set Blade Color
    opcode = 4'b0101;
    data_in = 32'd7;
    @(posedge clk);
    #1;
    $display("After Set Color 7: blade_color = %d", blade_color);
    
    // Set Blade Count
    opcode = 4'b0110;
    data_in = 32'd3;
    @(posedge clk);
    #1;
    $display("After Set Count 3: blade_count = %d", blade_count);
    
    // Turn power back on first
    opcode = 4'b0001;
    data_in = 32'h0;
    @(posedge clk);
    #1;
    $display("Power back ON: power_status = %b", DUT.power_status);
    
    // Lock System
    opcode = 4'b0111;
    data_in = 32'h0;
    @(posedge clk);
    #1;
    $display("After Lock: lock_status = %b", DUT.lock_status);
    $display("active_dec[7] = %b, lock_set_value = %b, next_lock = %b", DUT.active_dec[7], DUT.lock_set_value, DUT.next_lock);
    $display("Gating: decode[7] = %b, power_status = %b, not_lock_status = %b", DUT.decode[7], DUT.power_status, DUT.not_lock_status);
    
    // Unlock first to test toggle
    opcode = 4'b1000;
    data_in = 32'h0;
    @(posedge clk);
    #1;
    $display("After Unlock: lock_status = %b", DUT.lock_status);
    
    // Toggle Power
    opcode = 4'b1010;
    data_in = 32'h0;
    @(posedge clk);
    #1;
    $display("After Toggle Power: power_status = %b", DUT.power_status);
    
    // Turn power back on for clear length test
    opcode = 4'b0001;
    @(posedge clk);
    #1;
    $display("Power back ON: power_status = %b", DUT.power_status);
    
    // Clear Length
    opcode = 4'b1100;
    data_in = 32'h0;
    @(posedge clk);
    #1;
    $display("After Clear Length: blade_length = %d", blade_length);
    
    // Maximize Length
    opcode = 4'b1101;
    data_in = 32'h0;
    @(posedge clk);
    #1;
    $display("After Maximize Length: blade_length = %d", blade_length);
    
    // Set Error - hold for 2 cycles
    opcode = 4'b1110;
    data_in = 32'h85;  // Set error to 0x85
    @(posedge clk);
    #1;
    $display("After Set Error cycle 1: error_reg = %h", error_reg);
    
    @(posedge clk);
    #1;
    $display("After Set Error cycle 2: error_reg = %h", error_reg);
    
    // Set a known value for invert test
    opcode = 4'b0010;
    data_in = 32'd100;  // 0x00000064
    @(posedge clk);
    #1;
    $display("Set length to 100 for invert test: blade_length = %d", blade_length);
    
    // Invert Length
    opcode = 4'b1111;
    data_in = 32'h0;
    @(posedge clk);
    #1;
    $display("After Invert Length: blade_length = %d", blade_length);
    
    $display("=== TEST COMPLETE ===");
    $finish;
end

endmodule
