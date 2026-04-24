module alu32(
    input [31:0] a,
    input [31:0] b,
    input [2:0] ctr,
    output [31:0] ans,
    output carry
);

wire [31:0] add_result;
wire [31:0] sub_result;
wire add_carry;
wire sub_borrow;
wire [31:0] mux_out;

// Instantiate adder
adder32 adder(
    .a(a),
    .b(b),
    .sum(add_result),
    .carry_out(add_carry)
);

// Instantiate subtractor
subtractor32 subtractor(
    .a(a),
    .b(b),
    .diff(sub_result),
    .borrow_out(sub_borrow)
);

// CTR[1] selects between add and subtract
// ctr=010 → add, ctr=110 → subtract
// CTR[2] is the differentiating bit (0=add, 1=sub)
mux2to1 #(32) result_mux(
    .in0(add_result),
    .in1(sub_result),
    .sel(ctr[2]),
    .out(ans)
);

mux2to1 #(1) carry_mux(
    .in0(add_carry),
    .in1(sub_borrow),
    .sel(ctr[2]),
    .out(carry)
);

endmodule