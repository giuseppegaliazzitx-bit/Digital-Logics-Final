// ============================================================
// Module: not_32bit
// Description: Structural 32-bit NOT gate.
//              Performs bitwise NOT operation on 32-bit input.
//              Built from 32 individual NOT gate primitives.
//
// Inputs:  in[31:0] - 32-bit input
// Outputs: out[31:0] - bitwise NOT of input
// ============================================================
module not_32bit (
    input  wire [31:0] in,
    output wire [31:0] out
);
    not g_not0  (out[0],  in[0]);
    not g_not1  (out[1],  in[1]);
    not g_not2  (out[2],  in[2]);
    not g_not3  (out[3],  in[3]);
    not g_not4  (out[4],  in[4]);
    not g_not5  (out[5],  in[5]);
    not g_not6  (out[6],  in[6]);
    not g_not7  (out[7],  in[7]);
    not g_not8  (out[8],  in[8]);
    not g_not9  (out[9],  in[9]);
    not g_not10 (out[10], in[10]);
    not g_not11 (out[11], in[11]);
    not g_not12 (out[12], in[12]);
    not g_not13 (out[13], in[13]);
    not g_not14 (out[14], in[14]);
    not g_not15 (out[15], in[15]);
    not g_not16 (out[16], in[16]);
    not g_not17 (out[17], in[17]);
    not g_not18 (out[18], in[18]);
    not g_not19 (out[19], in[19]);
    not g_not20 (out[20], in[20]);
    not g_not21 (out[21], in[21]);
    not g_not22 (out[22], in[22]);
    not g_not23 (out[23], in[23]);
    not g_not24 (out[24], in[24]);
    not g_not25 (out[25], in[25]);
    not g_not26 (out[26], in[26]);
    not g_not27 (out[27], in[27]);
    not g_not28 (out[28], in[28]);
    not g_not29 (out[29], in[29]);
    not g_not30 (out[30], in[30]);
    not g_not31 (out[31], in[31]);
endmodule
