// ============================================================
// Module: breadboard
// Project: Lightsaber Control Circuit (32-bit architectural fix)
// ============================================================
module breadboard (
    input  wire        clk,
    input  wire        reset,
    input  wire [3:0]  opcode,
    input  wire [31:0] data_in,
    output wire [31:0] blade_length,
    output wire [31:0] blade_color,
    output wire [31:0] blade_count,
    output wire [31:0] error_reg,
    output wire        power_status,
    output wire        lock_status
);

// ============================================================
// COMPONENT: Decoder & Gating
// ============================================================
wire [15:0] decode;
wire [15:0] active_dec;
wire not_power_status;
wire not_lock_status;

decoder4to16 opcode_decoder (.in(opcode), .out(decode));

not g_not_pwr (not_power_status, power_status);
not g_not_lck (not_lock_status,  lock_status);

assign active_dec[0] = decode[0];   // Power OFF
assign active_dec[1] = decode[1];   // Power ON
and g_gate2  (active_dec[2],  decode[2],  power_status, not_lock_status); // Set Length
and g_gate3  (active_dec[3],  decode[3],  power_status, not_lock_status); // Inc Length
and g_gate4  (active_dec[4],  decode[4],  power_status, not_lock_status); // Dec Length
and g_gate5  (active_dec[5],  decode[5],  power_status, not_lock_status); // Set Color
and g_gate6  (active_dec[6],  decode[6],  power_status, not_lock_status); // Set Count
and g_gate7  (active_dec[7],  decode[7],  power_status);                  // Lock
and g_gate8  (active_dec[8],  decode[8],  power_status);                  // Unlock
assign active_dec[9]  = decode[9];                                        // Reset Error
assign active_dec[10] = decode[10];                                       // Toggle Power
and g_gate11 (active_dec[11], decode[11], power_status, not_lock_status); // Double Length
assign active_dec[15:12] = decode[15:12];                                 // Reserved

// ============================================================
// COMPONENT: Bus Splitters
// ============================================================
wire [31:0] length_data, color_data, count_data;
data_splitter ds_inst (
    .data_in    (data_in),
    .length_data(length_data),
    .color_data (color_data),
    .count_data (count_data)
);

wire [2:0] len_mux_sel;
wire [1:0] pwr_mux_sel;
mux_sel_splitter mss_inst (
    .opcode          (opcode),
    .decision_mux_sel(len_mux_sel),
    .power_mux_sel   (pwr_mux_sel)
);

// ============================================================
// COMPONENT: Structural Enablers
// ============================================================
wire length_en, power_en, lock_en, color_en, count_en;

// Length Enable: Ops 2, 3, 4, 11
or4 length_en_or (.i0(active_dec[2]), .i1(active_dec[3]), .i2(active_dec[4]), .i3(active_dec[11]), .out(length_en));

// Power Enable: Ops 0, 1, 10
or3 power_en_or (.i0(active_dec[0]), .i1(active_dec[1]), .i2(active_dec[10]), .out(power_en));

// Lock Enable: Ops 7, 8
or2 lock_en_or (.i0(active_dec[7]), .i1(active_dec[8]), .out(lock_en));

// Simple passing enablers for remaining regs
assign color_en = active_dec[5];
assign count_en = active_dec[6];

// ============================================================
// COMPONENT: Arithmetic Logic Unit
// ============================================================
wire [31:0] alu_b_in;
wire [31:0] alu_result;
wire        alu_cout, alu_bout;

