// ============================================================
// Module: mux8to1_32bit
// Description: 32-bit 8-to-1 Multiplexer (Decision_Logic_MUX)
// ============================================================
module mux8to1_32bit (
    input  wire [2:0]  sel,
    input  wire [31:0] i0,
    input  wire [31:0] i1,
    input  wire [31:0] i2,
    input  wire [31:0] i3,
    input  wire [31:0] i4,
    input  wire [31:0] i5,
    input  wire [31:0] i6,
    input  wire [31:0] i7,
    output reg  [31:0] out
);
    always @(*) begin
        case (sel)
            3'd0: out = i0;
            3'd1: out = i1;
            3'd2: out = i2;
            3'd3: out = i3;
            3'd4: out = i4;
            3'd5: out = i5;
            3'd6: out = i6;
            3'd7: out = i7;
        endcase
    end
endmodule
