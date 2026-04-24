// ============================================================
// Module: register8
// Description: 8-bit register built from 8 individual DFFs with enable.
// ============================================================
module register8 (
    input  wire       clk,
    input  wire       reset,
    input  wire       en,
    input  wire [7:0] d,
    output wire [7:0] q
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : dff_gen
            dff ff_inst (.clk(clk), .reset(reset), .en(en), .d(d[i]), .q(q[i]));
        end
    endgenerate
endmodule
