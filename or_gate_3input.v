// ============================================================
// Module: or_gate_3input
// Description: 3-input OR gate for Power_Enable_OR
//              Outputs 1 if any input is 1
// ============================================================
module or_gate_3input (
    input  wire [2:0] in,
    output wire       out
);
    assign out = |in;
endmodule
