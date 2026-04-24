`timescale 1ns/1ps

module stimulus;

// ─── Inputs ───────────────────────────────────────────
reg [3:0] opcode;
reg [31:0] data_in;
reg clk;
reg reset;

// ─── Outputs ──────────────────────────────────────────
wire [31:0] blade_length;
wire [7:0] blade_color;
wire [7:0] blade_count;
wire [7:0] error_reg;
wire power_status;
wire lock_status;

// ─── Instantiate Breadboard ───────────────────────────
breadboard uut(
    .opcode(opcode),
    .data_in(data_in),
    .clk(clk),
    .reset(reset),
    .blade_length(blade_length),
    .blade_color(blade_color),
    .blade_count(blade_count),
    .error_reg(error_reg),
    .power_status(power_status),
    .lock_status(lock_status)
);

// ─── Clock Generation ─────────────────────────────────
initial clk = 0;
always #5 clk = ~clk;

// ─── Task: Apply Opcode ───────────────────────────────
task apply_op;
    input [3:0] op;
    input [31:0] din;
    begin
        opcode = op;
        data_in = din;
        @(posedge clk);
        #1;
    end
endtask

// ─── Stimulus ─────────────────────────────────────────
initial begin
    // Initialize
    reset = 1;
    opcode = 4'b0000;
    data_in = 32'd0;
    @(posedge clk);
    #1;
    reset = 0;

    $display("=== LIGHTSABER CONTROL SYSTEM TEST ===");
    $display("Time | Opcode | Data_in | blade_length | blade_color | blade_count | error_reg | power | lock");

    // 0000 - Power OFF (verify starts off)
    apply_op(4'b0000, 32'd0);
    $display("%0t | 0000 Power OFF      | power_status=%b", $time, power_status);

    // 0001 - Power ON
    apply_op(4'b0001, 32'd0);
    $display("%0t | 0001 Power ON       | power_status=%b", $time, power_status);

    // 0010 - Set Blade Length to 100
    apply_op(4'b0010, 32'd100);
    $display("%0t | 0010 Set Length     | blade_length=%0d", $time, blade_length);

    // 0011 - Increment Length
    apply_op(4'b0011, 32'd0);
    $display("%0t | 0011 Increment      | blade_length=%0d", $time, blade_length);

    // 0011 - Increment Again
    apply_op(4'b0011, 32'd0);
    $display("%0t | 0011 Increment      | blade_length=%0d", $time, blade_length);

    // 0100 - Decrement Length
    apply_op(4'b0100, 32'd0);
    $display("%0t | 0100 Decrement      | blade_length=%0d", $time, blade_length);

    // 0101 - Set Blade Color to 5
    apply_op(4'b0101, 32'd5);
    $display("%0t | 0101 Set Color      | blade_color=%0d", $time, blade_color);

    // 0110 - Set Blade Count to 3
    apply_op(4'b0110, 32'd3);
    $display("%0t | 0110 Set Count      | blade_count=%0d", $time, blade_count);

    // 0111 - Lock System
    apply_op(4'b0111, 32'd0);
    $display("%0t | 0111 Lock           | lock_status=%b", $time, lock_status);

    // 1000 - Unlock System
    apply_op(4'b1000, 32'd0);
    $display("%0t | 1000 Unlock         | lock_status=%b", $time, lock_status);

    // 1001 - Reset Errors
    apply_op(4'b1001, 32'd0);
    $display("%0t | 1001 Reset Errors   | error_reg=%0d", $time, error_reg);

    // 1010 - Toggle Power
    apply_op(4'b1010, 32'd0);
    $display("%0t | 1010 Toggle Power   | power_status=%b", $time, power_status);

    // 1010 - Toggle Power again
    apply_op(4'b1010, 32'd0);
    $display("%0t | 1010 Toggle Power   | power_status=%b", $time, power_status);

    // 1011 - Double Length
    apply_op(4'b0010, 32'd4);
    $display("%0t | 0010 Set Length=4   | blade_length=%0d", $time, blade_length);
    apply_op(4'b1011, 32'd0);
    $display("%0t | 1011 Double Length  | blade_length=%0d", $time, blade_length);

    // 1100 - Clear Length
    apply_op(4'b1100, 32'd0);
    $display("%0t | 1100 Clear Length   | blade_length=%0d", $time, blade_length);

    // 1101 - Maximize Length
    apply_op(4'b1101, 32'd0);
    $display("%0t | 1101 Maximize       | blade_length=%h", $time, blade_length);

    // 1110 - Set Error
    apply_op(4'b1110, 32'd7);
    $display("%0t | 1110 Set Error      | error_reg=%0d", $time, error_reg);

    // 1001 - Reset Errors
    apply_op(4'b1001, 32'd0);
    $display("%0t | 1001 Reset Errors   | error_reg=%0d", $time, error_reg);

    // 1111 - Invert Length
    apply_op(4'b0010, 32'd15);
    $display("%0t | 0010 Set Length=15  | blade_length=%0d", $time, blade_length);
    apply_op(4'b1111, 32'd0);
    $display("%0t | 1111 Invert Length  | blade_length=%h", $time, blade_length);

    // Final - Power OFF
    apply_op(4'b0000, 32'd0);
    $display("%0t | 0000 Power OFF      | power_status=%b", $time, power_status);

    $display("=== TEST COMPLETE ===");
    $finish;
end

endmodule