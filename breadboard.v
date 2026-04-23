// ============================================================
// Module: breadboard
// Project: Lightsaber Control Circuit
// Cohort:  Halo 2 (2004)
// Members: Giuseppe Galiazzi, Ricky Lu, Mikael Rehman,
//          Mohamed Ibrahim, Samerawit Gorfe, Faiz Aye, Said Elsaadi
// Course:  CS 4341 - Spring 2026
//
// Description:
//   Top-level structural module implementing all 16 opcodes for
//   a complete lightsaber control system. Uses 32-bit blade length
//   and 8-bit color/count/error registers.
//
// Opcode Table:
//   0000 - Power OFF           1000 - Unlock System
//   0001 - Power ON            1001 - Reset Errors
//   0010 - Set Blade Length    1010 - Toggle Power
//   0011 - Increment Length    1011 - Double Length
//   0100 - Decrement Length    1100 - Clear Length
//   0101 - Set Blade Color     1101 - Maximize Length
//   0110 - Set Blade Count     1110 - Set Error
//   0111 - Lock System         1111 - Invert Length
//
// Inputs:
//   clk        - 1-bit system clock
//   reset      - 1-bit active-high synchronous reset
//   opcode     - 4-bit command opcode
//   data_in    - 32-bit input data (for set operations)
//
// Outputs:
//   blade_length - 32-bit current blade length register
//   blade_color  - 8-bit current blade color register
//   blade_count  - 8-bit current blade count register
//   error_reg    - 8-bit accumulated error status register
// ============================================================
module breadboard (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] opcode,
    input  wire [31:0] data_in,
    output wire [31:0] blade_length,
    output wire [7:0] blade_color,
    output wire [7:0] blade_count,
    output wire [7:0] error_reg
);

// ============================================================
// INTERFACES — local wires connecting components
// ============================================================

// Decoder interface: one-hot opcode select lines
wire [15:0] decode;

// Gated decoder lines (blocked when system is off or locked)
wire [15:0] active_dec;

// Status registers
wire power_status;
wire lock_status;

// Arithmetic unit interfaces
wire [31:0] alu_result;    // Result from Length_ALU
wire        alu_carry;     // Carry/borrow from ALU

// ALU input MUX interfaces
wire [31:0] alu_b_input;   // Selected B input for ALU

// Decision Logic MUX interfaces (8 inputs for different operations)
wire [31:0] dl_in0;  // Hold current value
wire [31:0] dl_in1;  // Set Length (data_in)
wire [31:0] dl_in2;  // Increment Length (current + 1)
wire [31:0] dl_in3;  // Decrement Length (current - 1)
wire [31:0] dl_in4;  // Double Length (current + current)
wire [31:0] dl_in5;  // Clear Length (0)
wire [31:0] dl_in6;  // Maximize Length (all 1s)
wire [31:0] dl_in7;  // Invert Length (bitwise NOT)
wire [31:0] next_length;  // Output from Decision Logic MUX


// Power control interfaces
wire pwr_not_out;     // Output of Power_NOT
wire [1:0] pwr_mux_sel; // Select for Power_MUX
wire next_power;      // Output from Power_MUX

// Lock control interfaces
wire next_lock;       // Output from Lock_MUX

// Length NOT interface
wire [31:0] length_not_out;  // Bitwise NOT of current length

// Error detection and control interfaces
wire [7:0] next_error;       // Output from Error_MUX

// Gating NOT wires
wire not_power_status;
wire not_lock_status;
assign not_lock_status = ~lock_status;

// ============================================================
// COMPONENT 1: 4-to-16 DECODER (Opcode_Decoder)
// Converts 4-bit opcode to one-hot 16-bit select vector
// ============================================================
decoder4to16 opcode_decoder (
    .in  (opcode),
    .out (decode)
);

// Opcodes 0000 (power off) and 0001 (power on): always pass through
assign active_dec[0] = decode[0];   // Power OFF  — always active
assign active_dec[1] = decode[1];   // Power ON   — always active

