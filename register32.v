// ============================================================
// Module: register32
// Description: 32-bit register built from 32 individual DFFs.
// Inputs:  clk   - system clock
//          reset - active-high reset (clears all bits to 0)
//          en    - enable signal
//          d     - 32-bit next value to store
// Outputs: q     - 32-bit current stored value
// ============================================================
module register32 (
    input  wire        clk,
    input  wire        reset,
    input  wire        en,
    input  wire [31:0] d,
    output wire [31:0] q
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : dff_gen
            dff ff_inst (.clk(clk), .reset(reset), .en(en), .d(d[i]), .q(q[i]));
        end
    endgenerate
endmodule
