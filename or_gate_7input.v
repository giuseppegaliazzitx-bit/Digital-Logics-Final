// ============================================================
// Module: or_gate_7input
// Description: 7-input OR gate for Length_Enable_OR
//              Outputs 1 if any input is 1
// ============================================================
module or_gate_7input (
    input  wire [6:0] in,
    output wire       out
);
    assign out = |in;
endmodule
