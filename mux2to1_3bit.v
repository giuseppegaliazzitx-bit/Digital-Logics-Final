// ============================================================
// Module: mux2to1_3bit
// Description: Structural 2-to-1 multiplexer for 3-bit signals.
//              Instantiates 3 mux2to1_1bit modules, one per bit.
//              When sel=0, output = a. When sel=1, output = b.
//
// Inputs:  sel     - select signal
//          a[2:0]  - channel 0 (selected when sel=0)
//          b[2:0]  - channel 1 (selected when sel=1)
// Outputs: out[2:0] - selected 3-bit value
// ============================================================
module mux2to1_3bit (
    input  wire      sel,
    input  wire [2:0] a,
    input  wire [2:0] b,
    output wire [2:0] out
);
    mux2to1_1bit m0 (.sel(sel), .a(a[0]), .b(b[0]), .out(out[0]));
    mux2to1_1bit m1 (.sel(sel), .a(a[1]), .b(b[1]), .out(out[1]));
    mux2to1_1bit m2 (.sel(sel), .a(a[2]), .b(b[2]), .out(out[2]));
endmodule
