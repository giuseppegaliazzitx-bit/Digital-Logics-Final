// ============================================================
// Module: length_alu
// Description: 32-bit Adder/Subtractor for blade length operations.
//              Performs addition when subtract=0, subtraction when subtract=1.
//              Built structurally using adder32 and subtractor32.
//
// Inputs:  a[31:0]    - first operand (current blade length)
//          b[31:0]    - second operand (value to add/subtract)
//          subtract   - 0 for addition, 1 for subtraction
// Outputs: result[31:0] - 32-bit result of operation
//          carry_out    - carry out (for addition) or borrow out (for subtraction)
// ============================================================
module length_alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire        subtract,
    output wire [31:0] result,
    output wire        carry_out
);
    wire [31:0] add_result;   // Result from adder
    wire [31:0] sub_result;   // Result from subtractor
    wire        add_cout;     // Carry out from adder
    wire        sub_bout;     // Borrow out from subtractor

    // 32-bit addition path
    adder32 adder_inst (
        .a     (a),
        .b     (b),
        .cin   (1'b0),
        .sum   (add_result),
        .cout  (add_cout)
    );

    // 32-bit subtraction path
    subtractor32 subtractor_inst (
        .a     (a),
        .b     (b),
        .diff  (sub_result),
        .bout  (sub_bout)
    );

    // MUX to select between addition and subtraction results
    mux2to1_32bit result_mux (
        .sel    (subtract),
        .a      (add_result),
        .b      (sub_result),
        .out    (result)
    );

    // MUX to select appropriate carry/borrow flag
    mux2to1_1bit carry_mux (
        .sel    (subtract),
        .a      (add_cout),
        .b      (sub_bout),
        .out    (carry_out)
    );
endmodule
