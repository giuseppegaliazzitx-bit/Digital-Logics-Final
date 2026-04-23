// ============================================================
// Module: dff
// Description: D Flip-Flop with synchronous reset (active-high).
//              This is behavioral per assignment specification.
//              All registers in the system are built from this DFF.
// Inputs:  clk   - system clock (rising edge triggered)
//          reset - synchronous active-high reset
//          d     - data input
// Outputs: q     - stored output
// ============================================================
module dff (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);
    always @(posedge clk) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule
