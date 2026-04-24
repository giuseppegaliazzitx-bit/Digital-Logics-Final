module adder32(
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum,
    output carry_out
);

wire [32:0] carry;

buf g1 (carry[0], 1'b0);

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : adder_array
        full_adder fa(
            .a(a[i]),
            .b(b[i]),
            .cin(carry[i]),
            .sum(sum[i]),
            .cout(carry[i+1])
        );
    end
endgenerate

buf g2 (carry_out, carry[32]);

endmodule