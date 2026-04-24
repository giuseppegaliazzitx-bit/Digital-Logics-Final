module or4 (
    input  wire i0,
    input  wire i1,
    input  wire i2,
    input  wire i3,
    output wire out
);
    or(out, i0, i1, i2, i3);
endmodule