// Opcodes 0010–0111 (operations): require power ON and NOT locked
and g_gate2 (active_dec[2], decode[2], power_status, not_lock_status); // Set Length
and g_gate3 (active_dec[3], decode[3], power_status, not_lock_status); // Inc Length
and g_gate4 (active_dec[4], decode[4], power_status, not_lock_status); // Dec Length
and g_gate5 (active_dec[5], decode[5], power_status, not_lock_status); // Set Color
and g_gate6 (active_dec[6], decode[6], power_status, not_lock_status); // Set Count
and g_gate7 (active_dec[7], decode[7], power_status, not_lock_status); // Lock

// Opcodes 1000 (unlock): require power ON only
and g_gate8 (active_dec[8], decode[8], power_status); // Unlock

// Opcode 1001 (reset error): always active
assign active_dec[9] = decode[9];

// Opcodes 1010–1111 (advanced operations): require power ON and NOT locked
and g_gate10 (active_dec[10], decode[10], power_status, not_lock_status); // Toggle Power
and g_gate11 (active_dec[11], decode[11], power_status, not_lock_status); // Double Length
and g_gate12 (active_dec[12], decode[12], power_status, not_lock_status); // Clear Length
and g_gate13 (active_dec[13], decode[13], power_status, not_lock_status); // Maximize Length
and g_gate14 (active_dec[14], decode[14], power_status, not_lock_status); // Set Error
and g_gate15 (active_dec[15], decode[15], power_status, not_lock_status); // Invert Length

// ============================================================
// COMPONENT 3: LENGTH REGISTER (32-bit)
// Stores current blade length
// ============================================================
register32 length_reg (
    .clk   (clk),
    .reset (reset),
    .d     (next_length),
    .q     (blade_length)
);

// ============================================================
// COMPONENT 4: LENGTH NOT GATE
// Provides bitwise NOT of current length for invert operation
// ============================================================
not_32bit length_not (
    .in  (blade_length),
    .out (length_not_out)
);

// ============================================================
// COMPONENT 5: ALU_B_MUX
// Selects B input for ALU operations
// sel=0: use constant 1 (for increment/decrement)
// sel=1: use current length (for double length)
// ============================================================
// Select B input for ALU: use blade_length for double, use 1 for increment/decrement
assign alu_b_input = active_dec[11] ? blade_length : 32'd1;

// ============================================================
// COMPONENT 6: LENGTH ALU (32-bit Adder/Subtractor)
// Performs arithmetic operations on blade length
// ============================================================
length_alu blade_alu (
    .a         (blade_length),
    .b         (alu_b_input),
    .subtract (active_dec[4]),  // Subtract for decrement opcode
    .result    (alu_result),
    .carry_out (alu_carry)
);

// ============================================================
// COMPONENT 7: DECISION LOGIC MUX (8-to-1, 32-bit)
// Selects next blade length based on opcode
// sel[2:0] mapping:
// 000: Hold, 001: Set, 010: Increment, 011: Decrement
// 100: Double, 101: Clear, 110: Maximize, 111: Invert
// ============================================================
assign dl_in0 = blade_length;      // Hold
assign dl_in1 = data_in;           // Set Length
assign dl_in2 = alu_result;        // Increment Length
assign dl_in3 = alu_result;        // Decrement Length
assign dl_in4 = alu_result;        // Double Length
assign dl_in5 = 32'd0;             // Clear Length
assign dl_in6 = 32'hFFFFFFFF;      // Maximize Length
assign dl_in7 = length_not_out;    // Invert Length

// Generate next length using simpler logic
assign next_length = active_dec[2]  ? data_in :           // Set Length
                     active_dec[3]  ? alu_result :      // Increment Length
                     active_dec[4]  ? alu_result :      // Decrement Length
                     active_dec[11] ? alu_result :      // Double Length
                     active_dec[12] ? 32'd0 :           // Clear Length
                     active_dec[13] ? 32'hFFFFFFFF :    // Maximize Length
                     active_dec[15] ? length_not_out :   // Invert Length
                     blade_length;                        // Default: hold current value


// ============================================================
// COMPONENT 8: POWER NOT GATE
// Provides NOT of current power status for toggle operation
// ============================================================
not power_not (pwr_not_out, power_status);

// ============================================================
// COMPONENT 9: POWER MUX (4-to-1, 1-bit)
// Selects next power state
// sel[1:0] mapping: 00: Hold, 01: OFF, 10: ON, 11: Toggle
// ============================================================
assign pwr_mux_sel[0] = active_dec[0] | active_dec[1] | active_dec[10];  // OFF, ON, Toggle
assign pwr_mux_sel[1] = active_dec[1] | active_dec[10];                   // ON, Toggle

