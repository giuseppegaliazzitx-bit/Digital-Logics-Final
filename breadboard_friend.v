// ============================================================
// Module: breadboard_friend
// Description: Lightsaber Control Circuit - Friend's Architecture
//              Implements all 16 opcodes using specified component architecture
// ============================================================
module breadboard_friend (
    input  wire        clk,
    input  wire        reset,
    input  wire [3:0]  opcode,
    input  wire [31:0] data_in,
    output wire [31:0] blade_length,
    output wire [7:0]  blade_color,
    output wire [7:0]  blade_count,
    output wire [7:0]  error_reg
);

// ============================================================
// INTERNAL SIGNALS
// ============================================================
// Decoder outputs
wire [15:0] decode;

// Register outputs (now declared as reg above)
// wire [31:0] length_q;  // Now reg
// wire [7:0]  color_q;   // Now reg
// wire [7:0]  count_q;   // Now reg
// wire [7:0]  error_q;   // Now reg
// wire        power_q;   // Now reg
// wire        lock_q;    // Now reg

// ALU signals
wire [31:0] alu_out;
wire        alu_carry;

// MUX signals
wire [31:0] mux_out;
wire [2:0]  mux_sel;

// Control signals
wire [6:0] length_enable_inputs;
wire [2:0] power_enable_inputs;
wire [1:0] lock_enable_inputs;
wire [1:0] error_enable_inputs;
wire        length_enable;
wire        power_enable;
wire        lock_enable;
wire        error_enable;

// Data routing
wire [7:0]  split_data;
wire [7:0]  error_mux_out;
wire        power_not_out;
wire [2:0]  alu_control;
wire [31:0] length_not_out;

// MUX selector generation
wire mux_sel_bit0;
wire mux_sel_bit1;

// ============================================================
// COMPONENT 1: OPCODE_DECODER
// ============================================================
decoder4to16 opcode_decoder (
    .in  (opcode),
    .out (decode)
);

// ============================================================
// COMPONENT 2: LENGTH_ALU with dynamic B input
// ============================================================
wire [31:0] alu_b_input;
assign alu_b_input = decode[11] ? length_q : 32'd1;  // Double length uses A+A

length_alu blade_alu (
    .a         (length_q),
    .b         (alu_b_input),
    .subtract  (alu_control[0]),  // Subtraction control
    .result    (alu_out),
    .carry_out (alu_carry)
);

