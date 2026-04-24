// ============================================================
// Module: mux_sel_splitter
// Description: Extracts select lines from the opcode.
// ============================================================
module mux_sel_splitter (
    input  wire [3:0] opcode,
    output wire [2:0] decision_mux_sel,
    output wire [1:0] power_mux_sel
);
    assign decision_mux_sel = opcode[2:0];
    assign power_mux_sel    = opcode[1:0];
endmodule
