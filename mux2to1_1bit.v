// ============================================================
// Module: mux2to1_1bit
// Description: 2-to-1 multiplexer for 1-bit signals
// ============================================================
module mux2to1_1bit (
    input  wire sel,
    input  wire a,
    input  wire b,
    output wire out
);
    assign out = sel ? b : a;
endmodule
