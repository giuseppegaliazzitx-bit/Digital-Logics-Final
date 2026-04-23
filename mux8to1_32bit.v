// ============================================================
// Module: mux8to1_32bit
// Description: Structural 8-to-1 multiplexer for 32-bit signals.
//              Built from cascaded 2-to-1 MUXes.
//              Selects one of 8 inputs based on 3-bit select signal.
//
// Inputs:  sel[2:0]  - 3-bit select signal
//          in0[31:0] - input 0 (selected when sel=000)
//          in1[31:0] - input 1 (selected when sel=001)
//          in2[31:0] - input 2 (selected when sel=010)
//          in3[31:0] - input 3 (selected when sel=011)
//          in4[31:0] - input 4 (selected when sel=100)
//          in5[31:0] - input 5 (selected when sel=101)
//          in6[31:0] - input 6 (selected when sel=110)
//          in7[31:0] - input 7 (selected when sel=111)
// Outputs: out[31:0] - selected 32-bit value
// ============================================================
module mux8to1_32bit (
    input  wire [2:0]  sel,
    input  wire [31:0] in0,
    input  wire [31:0] in1,
    input  wire [31:0] in2,
    input  wire [31:0] in3,
    input  wire [31:0] in4,
    input  wire [31:0] in5,
    input  wire [31:0] in6,
    input  wire [31:0] in7,
    output wire [31:0] out
);
    wire [31:0] stage0_out;  // Output of first stage MUXes
    wire [31:0] stage1_out;  // Output of first stage MUXes
    wire [31:0] stage2_out;  // Output of first stage MUXes
    wire [31:0] stage3_out;  // Output of first stage MUXes

    // First stage: select between pairs using sel[0]
    mux2to1_32bit mux0_1 (.sel(sel[0]), .a(in0), .b(in1), .out(stage0_out));
    mux2to1_32bit mux2_3 (.sel(sel[0]), .a(in2), .b(in3), .out(stage1_out));
    mux2to1_32bit mux4_5 (.sel(sel[0]), .a(in4), .b(in5), .out(stage2_out));
    mux2to1_32bit mux6_7 (.sel(sel[0]), .a(in6), .b(in7), .out(stage3_out));

    // Second stage: select between first stage outputs using sel[1]
    wire [31:0] stage4_out;
    wire [31:0] stage5_out;
    mux2to1_32bit mux_stage4 (.sel(sel[1]), .a(stage0_out), .b(stage1_out), .out(stage4_out));
    mux2to1_32bit mux_stage5 (.sel(sel[1]), .a(stage2_out), .b(stage3_out), .out(stage5_out));

    // Final stage: select between the two groups using sel[2]
    mux2to1_32bit mux_final (.sel(sel[2]), .a(stage4_out), .b(stage5_out), .out(out));
endmodule
