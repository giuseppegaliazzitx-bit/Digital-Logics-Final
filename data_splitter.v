// ============================================================
// Module: data_splitter
// Description: Splits 32-bit data_in bus for target components.
// ============================================================
module data_splitter (
    input  wire [31:0] data_in,
    output wire [31:0] length_data,
    output wire [7:0]  color_data,
    output wire [7:0]  count_data,
    output wire [7:0]  error_data
);
    assign length_data = data_in;
    assign color_data  = data_in[7:0];
    assign count_data  = data_in[7:0];
    assign error_data  = data_in[7:0];
endmodule
