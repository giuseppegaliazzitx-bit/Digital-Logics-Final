// ============================================================
// Module: register1
// Description: 1-bit register built from a single DFF.
//              Used for power_status and lock_status registers.
// Inputs:  clk   - system clock
//          reset - active-high reset (clears to 0)
//          d     - next value to store
// Outputs: q     - current stored value
// ============================================================
module register1 (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output wire q
);
    dff ff0 (.clk(clk), .reset(reset), .d(d), .q(q));
endmodule
