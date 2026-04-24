// ============================================================
// Logic Gate Modules
// Description: Structural OR gates for system components.
// ============================================================

module or2 (
    input  wire i0,
    input  wire i1,
    output wire out
);
    or(out, i0, i1);
endmodule
