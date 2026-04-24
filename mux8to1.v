module mux8to1 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    input [WIDTH-1:0] in3,
    input [WIDTH-1:0] in4,
    input [WIDTH-1:0] in5,
    input [WIDTH-1:0] in6,
    input [WIDTH-1:0] in7,
    input [2:0] sel,
    output [WIDTH-1:0] out
);

wire not_sel0, not_sel1, not_sel2;
wire [WIDTH-1:0] and0_out, and1_out, and2_out, and3_out;
wire [WIDTH-1:0] and4_out, and5_out, and6_out, and7_out;
wire [WIDTH-1:0] or01_out, or23_out, or45_out, or67_out;
wire [WIDTH-1:0] or0123_out, or4567_out;

not g1 (not_sel0, sel[0]);
not g2 (not_sel1, sel[1]);
not g3 (not_sel2, sel[2]);

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : mux8_array
        // sel=000 → in0
        and g4 (and0_out[i], in0[i], not_sel2, not_sel1, not_sel0);
        // sel=001 → in1
        and g5 (and1_out[i], in1[i], not_sel2, not_sel1, sel[0]);
        // sel=010 → in2
        and g6 (and2_out[i], in2[i], not_sel2, sel[1], not_sel0);
        // sel=011 → in3
        and g7 (and3_out[i], in3[i], not_sel2, sel[1], sel[0]);
        // sel=100 → in4
        and g8 (and4_out[i], in4[i], sel[2], not_sel1, not_sel0);
        // sel=101 → in5
        and g9 (and5_out[i], in5[i], sel[2], not_sel1, sel[0]);
        // sel=110 → in6
        and g10 (and6_out[i], in6[i], sel[2], sel[1], not_sel0);
        // sel=111 → in7
        and g11 (and7_out[i], in7[i], sel[2], sel[1], sel[0]);
        // OR pairs
        or g12 (or01_out[i],   and0_out[i], and1_out[i]);
        or g13 (or23_out[i],   and2_out[i], and3_out[i]);
        or g14 (or45_out[i],   and4_out[i], and5_out[i]);
        or g15 (or67_out[i],   and6_out[i], and7_out[i]);
        // OR groups
        or g16 (or0123_out[i], or01_out[i], or23_out[i]);
        or g17 (or4567_out[i], or45_out[i], or67_out[i]);
        // Final OR
        or g18 (out[i],        or0123_out[i], or4567_out[i]);
    end
endgenerate

endmodule