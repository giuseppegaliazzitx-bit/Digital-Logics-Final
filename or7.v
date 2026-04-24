module or7 (
    input  wire i0,
    input  wire i1,
    input  wire i2,
    input  wire i3,
    input  wire i4,
    input  wire i5,
    input  wire i6,
    output wire out
);
    or(out, i0, i1, i2, i3, i4, i5, i6);
endmodule
