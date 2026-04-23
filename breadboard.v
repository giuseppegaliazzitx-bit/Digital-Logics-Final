// ============================================================
// Module: breadboard
// Project: Lightsaber Control Circuit
// Cohort:  Halo 2 (2004)
// Members: Giuseppe Galiazzi, Ricky Lu, Mikael Rehman,
//          Mohamed Ibrahim, Samerawet Gorfe, Faiz Aye, Said Elsaadi
// Course:  CS 4341 - Spring 2026
//
// Description:
//   Top-level structural module. Connects all components
//   (decoder, adders, subtractors, MUXes, registers) to
//   implement a clock-driven lightsaber control system.
//   On each rising clock edge the system decodes a 4-bit opcode
//   and updates internal state registers accordingly.
//
// Opcode Table:
//   0000 - Power OFF            8 - Unlock system
//   0001 - Power ON             9 - Reset error register
//   0010 - Set blade length     A-F - Reserved (invalid)
//   0011 - Increment length
//   0100 - Decrement length
//   0101 - Set blade color
//   0110 - Set blade count
//   0111 - Lock system
//
// Inputs:
//   clk        - 1-bit system clock
//   reset      - 1-bit active-high synchronous reset
//   opcode     - 4-bit command opcode
//   data_in    - 8-bit input data (for set operations)
//
// Outputs:
//   blade_length - 8-bit current blade length register
//   blade_color  - 8-bit current blade color register
//   blade_count  - 8-bit current blade count register
//   error_reg    - 8-bit accumulated error status register
//   power_status - 1-bit system power state
//   lock_status  - 1-bit system lock state
// ============================================================
module breadboard (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] opcode,
    input  wire [7:0] data_in,
    output wire [7:0] blade_length,
    output wire [7:0] blade_color,
    output wire [7:0] blade_count,
    output wire [7:0] error_reg,
    output wire       power_status,
    output wire       lock_status
);

// ============================================================
// INTERFACES — local wires connecting components
// ============================================================

// Decoder interface: one-hot opcode select lines
wire [15:0] decode;

// Gated decoder lines (blocked when system is off or locked)
wire [15:0] active_dec;

// Arithmetic unit interfaces
wire [7:0] inc_length;   // blade_length + 1 (from adder)
wire [7:0] dec_length;   // blade_length - 1 (from subtractor)
wire       inc_cout;     // carry out of increment (overflow flag)
wire       dec_bout;     // borrow out of decrement (underflow flag)

// MUX chain output interfaces (next register values)
wire [7:0] next_length;
wire [7:0] next_color;
wire [7:0] next_count;
wire       next_power;
wire       next_lock;
wire [7:0] next_error;

// Intermediate MUX chain wires — blade length
wire [7:0] len_mux_set;  // after Set Length MUX
wire [7:0] len_mux_inc;  // after Increment MUX

// Intermediate MUX chain wires — power and lock
wire pwr_mux_off;        // after Power OFF MUX
wire lck_mux_on;         // after Lock MUX

// Error detection wires
wire err_length_overflow;   // error[3]: inc while at max
wire err_length_underflow;  // error[2]: dec while at zero
wire err_invalid_opcode;    // error[4]: opcode >= 1010
wire err_power_off_cmd;     // error[0]: command while powered off
wire err_locked_cmd;        // error[1]: op command while locked

wire [7:0] computed_error;  // newly detected errors this cycle
wire [7:0] error_accum;     // current errors OR new errors

// Gating NOT wires (for structural AND gates)
wire not_power_status;
wire not_lock_status;

// OR wires for error detection grouping
wire any_op_cmd;            // decode[2..9]: any operation opcode
wire any_blocked_op;        // decode[2..6]: ops blocked by lock
wire inv_op_a, inv_op_b;    // intermediate OR for invalid opcode

// ============================================================
// COMPONENT 1: 4-to-16 DECODER
// Converts 4-bit opcode to one-hot 16-bit select vector
// ============================================================
decoder4to16 opcode_decoder (
    .in  (opcode),
    .out (decode)
);

// ============================================================
// COMPONENT 2: POWER / LOCK GATING LOGIC
// Gates each decoder line so commands are blocked when the
// system is powered off or locked (structural NOT + AND gates)
// ============================================================
not g_not_pwr (not_power_status, power_status);
not g_not_lck (not_lock_status,  lock_status);

