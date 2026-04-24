module not_gate #(parameter WIDTH = 1)(
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : not_array
        not g1 (out[i], in[i]);
    end
endgenerate

endmodule