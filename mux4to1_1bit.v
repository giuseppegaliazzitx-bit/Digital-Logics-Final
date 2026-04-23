// ============================================================
// Module: mux4to1_1bit
// Description: Structural 4-to-1 multiplexer for 1-bit signals.
//              Built from cascaded 2-to-1 MUXes.
//              Selects one of 4 inputs based on 2-bit select signal.
//
// Inputs:  sel[1:0] - 2-bit select signal
//          in0      - input 0 (selected when sel=00)
//          in1      - input 1 (selected when sel=01)
//          in2      - input 2 (selected when sel=10)
//          in3      - input 3 (selected when sel=11)
// Outputs: out      - selected 1-bit value
// ============================================================
module mux4to1_1bit (
    input  wire [1:0] sel,
    input  wire       in0,
    input  wire       in1,
    input  wire       in2,
    input  wire       in3,
    output wire       out
);
    wire stage0_out;  // Output of first stage MUX
    wire stage1_out;  // Output of second stage MUX

    // First stage: select between pairs using sel[0]
    mux2to1_1bit mux0_1 (.sel(sel[0]), .a(in0), .b(in1), .out(stage0_out));
    mux2to1_1bit mux2_3 (.sel(sel[0]), .a(in2), .b(in3), .out(stage1_out));

    // Second stage: select between first stage outputs using sel[1]
    mux2to1_1bit mux_final (.sel(sel[1]), .a(stage0_out), .b(stage1_out), .out(out));
endmodule
