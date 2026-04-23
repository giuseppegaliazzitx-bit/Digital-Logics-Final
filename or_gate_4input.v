// ============================================================
// Module: or_gate_4input
// Description: 4-input OR gate for MUX_Sel_Bit0_OR
//              Outputs 1 if any input is 1
// ============================================================
module or_gate_4input (
    input  wire [3:0] in,
    output wire       out
);
    assign out = |in;
endmodule
