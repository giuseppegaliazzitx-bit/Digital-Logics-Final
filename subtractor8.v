// ============================================================
// Module: subtractor8
// Description: Structural 8-bit subtractor using two's complement.
//              Computes A - B by inverting B and adding 1 (cin=1).
//              Built structurally using NOT gates and adder8.
//              Used for blade length decrement (A - 1).
//
// Inputs:  a[7:0] - minuend
//          b[7:0] - subtrahend
// Outputs: diff[7:0] - result of a - b
//          bout      - borrow out (1 if a < b, i.e. underflow)
// ============================================================
module subtractor8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] diff,
    output wire       bout
);
    wire [7:0] b_inv;  // Bitwise NOT of b
    wire       cout;   // Carry from adder (NOT cout = borrow)

    // Invert all bits of b (structural NOT gates)
    not g_inv0 (b_inv[0], b[0]);
    not g_inv1 (b_inv[1], b[1]);
    not g_inv2 (b_inv[2], b[2]);
    not g_inv3 (b_inv[3], b[3]);
    not g_inv4 (b_inv[4], b[4]);
    not g_inv5 (b_inv[5], b[5]);
    not g_inv6 (b_inv[6], b[6]);
    not g_inv7 (b_inv[7], b[7]);

    // a + (~b) + 1  =  a - b  (two's complement subtraction)
    // cin = 1 provides the "+1"
    adder8 sub_adder (
        .a(a), .b(b_inv), .cin(1'b1),
        .sum(diff), .cout(cout)
    );

    // Borrow = NOT carry_out (underflow when a < b)
    not g_borrow (bout, cout);
endmodule
