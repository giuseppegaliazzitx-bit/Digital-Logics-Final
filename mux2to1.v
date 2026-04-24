module mux2to1 #(parameter WIDTH = 1)(
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    input sel,
    output [WIDTH-1:0] out
);

wire [WIDTH-1:0] and0_out;
wire [WIDTH-1:0] and1_out;
wire not_sel;

not g1 (not_sel, sel);

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : mux_array
        and g2 (and0_out[i], in0[i], not_sel);
        and g3 (and1_out[i], in1[i], sel);
        or  g4 (out[i], and0_out[i], and1_out[i]);
    end
endgenerate

endmodule