// Opcodes 0000 (power off) and 0001 (power on): always pass through
assign active_dec[0] = decode[0];   // Power OFF  — always active
assign active_dec[1] = decode[1];   // Power ON   — always active

// Opcodes 0010–0110 (operations): require power ON and NOT locked
and g_gate2 (active_dec[2], decode[2], power_status, not_lock_status); // Set Length
and g_gate3 (active_dec[3], decode[3], power_status, not_lock_status); // Inc Length
and g_gate4 (active_dec[4], decode[4], power_status, not_lock_status); // Dec Length
and g_gate5 (active_dec[5], decode[5], power_status, not_lock_status); // Set Color
and g_gate6 (active_dec[6], decode[6], power_status, not_lock_status); // Set Count

// Opcodes 0111–1000 (lock/unlock): require power ON only
and g_gate7 (active_dec[7], decode[7], power_status); // Lock
and g_gate8 (active_dec[8], decode[8], power_status); // Unlock

// Opcode 1001 (reset error): always active
assign active_dec[9] = decode[9];

// Reserved opcodes 1010–1111: pass through for error detection
assign active_dec[15:10] = decode[15:10];

// ============================================================
// COMPONENT 3: 8-BIT ADDER — blade length increment
// Computes blade_length + 1 each cycle (result used if op=0011)
// ============================================================
adder8 length_incrementer (
    .a   (blade_length),
    .b   (8'd1),
    .cin (1'b0),
    .sum (inc_length),
    .cout(inc_cout)
);

// ============================================================
// COMPONENT 4: 8-BIT SUBTRACTOR — blade length decrement
// Computes blade_length - 1 each cycle (result used if op=0100)
// ============================================================
subtractor8 length_decrementer (
    .a   (blade_length),
    .b   (8'd1),
    .diff(dec_length),
    .bout(dec_bout)
);

// ============================================================
// COMPONENT 5: BLADE LENGTH MUX CHAIN
// Selects the next blade_length value from:
//   Hold (default) → Set (0010) → Increment (0011) → Decrement (0100)
// Since opcodes are mutually exclusive (one-hot decoder),
// only one MUX stage fires per cycle.
// ============================================================
mux2to1_8bit len_mux_set_inst (
    .sel(active_dec[2]),  // opcode 0010: Set Length
    .a  (blade_length),   // hold current if not selected
    .b  (data_in),        // load from data_in if selected
    .out(len_mux_set)
);
mux2to1_8bit len_mux_inc_inst (
    .sel(active_dec[3]),  // opcode 0011: Increment Length
    .a  (len_mux_set),    // previous MUX result
    .b  (inc_length),     // use incremented value if selected
    .out(len_mux_inc)
);
mux2to1_8bit len_mux_dec_inst (
    .sel(active_dec[4]),  // opcode 0100: Decrement Length
    .a  (len_mux_inc),    // previous MUX result
    .b  (dec_length),     // use decremented value if selected
    .out(next_length)
);

// ============================================================
// COMPONENT 6: BLADE COLOR MUX
// Selects next blade_color value:
//   Hold (default) → Set Color (0101)
// ============================================================
mux2to1_8bit color_mux (
    .sel(active_dec[5]),  // opcode 0101: Set Color
    .a  (blade_color),
    .b  (data_in),
    .out(next_color)
);

// ============================================================
// COMPONENT 7: BLADE COUNT MUX
// Selects next blade_count value:
//   Hold (default) → Set Count (0110)
// ============================================================
mux2to1_8bit count_mux (
    .sel(active_dec[6]),  // opcode 0110: Set Count
    .a  (blade_count),
    .b  (data_in),
    .out(next_count)
);

// ============================================================
// COMPONENT 8: POWER STATUS MUX CHAIN
// Hold → Power OFF (0000) → Power ON (0001)
// ============================================================
mux2to1_1bit pwr_off_mux (
    .sel(active_dec[0]),  // opcode 0000: Power OFF
    .a  (power_status),
    .b  (1'b0),           // set to 0 (off)
    .out(pwr_mux_off)
);
mux2to1_1bit pwr_on_mux (
    .sel(active_dec[1]),  // opcode 0001: Power ON
    .a  (pwr_mux_off),
    .b  (1'b1),           // set to 1 (on)
    .out(next_power)
);

// ============================================================
// COMPONENT 9: LOCK STATUS MUX CHAIN
// Hold → Lock (0111) → Unlock (1000)
// ============================================================
mux2to1_1bit lock_mux (
    .sel(active_dec[7]),  // opcode 0111: Lock
    .a  (lock_status),
    .b  (1'b1),           // set to 1 (locked)
    .out(lck_mux_on)
);
mux2to1_1bit unlock_mux (
    .sel(active_dec[8]),  // opcode 1000: Unlock
    .a  (lck_mux_on),
    .b  (1'b0),           // set to 0 (unlocked)
    .out(next_lock)
);

// ============================================================
// COMPONENT 10: ERROR DETECTION LOGIC (structural gates)
// Detects error conditions and sets the appropriate error bits.
//
// Error register bit map:
//   error_reg[0] — Command received while system is powered off
//   error_reg[1] — Operation attempted while system is locked
//   error_reg[2] — Length decrement underflow (already at 0)
//   error_reg[3] — Length increment overflow  (already at 255)
//   error_reg[4] — Invalid opcode (1010–1111)
//   error_reg[7:5] — Reserved (always 0)
// ============================================================

// Error[3]: Overflow — increment active AND carry out is high
and g_err_ovf  (err_length_overflow,  active_dec[3], inc_cout);

// Error[2]: Underflow — decrement active AND borrow out is high
and g_err_udf  (err_length_underflow, active_dec[4], dec_bout);

// Error[4]: Invalid opcode — any reserved opcode (1010–1111)
or  g_err_inv_a (inv_op_a, decode[10], decode[11], decode[12]);
or  g_err_inv_b (inv_op_b, decode[13], decode[14], decode[15]);
or  g_err_inv   (err_invalid_opcode, inv_op_a, inv_op_b);

// Error[0]: Command while powered off
// Triggered by opcodes 0010-1111 while powered off.
// Power ON (0001) and Power OFF (0000) are exempt — always allowed.
or  g_any_op (any_op_cmd, decode[2], decode[3],
              decode[4], decode[5], decode[6], decode[7],
              decode[8], decode[9], inv_op_a, inv_op_b);
and g_err_pwr (err_power_off_cmd, any_op_cmd, not_power_status);

// Error[1]: Operation while locked
// Triggered if an operation opcode (0010–0110) arrives while locked
or  g_blocked_op (any_blocked_op, decode[2], decode[3],
                  decode[4], decode[5], decode[6]);
and g_err_lck (err_locked_cmd, any_blocked_op, lock_status);

// Assemble computed_error byte from individual flags
assign computed_error[0] = err_power_off_cmd;
assign computed_error[1] = err_locked_cmd;
assign computed_error[2] = err_length_underflow;
assign computed_error[3] = err_length_overflow;
assign computed_error[4] = err_invalid_opcode;
assign computed_error[7:5] = 3'b000;

// Accumulate: OR current stored errors with newly detected errors
// (errors stay set until explicitly cleared with opcode 1001)
or g_acc0 (error_accum[0], error_reg[0], computed_error[0]);
or g_acc1 (error_accum[1], error_reg[1], computed_error[1]);
or g_acc2 (error_accum[2], error_reg[2], computed_error[2]);
or g_acc3 (error_accum[3], error_reg[3], computed_error[3]);
or g_acc4 (error_accum[4], error_reg[4], computed_error[4]);
assign error_accum[7:5] = 3'b000;

// Error Reset MUX: opcode 1001 clears error_reg to 0
mux2to1_8bit err_reset_mux (
    .sel(active_dec[9]),  // opcode 1001: Reset Error
    .a  (error_accum),    // hold/accumulate errors
    .b  (8'd0),           // clear all errors
    .out(next_error)
);

// ============================================================
// COMPONENT 11: STATE REGISTERS
// All registers are clocked on the rising edge of clk.
// Synchronous reset drives all registers to 0.
// ============================================================
register8  len_reg  (.clk(clk), .reset(reset), .d(next_length), .q(blade_length));
register8  col_reg  (.clk(clk), .reset(reset), .d(next_color),  .q(blade_color));
register8  cnt_reg  (.clk(clk), .reset(reset), .d(next_count),  .q(blade_count));
register8  err_reg  (.clk(clk), .reset(reset), .d(next_error),  .q(error_reg));
register1  pwr_reg  (.clk(clk), .reset(reset), .d(next_power),  .q(power_status));
register1  lck_reg  (.clk(clk), .reset(reset), .d(next_lock),   .q(lock_status));

endmodule
