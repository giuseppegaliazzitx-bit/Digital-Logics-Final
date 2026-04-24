// ============================================================
// Module: mux2to1_8bit
// Description: 8-bit 2-to-1 Multiplexer (ERROR_MUX)
// ============================================================
module mux2to1_8bit (
    input  wire       sel,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] out
);
    assign out = sel ? b : a;
endmodule
