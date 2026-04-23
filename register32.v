// ============================================================
// Module: register32
// Description: 32-bit register built from 32 individual DFFs.
//              Used for blade_length register (32-bit).
// Inputs:  clk   - system clock
//          reset - active-high reset (clears all bits to 0)
//          d     - 32-bit next value to store
// Outputs: q     - 32-bit current stored value
// ============================================================
module register32 (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] d,
    output wire [31:0] q
);
    dff ff0  (.clk(clk), .reset(reset), .d(d[0]),  .q(q[0]));
    dff ff1  (.clk(clk), .reset(reset), .d(d[1]),  .q(q[1]));
    dff ff2  (.clk(clk), .reset(reset), .d(d[2]),  .q(q[2]));
    dff ff3  (.clk(clk), .reset(reset), .d(d[3]),  .q(q[3]));
    dff ff4  (.clk(clk), .reset(reset), .d(d[4]),  .q(q[4]));
    dff ff5  (.clk(clk), .reset(reset), .d(d[5]),  .q(q[5]));
    dff ff6  (.clk(clk), .reset(reset), .d(d[6]),  .q(q[6]));
    dff ff7  (.clk(clk), .reset(reset), .d(d[7]),  .q(q[7]));
    dff ff8  (.clk(clk), .reset(reset), .d(d[8]),  .q(q[8]));
    dff ff9  (.clk(clk), .reset(reset), .d(d[9]),  .q(q[9]));
    dff ff10 (.clk(clk), .reset(reset), .d(d[10]), .q(q[10]));
    dff ff11 (.clk(clk), .reset(reset), .d(d[11]), .q(q[11]));
    dff ff12 (.clk(clk), .reset(reset), .d(d[12]), .q(q[12]));
    dff ff13 (.clk(clk), .reset(reset), .d(d[13]), .q(q[13]));
    dff ff14 (.clk(clk), .reset(reset), .d(d[14]), .q(q[14]));
    dff ff15 (.clk(clk), .reset(reset), .d(d[15]), .q(q[15]));
    dff ff16 (.clk(clk), .reset(reset), .d(d[16]), .q(q[16]));
    dff ff17 (.clk(clk), .reset(reset), .d(d[17]), .q(q[17]));
    dff ff18 (.clk(clk), .reset(reset), .d(d[18]), .q(q[18]));
    dff ff19 (.clk(clk), .reset(reset), .d(d[19]), .q(q[19]));
    dff ff20 (.clk(clk), .reset(reset), .d(d[20]), .q(q[20]));
    dff ff21 (.clk(clk), .reset(reset), .d(d[21]), .q(q[21]));
    dff ff22 (.clk(clk), .reset(reset), .d(d[22]), .q(q[22]));
    dff ff23 (.clk(clk), .reset(reset), .d(d[23]), .q(q[23]));
    dff ff24 (.clk(clk), .reset(reset), .d(d[24]), .q(q[24]));
    dff ff25 (.clk(clk), .reset(reset), .d(d[25]), .q(q[25]));
    dff ff26 (.clk(clk), .reset(reset), .d(d[26]), .q(q[26]));
    dff ff27 (.clk(clk), .reset(reset), .d(d[27]), .q(q[27]));
    dff ff28 (.clk(clk), .reset(reset), .d(d[28]), .q(q[28]));
    dff ff29 (.clk(clk), .reset(reset), .d(d[29]), .q(q[29]));
    dff ff30 (.clk(clk), .reset(reset), .d(d[30]), .q(q[30]));
    dff ff31 (.clk(clk), .reset(reset), .d(d[31]), .q(q[31]));
endmodule
