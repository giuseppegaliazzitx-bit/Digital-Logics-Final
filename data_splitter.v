// ============================================================
// Module: data_splitter
// Description: 32-to-8 splitter feeding Color, Count, and Error registers
//              Takes lower 8 bits of 32-bit data_in
// ============================================================
module data_splitter (
    input  wire [31:0] data_in,
    output wire [7:0]  data_out
);
    assign data_out = data_in[7:0];
endmodule
