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
// Module: mux2to1_32bit
// Description: Structural 2-to-1 multiplexer for 32-bit signals.
//              Instantiates 32 mux2to1_1bit modules, one per bit.
//              When sel=0, output = a. When sel=1, output = b.
//
// Inputs:  sel      - select signal
//          a[31:0]  - channel 0 (selected when sel=0)
//          b[31:0]  - channel 1 (selected when sel=1)
// Outputs: out[31:0] - selected 32-bit value
// ============================================================
module mux2to1_32bit (
    input  wire        sel,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] out
);
    mux2to1_1bit m0  (.sel(sel), .a(a[0]),  .b(b[0]),  .out(out[0]));
    mux2to1_1bit m1  (.sel(sel), .a(a[1]),  .b(b[1]),  .out(out[1]));
    mux2to1_1bit m2  (.sel(sel), .a(a[2]),  .b(b[2]),  .out(out[2]));
    mux2to1_1bit m3  (.sel(sel), .a(a[3]),  .b(b[3]),  .out(out[3]));
    mux2to1_1bit m4  (.sel(sel), .a(a[4]),  .b(b[4]),  .out(out[4]));
    mux2to1_1bit m5  (.sel(sel), .a(a[5]),  .b(b[5]),  .out(out[5]));
    mux2to1_1bit m6  (.sel(sel), .a(a[6]),  .b(b[6]),  .out(out[6]));
    mux2to1_1bit m7  (.sel(sel), .a(a[7]),  .b(b[7]),  .out(out[7]));
    mux2to1_1bit m8  (.sel(sel), .a(a[8]),  .b(b[8]),  .out(out[8]));
    mux2to1_1bit m9  (.sel(sel), .a(a[9]),  .b(b[9]),  .out(out[9]));
    mux2to1_1bit m10 (.sel(sel), .a(a[10]), .b(b[10]), .out(out[10]));
    mux2to1_1bit m11 (.sel(sel), .a(a[11]), .b(b[11]), .out(out[11]));
    mux2to1_1bit m12 (.sel(sel), .a(a[12]), .b(b[12]), .out(out[12]));
    mux2to1_1bit m13 (.sel(sel), .a(a[13]), .b(b[13]), .out(out[13]));
    mux2to1_1bit m14 (.sel(sel), .a(a[14]), .b(b[14]), .out(out[14]));
    mux2to1_1bit m15 (.sel(sel), .a(a[15]), .b(b[15]), .out(out[15]));
    mux2to1_1bit m16 (.sel(sel), .a(a[16]), .b(b[16]), .out(out[16]));
    mux2to1_1bit m17 (.sel(sel), .a(a[17]), .b(b[17]), .out(out[17]));
    mux2to1_1bit m18 (.sel(sel), .a(a[18]), .b(b[18]), .out(out[18]));
    mux2to1_1bit m19 (.sel(sel), .a(a[19]), .b(b[19]), .out(out[19]));
    mux2to1_1bit m20 (.sel(sel), .a(a[20]), .b(b[20]), .out(out[20]));
    mux2to1_1bit m21 (.sel(sel), .a(a[21]), .b(b[21]), .out(out[21]));
    mux2to1_1bit m22 (.sel(sel), .a(a[22]), .b(b[22]), .out(out[22]));
    mux2to1_1bit m23 (.sel(sel), .a(a[23]), .b(b[23]), .out(out[23]));
    mux2to1_1bit m24 (.sel(sel), .a(a[24]), .b(b[24]), .out(out[24]));
    mux2to1_1bit m25 (.sel(sel), .a(a[25]), .b(b[25]), .out(out[25]));
    mux2to1_1bit m26 (.sel(sel), .a(a[26]), .b(b[26]), .out(out[26]));
    mux2to1_1bit m27 (.sel(sel), .a(a[27]), .b(b[27]), .out(out[27]));
    mux2to1_1bit m28 (.sel(sel), .a(a[28]), .b(b[28]), .out(out[28]));
    mux2to1_1bit m29 (.sel(sel), .a(a[29]), .b(b[29]), .out(out[29]));
    mux2to1_1bit m30 (.sel(sel), .a(a[30]), .b(b[30]), .out(out[30]));
    mux2to1_1bit m31 (.sel(sel), .a(a[31]), .b(b[31]), .out(out[31]));
endmodule