mux4to1_1bit power_mux (
    .sel (pwr_mux_sel),
    .in0 (power_status),   // Hold
    .in1 (1'b0),           // OFF
    .in2 (1'b1),           // ON
    .in3 (pwr_not_out),    // Toggle
    .out (next_power)
);

// ============================================================
// COMPONENT 10: POWER REGISTER
// Stores current power status
// ============================================================
register1 power_reg (
    .clk   (clk),
    .reset (reset),
    .d     (next_power),
    .q     (power_status)
);

// ============================================================
// COMPONENT 11: LOCK MUX (2-to-1, 1-bit)
// Selects next lock state
// sel=0: Hold, sel=1: Set/Unlock based on specific opcodes
// ============================================================
wire lock_set_value;
assign lock_set_value = active_dec[7] ? 1'b1 : 1'b0;  // Lock=1, Unlock=0

mux2to1_1bit lock_mux (
    .sel    (active_dec[7] | active_dec[8]),  // Lock or Unlock
    .a      (lock_status),                    // Hold
    .b      (lock_set_value),                  // Set/Unlock
    .out    (next_lock)
);

// ============================================================
// COMPONENT 12: LOCK REGISTER
// Stores current lock status
// ============================================================
register1 lock_reg (
    .clk   (clk),
    .reset (reset),
    .d     (next_lock),
    .q     (lock_status)
);

// ============================================================
// COMPONENT 13: COLOR REGISTER
// Stores current blade color
// ============================================================
register8 color_reg (
    .clk   (clk),
    .reset (reset),
    .d     (data_in[7:0]),
    .q     (blade_color)
);

// ============================================================
// COMPONENT 14: COUNT REGISTER
// Stores current blade count
// ============================================================
register8 count_reg (
    .clk   (clk),
    .reset (reset),
    .d     (data_in[7:0]),
    .q     (blade_count)
);

// ============================================================
// COMPONENT 15: ERROR DETECTION LOGIC
// Detects error conditions and sets appropriate error bits
// ============================================================
wire err_power_off_cmd;     // Command while powered off
wire err_locked_cmd;        // Operation while locked
wire err_invalid_opcode;    // Invalid opcode (should never occur with proper gating)

// Error[0]: Command while powered off
wire any_op_cmd;
or g_any_op (any_op_cmd, decode[2], decode[3], decode[4], decode[5], decode[6],
             decode[7], decode[8], decode[10], decode[11], decode[12], 
             decode[13], decode[14], decode[15]);
and g_err_pwr (err_power_off_cmd, any_op_cmd, not_power_status);

// Error[1]: Operation while locked
wire any_locked_op;
or g_any_locked (any_locked_op, decode[2], decode[3], decode[4], decode[5], decode[6],
                 decode[7], decode[11], decode[12], decode[13], decode[15]);
and g_err_lck (err_locked_cmd, any_locked_op, lock_status);

// Error[4]: Invalid opcode (should not occur with proper decoder)
assign err_invalid_opcode = 1'b0;

// Assemble error bits
wire [7:0] computed_error;
assign computed_error[0] = err_power_off_cmd;
assign computed_error[1] = err_locked_cmd;
assign computed_error[2] = 1'b0;  // No underflow detection in 32-bit
assign computed_error[3] = 1'b0;  // No overflow detection in 32-bit
assign computed_error[4] = err_invalid_opcode;
assign computed_error[7:5] = 3'b000;

// Accumulate errors (OR current with new)
wire [7:0] error_accum;
assign error_accum = error_reg | computed_error;

// Final error selection: Reset, Set Error, or Accumulate
wire [7:0] final_error;
assign final_error = active_dec[9]  ? 8'd0 :           // Reset Errors
                     active_dec[14] ? data_in[7:0] :   // Set Error
                     error_accum;                     // Default: accumulate

// ============================================================
// COMPONENT 16: ERROR REGISTER
// Stores accumulated error status
// ============================================================
register8 error_reg_inst (
    .clk   (clk),
    .reset (reset),
    .d     (final_error),
    .q     (error_reg)
);

endmodule
