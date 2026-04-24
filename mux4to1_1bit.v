// ============================================================
// Module: mux4to1_1bit
// Description: 1-bit 4-to-1 Multiplexer (Power_MUX)
// ============================================================
module mux4to1_1bit (
    input  wire [1:0] sel,
    input  wire       i0,
    input  wire       i1,
    input  wire       i2,
    input  wire       i3,
    output reg        out
);
    always @(*) begin
        case (sel)
            2'd0: out = i0;
            2'd1: out = i1;
            2'd2: out = i2;
            2'd3: out = i3;
        endcase
    end
endmodule
