// ============================================================
// Module: mux2to1_1bit
// Description: Structural 2-to-1 multiplexer for 1-bit signals.
//              Built from NOT, AND, and OR gate primitives.
//              When sel=0, output = a. When sel=1, output = b.
//
// Inputs:  sel - select signal
//          a   - channel 0 (selected when sel=0)
//          b   - channel 1 (selected when sel=1)
// Outputs: out - selected value
// ============================================================
module mux2to1_1bit (
    input  wire sel,
    input  wire a,
    input  wire b,
    output wire out
);
    wire n_sel;    // inverted select
    wire sel_a;   // a gated by ~sel
    wire sel_b;   // b gated by sel

    not g_not  (n_sel, sel      );
    and g_and0 (sel_a, n_sel, a );
    and g_and1 (sel_b, sel,   b );
    or  g_or   (out,   sel_a, sel_b);
endmodule

// ============================================================
// Module: mux2to1_8bit
// Description: Structural 2-to-1 multiplexer for 8-bit signals.
//              Instantiates 8 mux2to1_1bit modules, one per bit.
//              When sel=0, output = a. When sel=1, output = b.
//
// Inputs:  sel     - select signal
//          a[7:0]  - channel 0 (selected when sel=0)
//          b[7:0]  - channel 1 (selected when sel=1)
// Outputs: out[7:0] - selected 8-bit value
// ============================================================
module mux2to1_8bit (
    input  wire       sel,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] out
);
    mux2to1_1bit m0 (.sel(sel), .a(a[0]), .b(b[0]), .out(out[0]));
    mux2to1_1bit m1 (.sel(sel), .a(a[1]), .b(b[1]), .out(out[1]));
    mux2to1_1bit m2 (.sel(sel), .a(a[2]), .b(b[2]), .out(out[2]));
    mux2to1_1bit m3 (.sel(sel), .a(a[3]), .b(b[3]), .out(out[3]));
    mux2to1_1bit m4 (.sel(sel), .a(a[4]), .b(b[4]), .out(out[4]));
    mux2to1_1bit m5 (.sel(sel), .a(a[5]), .b(b[5]), .out(out[5]));
    mux2to1_1bit m6 (.sel(sel), .a(a[6]), .b(b[6]), .out(out[6]));
    mux2to1_1bit m7 (.sel(sel), .a(a[7]), .b(b[7]), .out(out[7]));
endmodule
