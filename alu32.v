// ============================================================
// Module: alu32
// Description: 32-bit Arithmetic Logic Unit (Length_ALU)
//              Performs addition or subtraction.
// ============================================================
module alu32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire        sub,
    output wire [31:0] result,
    output wire        cout,
    output wire        bout
);
    assign result = sub ? (a - b) : (a + b);
    
    wire [32:0] sum_ext = {1'b0, a} + {1'b0, b};
    assign cout = sum_ext[32];
    
    assign bout = (a < b);
endmodule
