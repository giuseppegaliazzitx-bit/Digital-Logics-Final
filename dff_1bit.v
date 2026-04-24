module dff_1bit(
    input clk,
    input reset,
    input en,
    input d,
    output q
);

wire q_bar;
wire en_and_d, not_en, not_en_and_q, mux_out;
wire not_reset, d_final;

// Synchronous Enable MUX: en ? d : q
not  g1 (not_en, en);
and  g2 (en_and_d, en, d);
and  g3 (not_en_and_q, not_en, q);
or   g4 (mux_out, en_and_d, not_en_and_q);

// Synchronous Reset MUX: reset ? 0 : mux_out
not  g5 (not_reset, reset);
and  g6 (d_final, not_reset, mux_out);

// 6-NAND Positive-Edge Triggered DFF Core
wire w1, w2, w3, w4;
nand g7  (w1, w4, w2);
nand g8  (w2, w1, clk);
nand g9  (w3, w2, clk, w4);
nand g10 (w4, w3, d_final);
nand g11 (q, w2, q_bar);
nand g12 (q_bar, w3, q);

endmodule