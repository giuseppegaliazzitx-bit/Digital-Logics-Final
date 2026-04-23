// ============================================================
// Module: decoder4to16
// Description: Structural 4-to-16 decoder. Converts a 4-bit
//              opcode into a one-hot 16-bit select signal.
//              Built entirely from NOT and AND gate primitives.
//              Each output line is high for exactly one input value.
//
// Truth table (partial):
//   in = 0000 → out[0]  = 1, all others 0  (Power OFF)
//   in = 0001 → out[1]  = 1, all others 0  (Power ON)
//   in = 0010 → out[2]  = 1                (Set Length)
//   ...
//   in = 1111 → out[15] = 1                (Reserved)
//
// Inputs:  in[3:0]  - 4-bit opcode
// Outputs: out[15:0] - one-hot decoded output
// ============================================================
module decoder4to16 (
    input  wire [3:0]  in,
    output wire [15:0] out
);
    // Inverted inputs
    wire n3, n2, n1, n0;
    not g_n3 (n3, in[3]);
    not g_n2 (n2, in[2]);
    not g_n1 (n1, in[1]);
    not g_n0 (n0, in[0]);

    // One gate per output: out[i] = 1 only when in == i
    and g_out0  (out[0],  n3, n2, n1, n0    );  // 0000
    and g_out1  (out[1],  n3, n2, n1, in[0] );  // 0001
    and g_out2  (out[2],  n3, n2, in[1], n0 );  // 0010
    and g_out3  (out[3],  n3, n2, in[1], in[0]); // 0011
    and g_out4  (out[4],  n3, in[2], n1, n0 );  // 0100
    and g_out5  (out[5],  n3, in[2], n1, in[0]); // 0101
    and g_out6  (out[6],  n3, in[2], in[1], n0); // 0110
    and g_out7  (out[7],  n3, in[2], in[1], in[0]); // 0111
    and g_out8  (out[8],  in[3], n2, n1, n0    ); // 1000
    and g_out9  (out[9],  in[3], n2, n1, in[0] ); // 1001
    and g_out10 (out[10], in[3], n2, in[1], n0 ); // 1010
    and g_out11 (out[11], in[3], n2, in[1], in[0]); // 1011
    and g_out12 (out[12], in[3], in[2], n1, n0 ); // 1100
    and g_out13 (out[13], in[3], in[2], n1, in[0]); // 1101
    and g_out14 (out[14], in[3], in[2], in[1], n0); // 1110
    and g_out15 (out[15], in[3], in[2], in[1], in[0]); // 1111
endmodule
