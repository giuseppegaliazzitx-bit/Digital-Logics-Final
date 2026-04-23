// ============================================================
// Module: or_gate_2input
// Description: 2-input OR gate for Lock_Enable_OR and Error_Enable_OR
//              Outputs 1 if any input is 1
// ============================================================
module or_gate_2input (
    input  wire [1:0] in,
    output wire       out
);
    assign out = |in;
endmodule
