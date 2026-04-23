// ============================================================
// Module: full_adder
// Description: Structural single-bit full adder.
//              Built from XOR, AND, and OR gate primitives.
// Inputs:  a, b - single-bit operands
//          cin  - carry in
// Outputs: sum  - single-bit sum
//          cout - carry out
// ============================================================
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire s1, c1, c2;
    xor g_xor1 (s1,   a,  b   );   // partial sum
    xor g_xor2 (sum,  s1, cin  );   // final sum
    and g_and1 (c1,   a,  b   );   // carry from a & b
    and g_and2 (c2,   s1, cin  );   // carry from sum & cin
    or  g_or1  (cout, c1, c2  );   // final carry out
endmodule

// ============================================================
// Module: adder8
// Description: Structural 8-bit ripple carry adder.
//              Chains 8 full_adder modules bit by bit.
//              Used for blade length increment (A + 1).
// Inputs:  a[7:0]  - first operand
//          b[7:0]  - second operand
//          cin     - carry input (use 0 for normal addition)
// Outputs: sum[7:0] - 8-bit result
//          cout     - carry out (overflow flag)
// ============================================================
module adder8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       cin,
    output wire [7:0] sum,
    output wire       cout
);
    wire [6:0] carry;  // Internal carry chain

    full_adder fa0 (.a(a[0]), .b(b[0]), .cin(cin),     .sum(sum[0]), .cout(carry[0]));
    full_adder fa1 (.a(a[1]), .b(b[1]), .cin(carry[0]), .sum(sum[1]), .cout(carry[1]));
    full_adder fa2 (.a(a[2]), .b(b[2]), .cin(carry[1]), .sum(sum[2]), .cout(carry[2]));
    full_adder fa3 (.a(a[3]), .b(b[3]), .cin(carry[2]), .sum(sum[3]), .cout(carry[3]));
    full_adder fa4 (.a(a[4]), .b(b[4]), .cin(carry[3]), .sum(sum[4]), .cout(carry[4]));
    full_adder fa5 (.a(a[5]), .b(b[5]), .cin(carry[4]), .sum(sum[5]), .cout(carry[5]));
    full_adder fa6 (.a(a[6]), .b(b[6]), .cin(carry[5]), .sum(sum[6]), .cout(carry[6]));
    full_adder fa7 (.a(a[7]), .b(b[7]), .cin(carry[6]), .sum(sum[7]), .cout(cout));
endmodule
