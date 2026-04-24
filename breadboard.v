// ============================================================
// Module: breadboard
// Project: Lightsaber Control Circuit (32-bit/8-bit Fixes)
// ============================================================
module breadboard (
    input  wire        clk,
    input  wire        reset,
    input  wire [3:0]  opcode,
    input  wire [31:0] data_in,
    output wire [31:0] blade_length,
    output wire [7:0]  blade_color,
    output wire [7:0]  blade_count,
    output wire [7:0]  error_reg,
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
wire [31:0] length_data;
wire [7:0]  color_data;
wire [7:0]  count_data;
wire [7:0]  error_data;

data_splitter ds_inst (
    .data_in    (data_in),
    .length_data(length_data),
    .color_data (color_data),
    .count_data (count_data),
    .error_data (error_data)
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
wire [2:0]  alu_op;
wire [31:0] alu_result;
wire        alu_cout, alu_bout;

// ALU_B_MUX selects B input operand
mux2to1_32bit alu_b_mux_inst (
    .sel(active_dec[11]), // 1011: Double Length
    .a  (32'd1),          // Default addition/subtraction
    .b  (blade_length),   // Double payload
    .out(alu_b_in)
);

// CTR_MUX sends control instruction to Length_ALU
mux2to1_3bit ctr_mux_inst (
    .sel(active_dec[4]),  // 0100: Dec Length (Sub)
    .a  (3'b010),         // Add
    .b  (3'b110),         // Subtract
    .out(alu_op)
);

alu32 length_alu_inst (
    .a      (blade_length),
    .b      (alu_b_in),
    .op_code(alu_op),
    .result (alu_result),
    .cout   (alu_cout),
    .bout   (alu_bout)
);

// ============================================================
// COMPONENT: Next State Multiplexers
// ============================================================
wire [31:0] next_length;
wire        next_power;
wire        next_lock;
wire [7:0]  next_error;

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

// Lock MUX
mux2to1_1bit lock_mux_inst (
    .sel(active_dec[7]),  // Lock triggers 1, Unlock does not
    .a  (1'b0),
    .b  (1'b1),
    .out(next_lock)
);

// Error MUX
mux2to1_8bit error_mux_inst (
    .sel(active_dec[9]),  // Reset op sets error to 0
    .a  (error_data),     // Default loads data_in via data_splitter
    .b  (8'd0),           // Reset payload
    .out(next_error)
);

// ============================================================
// COMPONENT: Registers
// ============================================================
register32 len_reg (.clk(clk), .reset(reset), .en(length_en), .d(next_length), .q(blade_length));
register8  col_reg (.clk(clk), .reset(reset), .en(color_en),  .d(color_data),  .q(blade_color));
register8  cnt_reg (.clk(clk), .reset(reset), .en(count_en),  .d(count_data),  .q(blade_count));
register8  err_reg (.clk(clk), .reset(reset), .en(1'b1),      .d(next_error),  .q(error_reg));
register1  pwr_reg (.clk(clk), .reset(reset), .en(power_en),  .d(next_power),  .q(power_status));
register1  lck_reg (.clk(clk), .reset(reset), .en(lock_en),   .d(next_lock),   .q(lock_status));

endmodule
