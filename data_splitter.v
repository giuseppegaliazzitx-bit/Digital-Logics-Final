// ============================================================
// Module: data_splitter
// Description: Splits 32-bit data_in bus for target components.
// ============================================================
module data_splitter (
    input  wire [31:0] data_in,
    output wire [31:0] length_data,
    output wire [31:0] color_data,
    output wire [31:0] count_data
);
    assign length_data = data_in;
    assign color_data  = data_in;
    assign count_data  = data_in;
endmodule
