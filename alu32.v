// ============================================================
// Module: alu32
// Description: 32-bit Arithmetic Logic Unit (Length_ALU)
//              Performs Add (010) or Subtract (110).
// ============================================================
module alu32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  op_code,
    output wire [31:0] result,
    output wire        cout,
    output wire        bout
);
    wire sub = (op_code == 3'b110);
    assign result = sub ? (a - b) : (a + b);
    
    wire [32:0] sum_ext = {1'b0, a} + {1'b0, b};
    assign cout = sum_ext[32];
    
    assign bout = (a < b);
endmodule
