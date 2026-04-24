module subtractor32(
    input [31:0] a,
    input [31:0] b,
    output [31:0] diff,
    output borrow_out
);

wire [31:0] b_inverted;
wire [32:0] carry;

// Invert all bits of b
genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : invert_array
        not g1 (b_inverted[i], b[i]);
    end
endgenerate

// Set carry in to 1 (two's complement subtraction)
buf g2 (carry[0], 1'b1);

// Ripple carry adder with inverted b and carry in of 1
generate
    for (i = 0; i < 32; i = i + 1) begin : subtractor_array
        full_adder fa(
            .a(a[i]),
            .b(b_inverted[i]),
            .cin(carry[i]),
            .sum(diff[i]),
            .cout(carry[i+1])
        );
    end
endgenerate

buf g3 (borrow_out, carry[32]);

endmodule