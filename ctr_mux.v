// ============================================================
// Module: ctr_mux
// Description: 3-bit 2-to-1 multiplexer selecting addition or subtraction for Length_ALU
//              sel=0: addition (0), sel=1: subtraction (1)
// ============================================================
module ctr_mux (
    input  wire       sel,
    output wire [2:0] alu_control
);
    assign alu_control = {2'b00, sel}; // 3-bit control: [2:1] always 0, [0] = subtract flag
endmodule
