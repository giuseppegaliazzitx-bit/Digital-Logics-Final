module decoder4to16(
    input [3:0] in,
    output [15:0] out
);

wire n3, n2, n1, n0;

not g1 (n3, in[3]);
not g2 (n2, in[2]);
not g3 (n1, in[1]);
not g4 (n0, in[0]);

and a0  (out[0],  n3, n2, n1, n0);
and a1  (out[1],  n3, n2, n1, in[0]);
and a2  (out[2],  n3, n2, in[1], n0);
and a3  (out[3],  n3, n2, in[1], in[0]);
and a4  (out[4],  n3, in[2], n1, n0);
and a5  (out[5],  n3, in[2], n1, in[0]);
and a6  (out[6],  n3, in[2], in[1], n0);
and a7  (out[7],  n3, in[2], in[1], in[0]);
and a8  (out[8],  in[3], n2, n1, n0);
and a9  (out[9],  in[3], n2, n1, in[0]);
and a10 (out[10], in[3], n2, in[1], n0);
and a11 (out[11], in[3], n2, in[1], in[0]);
and a12 (out[12], in[3], in[2], n1, n0);
and a13 (out[13], in[3], in[2], n1, in[0]);
and a14 (out[14], in[3], in[2], in[1], n0);
and a15 (out[15], in[3], in[2], in[1], in[0]);

endmodule