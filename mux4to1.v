module mux4to1 #(parameter WIDTH = 1)(
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    input [WIDTH-1:0] in3,
    input [1:0] sel,
    output [WIDTH-1:0] out
);

wire not_sel0, not_sel1;
wire [WIDTH-1:0] and0_out, and1_out, and2_out, and3_out;
wire [WIDTH-1:0] or01_out, or23_out;

not g1 (not_sel0, sel[0]);
not g2 (not_sel1, sel[1]);

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : mux4_array
        // sel=00 → in0
        and g3 (and0_out[i], in0[i], not_sel1, not_sel0);
        // sel=01 → in1
        and g4 (and1_out[i], in1[i], not_sel1, sel[0]);
        // sel=10 → in2
        and g5 (and2_out[i], in2[i], sel[1], not_sel0);
        // sel=11 → in3
        and g6 (and3_out[i], in3[i], sel[1], sel[0]);
        // OR pairs
        or  g7 (or01_out[i], and0_out[i], and1_out[i]);
        or  g8 (or23_out[i], and2_out[i], and3_out[i]);
        // Final OR
        or  g9 (out[i], or01_out[i], or23_out[i]);
    end
endgenerate

endmodule