// ============================================================
// Module: subtractor32
// Description: Structural 32-bit subtractor using two's complement.
//              Computes A - B by inverting B and adding 1 (cin=1).
//              Built structurally using NOT gates and adder32.
//              Used for blade length decrement operations.
//
// Inputs:  a[31:0] - minuend
//          b[31:0] - subtrahend
// Outputs: diff[31:0] - result of a - b
//          bout        - borrow out (1 if a < b, i.e. underflow)
// ============================================================
module subtractor32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] diff,
    output wire        bout
);
    wire [31:0] b_inv;  // Bitwise NOT of b
    wire        cout;   // Carry from adder (NOT cout = borrow)

    // Invert all bits of b (structural NOT gates)
    not g_inv0  (b_inv[0],  b[0]);
    not g_inv1  (b_inv[1],  b[1]);
    not g_inv2  (b_inv[2],  b[2]);
    not g_inv3  (b_inv[3],  b[3]);
    not g_inv4  (b_inv[4],  b[4]);
    not g_inv5  (b_inv[5],  b[5]);
    not g_inv6  (b_inv[6],  b[6]);
    not g_inv7  (b_inv[7],  b[7]);
    not g_inv8  (b_inv[8],  b[8]);
    not g_inv9  (b_inv[9],  b[9]);
    not g_inv10 (b_inv[10], b[10]);
    not g_inv11 (b_inv[11], b[11]);
    not g_inv12 (b_inv[12], b[12]);
    not g_inv13 (b_inv[13], b[13]);
    not g_inv14 (b_inv[14], b[14]);
    not g_inv15 (b_inv[15], b[15]);
    not g_inv16 (b_inv[16], b[16]);
    not g_inv17 (b_inv[17], b[17]);
    not g_inv18 (b_inv[18], b[18]);
    not g_inv19 (b_inv[19], b[19]);
    not g_inv20 (b_inv[20], b[20]);
    not g_inv21 (b_inv[21], b[21]);
    not g_inv22 (b_inv[22], b[22]);
    not g_inv23 (b_inv[23], b[23]);
    not g_inv24 (b_inv[24], b[24]);
    not g_inv25 (b_inv[25], b[25]);
    not g_inv26 (b_inv[26], b[26]);
    not g_inv27 (b_inv[27], b[27]);
    not g_inv28 (b_inv[28], b[28]);
    not g_inv29 (b_inv[29], b[29]);
    not g_inv30 (b_inv[30], b[30]);
    not g_inv31 (b_inv[31], b[31]);

    // a + (~b) + 1  =  a - b  (two's complement subtraction)
    // cin = 1 provides the "+1"
    adder32 sub_adder (
        .a(a), .b(b_inv), .cin(1'b1),
        .sum(diff), .cout(cout)
    );

    // Borrow = NOT carry_out (underflow when a < b)
    not g_borrow (bout, cout);
endmodule
