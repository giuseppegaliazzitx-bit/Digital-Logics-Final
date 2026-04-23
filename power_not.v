// ============================================================
// Module: power_not
// Description: 1-bit NOT gate for Toggle Power operation
//              Inverts the power feedback signal
// ============================================================
module power_not (
    input  wire in,
    output wire out
);
    assign out = ~in;
endmodule
