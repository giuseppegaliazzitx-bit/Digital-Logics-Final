module or_gate #(parameter INPUTS = 2)(
    input [INPUTS-1:0] in,
    output out
);

generate
    if (INPUTS == 2) begin
        or g1 (out, in[0], in[1]);
    end
    else if (INPUTS == 3) begin
        wire temp;
        or g1 (temp, in[0], in[1]);
        or g2 (out, temp, in[2]);
    end
    else if (INPUTS == 4) begin
        wire temp1, temp2;
        or g1 (temp1, in[0], in[1]);
        or g2 (temp2, in[2], in[3]);
        or g3 (out, temp1, temp2);
    end
    else if (INPUTS == 7) begin
        wire temp1, temp2, temp3, temp4, temp5;
        or g1 (temp1, in[0], in[1]);
        or g2 (temp2, in[2], in[3]);
        or g3 (temp3, in[4], in[5]);
        or g4 (temp4, temp1, temp2);
        or g5 (temp5, temp3, in[6]);
        or g6 (out, temp4, temp5);
    end
endgenerate

endmodule