// CTR MUX selects B input operand
mux2to1_32bit ctr_mux_inst (
    .sel(active_dec[11]), // 1011: Double Length
    .a  (32'd1),
    .b  (blade_length),
    .out(alu_b_in)
);

alu32 length_alu_inst (
    .a     (blade_length),
    .b     (alu_b_in),
    .sub   (active_dec[4]), // 0100: Dec Length is subtract
    .result(alu_result),
    .cout  (alu_cout),
    .bout  (alu_bout)
);

// ============================================================
// COMPONENT: Next State Multiplexers
// ============================================================
wire [31:0] next_length;
wire        next_power;
wire [31:0] next_error;

// Length Decision MUX
mux8to1_32bit decision_mux_inst (
    .sel(len_mux_sel),
    .i0(32'd0),
    .i1(32'd0),
    .i2(length_data), // Set
    .i3(alu_result),  // Inc / Double
    .i4(alu_result),  // Dec
    .i5(32'd0),
    .i6(32'd0),
    .i7(32'd0),
    .out(next_length)
);

// Power MUX
mux4to1_1bit power_mux_inst (
    .sel(pwr_mux_sel),
    .i0(1'b0),             // OFF
    .i1(1'b1),             // ON
    .i2(not_power_status), // Toggle
    .i3(1'b0),
    .out(next_power)
);

// ============================================================
// COMPONENT: Error State Logic
// ============================================================
wire err_length_overflow, err_length_underflow;
wire err_invalid_opcode, err_power_off_cmd, err_locked_cmd;
wire [31:0] computed_error;
wire [31:0] error_accum;

wire is_add;
or2 g_is_add (.i0(active_dec[3]), .i1(active_dec[11]), .out(is_add));
and g_err_ovf (err_length_overflow, is_add, alu_cout);
and g_err_udf (err_length_underflow, active_dec[4], alu_bout);

// Use structural or4 for invalid opcode combination
or4 g_err_inv (.i0(decode[12]), .i1(decode[13]), .i2(decode[14]), .i3(decode[15]), .out(err_invalid_opcode));

// Use structural or7 to group basic operations for power check
wire op_group1, any_op_cmd;
or7 g_ops (.i0(decode[2]), .i1(decode[3]), .i2(decode[4]), .i3(decode[5]), .i4(decode[6]), .i5(decode[7]), .i6(decode[8]), .out(op_group1));
or g_any_pwr_off (any_op_cmd, op_group1, decode[9], decode[11], err_invalid_opcode);
and g_err_pwr (err_power_off_cmd, any_op_cmd, not_power_status);

wire any_blocked_op;
or g_blocked_op (any_blocked_op, decode[2], decode[3], decode[4], decode[5], decode[6], decode[11]);
and g_err_lck (err_locked_cmd, any_blocked_op, lock_status);

assign computed_error[0] = err_power_off_cmd;
assign computed_error[1] = err_locked_cmd;
assign computed_error[2] = err_length_underflow;
assign computed_error[3] = err_length_overflow;
assign computed_error[4] = err_invalid_opcode;
assign computed_error[31:5] = 27'b0;

or g_acc0 (error_accum[0], error_reg[0], computed_error[0]);
or g_acc1 (error_accum[1], error_reg[1], computed_error[1]);
or g_acc2 (error_accum[2], error_reg[2], computed_error[2]);
or g_acc3 (error_accum[3], error_reg[3], computed_error[3]);
or g_acc4 (error_accum[4], error_reg[4], computed_error[4]);
assign error_accum[31:5] = 27'b0;

mux2to1_32bit err_reset_mux (
    .sel(active_dec[9]),
    .a  (error_accum),
    .b  (32'd0),
    .out(next_error)
);

// ============================================================
// COMPONENT: Registers
// ============================================================
// Error register accumulates continuously (en = 1'b1)
register32 len_reg (.clk(clk), .reset(reset), .en(length_en), .d(next_length),   .q(blade_length));
register32 col_reg (.clk(clk), .reset(reset), .en(color_en),  .d(color_data),    .q(blade_color));
register32 cnt_reg (.clk(clk), .reset(reset), .en(count_en),  .d(count_data),    .q(blade_count));
register32 err_reg (.clk(clk), .reset(reset), .en(1'b1),      .d(next_error),    .q(error_reg));
register1  pwr_reg (.clk(clk), .reset(reset), .en(power_en),  .d(next_power),    .q(power_status));
register1  lck_reg (.clk(clk), .reset(reset), .en(lock_en),   .d(active_dec[7]), .q(lock_status));

endmodule
