// ============================================================
// Module: mux2to1_3bit
// Description: 3-bit 2-to-1 Multiplexer (CTR_MUX)
// ============================================================
module mux2to1_3bit (
    input  wire       sel,
    input  wire [2:0] a,
    input  wire [2:0] b,
    output wire [2:0] out
);
    assign out = sel ? b : a;
endmodule
