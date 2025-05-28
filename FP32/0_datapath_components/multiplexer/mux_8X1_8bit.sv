module mux_8X1_8bit(
    input  logic [2:0] sel,
    input  logic [7:0] D0, D1, D2, D3, D4, D5, D6, D7,
    output logic [7:0] Y
);

mux_8X1   bit0  (.sel(sel), .D({D7[0], D6[0], D5[0], D4[0], D3[0], D2[0], D1[0], D0[0]}), .Y(Y[0]));
mux_8X1   bit1  (.sel(sel), .D({D7[1], D6[1], D5[1], D4[1], D3[1], D2[1], D1[1], D0[1]}), .Y(Y[1]));
mux_8X1   bit2  (.sel(sel), .D({D7[2], D6[2], D5[2], D4[2], D3[2], D2[2], D1[2], D0[2]}), .Y(Y[2]));
mux_8X1   bit3  (.sel(sel), .D({D7[3], D6[3], D5[3], D4[3], D3[3], D2[3], D1[3], D0[3]}), .Y(Y[3]));
mux_8X1   bit4  (.sel(sel), .D({D7[4], D6[4], D5[4], D4[4], D3[4], D2[4], D1[4], D0[4]}), .Y(Y[4]));
mux_8X1   bit5  (.sel(sel), .D({D7[5], D6[5], D5[5], D4[5], D3[5], D2[5], D1[5], D0[5]}), .Y(Y[5]));
mux_8X1   bit6  (.sel(sel), .D({D7[6], D6[6], D5[6], D4[6], D3[6], D2[6], D1[6], D0[6]}), .Y(Y[6]));
mux_8X1   bit7  (.sel(sel), .D({D7[7], D6[7], D5[7], D4[7], D3[7], D2[7], D1[7], D0[7]}), .Y(Y[7]));

endmodule

