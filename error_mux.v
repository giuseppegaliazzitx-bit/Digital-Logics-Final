// ============================================================
// Module: error_mux
// Description: 8-bit 2-to-1 multiplexer for Error_Register
//              Selects between constant 0 and data_in[7:0]
// ============================================================
module error_mux (
    input  wire       sel,        // Select line (1 = data_in, 0 = 0)
    input  wire [7:0] data_in,    // Data input
    output wire [7:0] data_out    // MUX output
);
    assign data_out = sel ? data_in : 8'h00;
endmodule
