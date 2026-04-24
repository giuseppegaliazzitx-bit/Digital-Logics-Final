module breadboard(
    input [3:0] opcode,
    input [31:0] data_in,
    input clk,
    input reset,
    output [31:0] blade_length,
    output [7:0] blade_color,
    output [7:0] blade_count,
    output [7:0] error_reg,
    output power_status,
    output lock_status
);

// ─── Internal Wires ───────────────────────────────────────────

wire [15:0] dec_out;
wire [31:0] alu_out;
wire [31:0] alu_b;
wire [2:0] ctr;
wire alu_carry;
wire mux_sel_bit0;
wire mux_sel_bit1;
wire [2:0] mux_sel;
wire [31:0] mux_to_length;
wire [31:0] length_feedback;
wire [31:0] length_not_out;
wire power_not_out;
wire [1:0] power_mux_sel;
wire power_mux_out;
wire power_feedback;
wire power_enable;
wire lock_mux_out;
wire lock_enable;
wire lock_out;
wire [7:0] error_mux_out;
wire error_enable;
wire length_enable;
wire [7:0] splitter_out;

// ─── CONSTANT WIRES ───────────────────────────────────────────

// CONST_1_32bit
wire [31:0] const_1_32bit;
buf const1_32_buf0  (const_1_32bit[0],  1'b1);
buf const1_32_buf1  (const_1_32bit[1],  1'b0);
buf const1_32_buf2  (const_1_32bit[2],  1'b0);
buf const1_32_buf3  (const_1_32bit[3],  1'b0);
buf const1_32_buf4  (const_1_32bit[4],  1'b0);
buf const1_32_buf5  (const_1_32bit[5],  1'b0);
buf const1_32_buf6  (const_1_32bit[6],  1'b0);
buf const1_32_buf7  (const_1_32bit[7],  1'b0);
buf const1_32_buf8  (const_1_32bit[8],  1'b0);
buf const1_32_buf9  (const_1_32bit[9],  1'b0);
buf const1_32_buf10 (const_1_32bit[10], 1'b0);
buf const1_32_buf11 (const_1_32bit[11], 1'b0);
buf const1_32_buf12 (const_1_32bit[12], 1'b0);
buf const1_32_buf13 (const_1_32bit[13], 1'b0);
buf const1_32_buf14 (const_1_32bit[14], 1'b0);
buf const1_32_buf15 (const_1_32bit[15], 1'b0);
buf const1_32_buf16 (const_1_32bit[16], 1'b0);
buf const1_32_buf17 (const_1_32bit[17], 1'b0);
buf const1_32_buf18 (const_1_32bit[18], 1'b0);
buf const1_32_buf19 (const_1_32bit[19], 1'b0);
buf const1_32_buf20 (const_1_32bit[20], 1'b0);
buf const1_32_buf21 (const_1_32bit[21], 1'b0);
buf const1_32_buf22 (const_1_32bit[22], 1'b0);
buf const1_32_buf23 (const_1_32bit[23], 1'b0);
buf const1_32_buf24 (const_1_32bit[24], 1'b0);
buf const1_32_buf25 (const_1_32bit[25], 1'b0);
buf const1_32_buf26 (const_1_32bit[26], 1'b0);
buf const1_32_buf27 (const_1_32bit[27], 1'b0);
buf const1_32_buf28 (const_1_32bit[28], 1'b0);
buf const1_32_buf29 (const_1_32bit[29], 1'b0);
buf const1_32_buf30 (const_1_32bit[30], 1'b0);
buf const1_32_buf31 (const_1_32bit[31], 1'b0);

// CONST_0_32bit
wire [31:0] const_0_32bit;
genvar j;
generate
    for (j = 0; j < 32; j = j + 1) begin : const0_32_array
        buf const0_32_buf (const_0_32bit[j], 1'b0);
    end
endgenerate

// CONST_MAX_32bit (all 1s)
wire [31:0] const_max_32bit;
generate
    for (j = 0; j < 32; j = j + 1) begin : const_max_array
        buf const_max_buf (const_max_32bit[j], 1'b1);
    end
endgenerate

// CONST_ADD_CTR (010)
wire [2:0] const_add_ctr;
buf add_ctr_buf0 (const_add_ctr[0], 1'b0);
buf add_ctr_buf1 (const_add_ctr[1], 1'b1);
buf add_ctr_buf2 (const_add_ctr[2], 1'b0);

// CONST_SUB_CTR (110)
wire [2:0] const_sub_ctr;
buf sub_ctr_buf0 (const_sub_ctr[0], 1'b0);
buf sub_ctr_buf1 (const_sub_ctr[1], 1'b1);
buf sub_ctr_buf2 (const_sub_ctr[2], 1'b1);

// CONST_0_8bit
wire [7:0] const_0_8bit;
generate
    for (j = 0; j < 8; j = j + 1) begin : const0_8_array
        buf const0_8_buf (const_0_8bit[j], 1'b0);
    end
endgenerate

// ─── DATA SPLITTER ────────────────────────────────────────────

buf splitter [7:0] (splitter_out, data_in[7:0]);

// ─── OPCODE DECODER ──────────────────────────────────────────

decoder4to16 opcode_decoder(
    .in(opcode),
    .out(dec_out)
);

// ─── LENGTH ENABLE OR (7-input) ───────────────────────────────

wire [6:0] length_en_in;
buf len_en_buf0 (length_en_in[0], dec_out[2]);
buf len_en_buf1 (length_en_in[1], dec_out[3]);
buf len_en_buf2 (length_en_in[2], dec_out[4]);
buf len_en_buf3 (length_en_in[3], dec_out[11]);
buf len_en_buf4 (length_en_in[4], dec_out[12]);
buf len_en_buf5 (length_en_in[5], dec_out[13]);
buf len_en_buf6 (length_en_in[6], dec_out[15]);

or_gate #(7) length_enable_or(
    .in(length_en_in),
    .out(length_enable)
);

// ─── MUX SELECTOR LOGIC ───────────────────────────────────────

wire [3:0] mux_sel_bit0_in;
buf mux_sel0_buf0 (mux_sel_bit0_in[0], dec_out[3]);
buf mux_sel0_buf1 (mux_sel_bit0_in[1], dec_out[4]);
buf mux_sel0_buf2 (mux_sel_bit0_in[2], dec_out[11]);
buf mux_sel0_buf3 (mux_sel_bit0_in[3], dec_out[13]);

or_gate #(4) mux_sel_bit0_or(
    .in(mux_sel_bit0_in),
    .out(mux_sel_bit0)
);

wire [1:0] mux_sel_bit1_in;
buf mux_sel1_buf0 (mux_sel_bit1_in[0], dec_out[12]);
buf mux_sel1_buf1 (mux_sel_bit1_in[1], dec_out[13]);

or_gate #(2) mux_sel_bit1_or(
    .in(mux_sel_bit1_in),
    .out(mux_sel_bit1)
);

buf mux_sel_buf0 (mux_sel[0], mux_sel_bit0);
buf mux_sel_buf1 (mux_sel[1], mux_sel_bit1);
buf mux_sel_buf2 (mux_sel[2], dec_out[15]);

// ─── ALU B MUX ────────────────────────────────────────────────

mux2to1 #(32) alu_b_mux(
    .in0(const_1_32bit),
    .in1(length_feedback),
    .sel(dec_out[11]),
    .out(alu_b)
);

// ─── CTR MUX ──────────────────────────────────────────────────

mux2to1 #(3) ctr_mux(
    .in0(const_add_ctr),
    .in1(const_sub_ctr),
    .sel(dec_out[4]),
    .out(ctr)
);

// ─── LENGTH ALU ───────────────────────────────────────────────

alu32 length_alu(
    .a(length_feedback),
    .b(alu_b),
    .ctr(ctr),
    .ans(alu_out),
    .carry(alu_carry)
);

// ─── LENGTH NOT ───────────────────────────────────────────────

not_gate #(32) length_not(
    .in(length_feedback),
    .out(length_not_out)
);

// ─── DECISION LOGIC MUX ───────────────────────────────────────

wire [31:0] unused_in5, unused_in6, unused_in7;
generate
    for (j = 0; j < 32; j = j + 1) begin : unused_array
        buf unused_buf5 (unused_in5[j], 1'b0);
        buf unused_buf6 (unused_in6[j], 1'b0);
        buf unused_buf7 (unused_in7[j], 1'b0);
    end
endgenerate

mux8to1 #(32) decision_logic_mux(
    .in0(data_in),
    .in1(alu_out),
    .in2(const_0_32bit),
    .in3(const_max_32bit),
    .in4(length_not_out),
    .in5(unused_in5),
    .in6(unused_in6),
    .in7(unused_in7),
    .sel(mux_sel),
    .out(mux_to_length)
);

// ─── LENGTH REGISTER ──────────────────────────────────────────

dff #(32) length_register(
    .clk(clk),
    .reset(reset),
    .en(length_enable),
    .d(mux_to_length),
    .q(length_feedback)
);

buf blade_length_buf [31:0] (blade_length, length_feedback);

// ─── COLOR REGISTER ───────────────────────────────────────────

dff #(8) color_register(
    .clk(clk),
    .reset(reset),
    .en(dec_out[5]),
    .d(splitter_out),
    .q(blade_color)
);

// ─── COUNT REGISTER ───────────────────────────────────────────

dff #(8) count_register(
    .clk(clk),
    .reset(reset),
    .en(dec_out[6]),
    .d(splitter_out),
    .q(blade_count)
);

// ─── ERROR MUX ────────────────────────────────────────────────

mux2to1 #(8) error_mux(
    .in0(const_0_8bit),
    .in1(splitter_out),
    .sel(dec_out[14]),
    .out(error_mux_out)
);

// ─── ERROR ENABLE OR (2-input) ────────────────────────────────

wire [1:0] error_en_in;
buf err_en_buf0 (error_en_in[0], dec_out[9]);
buf err_en_buf1 (error_en_in[1], dec_out[14]);

or_gate #(2) error_enable_or(
    .in(error_en_in),
    .out(error_enable)
);

// ─── ERROR REGISTER ───────────────────────────────────────────

dff #(8) error_register(
    .clk(clk),
    .reset(reset),
    .en(error_enable),
    .d(error_mux_out),
    .q(error_reg)
);

// ─── POWER NOT ────────────────────────────────────────────────

not_gate #(1) power_not(
    .in(power_feedback),
    .out(power_not_out)
);

// ─── POWER MUX SELECTOR SPLITTER ─────────────────────────────

buf power_mux_sel_buf0 (power_mux_sel[0], dec_out[1]);
buf power_mux_sel_buf1 (power_mux_sel[1], dec_out[10]);

// ─── POWER CONSTANTS ─────────────────────────────────────────

wire const_0_1bit;
wire const_1_1bit;
buf power_const0_buf (const_0_1bit, 1'b0);
buf power_const1_buf (const_1_1bit, 1'b1);

// ─── POWER MUX ────────────────────────────────────────────────

mux4to1 #(1) power_mux(
    .in0(const_0_1bit),
    .in1(const_1_1bit),
    .in2(power_not_out),
    .in3(const_0_1bit),
    .sel(power_mux_sel),
    .out(power_mux_out)
);

// ─── POWER ENABLE OR (3-input) ────────────────────────────────

wire [2:0] power_en_in;
buf pwr_en_buf0 (power_en_in[0], dec_out[0]);
buf pwr_en_buf1 (power_en_in[1], dec_out[1]);
buf pwr_en_buf2 (power_en_in[2], dec_out[10]);

or_gate #(3) power_enable_or(
    .in(power_en_in),
    .out(power_enable)
);

// ─── POWER REGISTER ───────────────────────────────────────────

dff #(1) power_register(
    .clk(clk),
    .reset(reset),
    .en(power_enable),
    .d(power_mux_out),
    .q(power_feedback)
);

buf power_status_buf (power_status, power_feedback);

// ─── LOCK CONSTANTS ──────────────────────────────────────────

wire const_0_1bit_lock;
wire const_1_1bit_lock;
buf lock_const0_buf (const_0_1bit_lock, 1'b0);
buf lock_const1_buf (const_1_1bit_lock, 1'b1);

// ─── LOCK MUX ─────────────────────────────────────────────────

mux2to1 #(1) lock_mux(
    .in0(const_0_1bit_lock),
    .in1(const_1_1bit_lock),
    .sel(dec_out[7]),
    .out(lock_mux_out)
);

// ─── LOCK ENABLE OR (2-input) ─────────────────────────────────

wire [1:0] lock_en_in;
buf lock_en_buf0 (lock_en_in[0], dec_out[7]);
buf lock_en_buf1 (lock_en_in[1], dec_out[8]);

or_gate #(2) lock_enable_or(
    .in(lock_en_in),
    .out(lock_enable)
);

// ─── LOCK REGISTER ────────────────────────────────────────────

dff #(1) lock_register(
    .clk(clk),
    .reset(reset),
    .en(lock_enable),
    .d(lock_mux_out),
    .q(lock_out)
);

buf lock_status_buf (lock_status, lock_out);

endmodule