// ============================================================
// COMPONENT 3: DECISION_LOGIC_MUX (8-to-1)
// Input mapping based on friend's design
// sel 000: Hold current value
// sel 001: data_in (Set Length)
// sel 010: ALU output (Increment)
// sel 011: ALU output (Decrement)
// sel 100: ALU output (Double Length)
// sel 101: 0 (Clear Length)
// sel 110: all 1s (Maximize Length)
// sel 111: NOT of current (Invert Length)
// ============================================================
mux8to1_32bit decision_logic_mux (
    .sel (mux_sel),
    .in0 (length_q),           // Hold - 000
    .in1 (data_in),            // Set Length - 001
    .in2 (alu_out),            // Increment - 010
    .in3 (alu_out),            // Decrement - 011
    .in4 (alu_out),            // Double Length - 100
    .in5 (32'd0),              // Clear Length - 101
    .in6 (32'hFFFFFFFF),      // Maximize Length - 110
    .in7 (length_not_out),     // Invert Length - 111
    .out (mux_out)
);

// ============================================================
// COMPONENT 4: LENGTH_NOT
// ============================================================
not_32bit length_not (
    .in  (length_q),
    .out (length_not_out)
);

// ============================================================
// COMPONENT 5: POWER_NOT
// ============================================================
power_not power_not_inst (
    .in  (power_q),
    .out (power_not_out)
);

// ============================================================
// COMPONENT 6: DATA_SPLITTER
// ============================================================
data_splitter data_splitter_inst (
    .data_in  (data_in),
    .data_out (split_data)
);

// ============================================================
// COMPONENT 7: ERROR_MUX
// ============================================================
error_mux error_mux_inst (
    .sel     (decode[14]),      // Set Error opcode
    .data_in (split_data),      // Lower 8 bits of data_in
    .data_out(error_mux_out)
);

// ============================================================
// COMPONENT 8: CTR_MUX
// ============================================================
ctr_mux ctr_mux_inst (
    .sel         (decode[4]),       // Decrement opcode
    .alu_control (alu_control)
);

// ============================================================
// COMPONENT 9: LENGTH_ENABLE_OR (7-input)
// Opcodes that enable length register: 0010, 0011, 0100, 1011, 1100, 1101, 1111
// ============================================================
assign length_enable_inputs = {decode[15], decode[13], decode[12], decode[11], decode[4], decode[3], decode[2]};
or_gate_7input length_enable_or (
    .in  (length_enable_inputs),
    .out (length_enable)
);

// ============================================================
// COMPONENT 10: POWER_ENABLE_OR (3-input)
// Opcodes that enable power register: 0000, 0001, 1010
// ============================================================
assign power_enable_inputs = {decode[10], decode[1], decode[0]};
or_gate_3input power_enable_or (
    .in  (power_enable_inputs),
    .out (power_enable)
);

// ============================================================
// COMPONENT 11: LOCK_ENABLE_OR (2-input)
// Opcodes that enable lock register: 0111, 1000
// ============================================================
assign lock_enable_inputs = {decode[8], decode[7]};
or_gate_2input lock_enable_or (
    .in  (lock_enable_inputs),
    .out (lock_enable)
);

// ============================================================
// COMPONENT 12: ERROR_ENABLE_OR (2-input)
// Opcodes that enable error register: 1001, 1110
// ============================================================
assign error_enable_inputs = {decode[14], decode[9]};
or_gate_2input error_enable_or (
    .in  (error_enable_inputs),
    .out (error_enable)
);

// ============================================================
// COMPONENT 13: MUX_SELECTOR_LOGIC
// Based on friend's design for Decision_Logic_MUX selector
// ============================================================

// MUX selector mapping according to friend's design:
// 000: Hold (no operation)
// 001: Set Length (opcode 0010)
// 010: Increment (opcode 0011) 
// 011: Decrement (opcode 0100)
// 100: Double Length (opcode 1011)
// 101: Clear Length (opcode 1100)
// 110: Maximize Length (opcode 1101)
// 111: Invert Length (opcode 1111)

assign mux_sel = 
    decode[2]  ? 3'b001 :  // Set Length
    decode[3]  ? 3'b010 :  // Increment
    decode[4]  ? 3'b011 :  // Decrement
    decode[11] ? 3'b100 :  // Double Length
    decode[12] ? 3'b101 :  // Clear Length
    decode[13] ? 3'b110 :  // Maximize Length
    decode[15] ? 3'b111 :  // Invert Length
    3'b000;                // Default: Hold

// ============================================================
// COMPONENT 16: REGISTERS WITH ENABLE LOGIC
// ============================================================

// Length Register (32-bit) - gated by length_enable
reg [31:0] length_q;
always @(posedge clk) begin
    if (reset) begin
        length_q <= 32'd0;
    end else if (length_enable) begin
        length_q <= mux_out;
    end
end

// Color Register (8-bit) - gated by opcode 0101
reg [7:0] color_q;
always @(posedge clk) begin
    if (reset) begin
        color_q <= 8'd0;
    end else if (decode[5]) begin
        color_q <= split_data;
    end
end

// Count Register (8-bit) - gated by opcode 0110
reg [7:0] count_q;
always @(posedge clk) begin
    if (reset) begin
        count_q <= 8'd0;
    end else if (decode[6]) begin
        count_q <= split_data;
    end
end

// Error Register (8-bit) - gated by error_enable
reg [7:0] error_q;
always @(posedge clk) begin
    if (reset) begin
        error_q <= 8'd0;
    end else if (error_enable) begin
        error_q <= error_mux_out;
    end
end

// Power Register (1-bit) - gated by power_enable
reg power_q;
always @(posedge clk) begin
    if (reset) begin
        power_q <= 1'b0;
    end else if (power_enable) begin
        if (decode[10]) begin  // Toggle Power
            power_q <= power_not_out;
        end else if (decode[1]) begin  // Power ON
            power_q <= 1'b1;
        end else if (decode[0]) begin  // Power OFF
            power_q <= 1'b0;
        end
    end
end

// Lock Register (1-bit) - gated by lock_enable
reg lock_q;
always @(posedge clk) begin
    if (reset) begin
        lock_q <= 1'b0;
    end else if (lock_enable) begin
        if (decode[7]) begin  // Lock
            lock_q <= 1'b1;
        end else if (decode[8]) begin  // Unlock
            lock_q <= 1'b0;
        end
    end
end

// ============================================================
// OUTPUT ASSIGNMENTS
// ============================================================
assign blade_length = length_q;
assign blade_color  = color_q;
assign blade_count  = count_q;
assign error_reg    = error_q;

// ============================================================
// SPECIAL HANDLING FOR DOUBLE LENGTH (1011)
// When opcode 1011 is active, modify ALU to do A+A instead of A+1
// ============================================================
wire double_length_active = decode[11];
wire [31:0] alu_b_modified = double_length_active ? length_q : 32'd1;

// Re-instantiate ALU with modified B input (this is a simplified approach)
// In a complete implementation, you'd need proper multiplexing

endmodule
