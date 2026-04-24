module dff #(parameter WIDTH = 1)(
    input clk,
    input reset,
    input en,
    input [WIDTH-1:0] d,
    output [WIDTH-1:0] q
);

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : dff_array
        dff_1bit bit_inst (
            .clk(clk),
            .reset(reset),
            .en(en),
            .d(d[i]),
            .q(q[i])
        );
    end
endgenerate

endmodule