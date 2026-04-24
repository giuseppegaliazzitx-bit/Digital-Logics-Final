module or3 (
    input  wire i0,
    input  wire i1,
    input  wire i2,
    output wire out
);
    or(out, i0, i1, i2);
endmodule
