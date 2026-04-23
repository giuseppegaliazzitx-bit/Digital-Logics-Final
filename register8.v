// ============================================================
// Module: register8
// Description: 8-bit register built from 8 individual DFFs.
//              Used for blade_length, blade_color, blade_count,
//              and error_reg registers.
// Inputs:  clk   - system clock
//          reset - active-high reset (clears all bits to 0)
//          d     - 8-bit next value to store
// Outputs: q     - 8-bit current stored value
// ============================================================
module register8 (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] d,
    output wire [7:0] q
);
    dff ff0 (.clk(clk), .reset(reset), .d(d[0]), .q(q[0]));
    dff ff1 (.clk(clk), .reset(reset), .d(d[1]), .q(q[1]));
    dff ff2 (.clk(clk), .reset(reset), .d(d[2]), .q(q[2]));
    dff ff3 (.clk(clk), .reset(reset), .d(d[3]), .q(q[3]));
    dff ff4 (.clk(clk), .reset(reset), .d(d[4]), .q(q[4]));
    dff ff5 (.clk(clk), .reset(reset), .d(d[5]), .q(q[5]));
    dff ff6 (.clk(clk), .reset(reset), .d(d[6]), .q(q[6]));
    dff ff7 (.clk(clk), .reset(reset), .d(d[7]), .q(q[7]));
endmodule
