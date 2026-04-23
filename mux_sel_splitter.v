// ============================================================
// Module: mux_sel_splitter
// Description: 3-bit splitter combining selector bits for Decision_Logic_MUX
//              Passes through 3-bit selector unchanged
// ============================================================
module mux_sel_splitter (
    input  wire [2:0] sel_in,
    output wire [2:0] sel_out
);
    assign sel_out = sel_in;
endmodule
