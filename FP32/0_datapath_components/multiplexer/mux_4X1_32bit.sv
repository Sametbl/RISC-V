module mux_4X1_32bit(
    input  logic [1:0]  sel,
    input  logic [31:0] D0, D1, D2, D3,
    output logic [31:0] Y
);

mux_4X1 bit0  (.sel(sel), .D({D3[0], D2[0], D1[0], D0[0]}), .Y(Y[0]));
mux_4X1 bit1  (.sel(sel), .D({D3[1], D2[1], D1[1], D0[1]}), .Y(Y[1]));
mux_4X1 bit2  (.sel(sel), .D({D3[2], D2[2], D1[2], D0[2]}), .Y(Y[2]));
mux_4X1 bit3  (.sel(sel), .D({D3[3], D2[3], D1[3], D0[3]}), .Y(Y[3]));
mux_4X1 bit4  (.sel(sel), .D({D3[4], D2[4], D1[4], D0[4]}), .Y(Y[4]));
mux_4X1 bit5  (.sel(sel), .D({D3[5], D2[5], D1[5], D0[5]}), .Y(Y[5]));
mux_4X1 bit6  (.sel(sel), .D({D3[6], D2[6], D1[6], D0[6]}), .Y(Y[6]));
mux_4X1 bit7  (.sel(sel), .D({D3[7], D2[7], D1[7], D0[7]}), .Y(Y[7]));
mux_4X1 bit8  (.sel(sel), .D({D3[8], D2[8], D1[8], D0[8]}), .Y(Y[8]));
mux_4X1 bit9  (.sel(sel), .D({D3[9], D2[9], D1[9], D0[9]}), .Y(Y[9]));
mux_4X1 bit10 (.sel(sel), .D({D3[10], D2[10], D1[10], D0[10]}), .Y(Y[10]));
mux_4X1 bit11 (.sel(sel), .D({D3[11], D2[11], D1[11], D0[11]}), .Y(Y[11]));
mux_4X1 bit12 (.sel(sel), .D({D3[12], D2[12], D1[12], D0[12]}), .Y(Y[12]));
mux_4X1 bit13 (.sel(sel), .D({D3[13], D2[13], D1[13], D0[13]}), .Y(Y[13]));
mux_4X1 bit14 (.sel(sel), .D({D3[14], D2[14], D1[14], D0[14]}), .Y(Y[14]));
mux_4X1 bit15 (.sel(sel), .D({D3[15], D2[15], D1[15], D0[15]}), .Y(Y[15]));
mux_4X1 bit16 (.sel(sel), .D({D3[16], D2[16], D1[16], D0[16]}), .Y(Y[16]));
mux_4X1 bit17 (.sel(sel), .D({D3[17], D2[17], D1[17], D0[17]}), .Y(Y[17]));
mux_4X1 bit18 (.sel(sel), .D({D3[18], D2[18], D1[18], D0[18]}), .Y(Y[18]));
mux_4X1 bit19 (.sel(sel), .D({D3[19], D2[19], D1[19], D0[19]}), .Y(Y[19]));
mux_4X1 bit20 (.sel(sel), .D({D3[20], D2[20], D1[20], D0[20]}), .Y(Y[20]));
mux_4X1 bit21 (.sel(sel), .D({D3[21], D2[21], D1[21], D0[21]}), .Y(Y[21]));
mux_4X1 bit22 (.sel(sel), .D({D3[22], D2[22], D1[22], D0[22]}), .Y(Y[22]));
mux_4X1 bit23 (.sel(sel), .D({D3[23], D2[23], D1[23], D0[23]}), .Y(Y[23]));
mux_4X1 bit24 (.sel(sel), .D({D3[24], D2[24], D1[24], D0[24]}), .Y(Y[24]));
mux_4X1 bit25 (.sel(sel), .D({D3[25], D2[25], D1[25], D0[25]}), .Y(Y[25]));
mux_4X1 bit26 (.sel(sel), .D({D3[26], D2[26], D1[26], D0[26]}), .Y(Y[26]));
mux_4X1 bit27 (.sel(sel), .D({D3[27], D2[27], D1[27], D0[27]}), .Y(Y[27]));
mux_4X1 bit28 (.sel(sel), .D({D3[28], D2[28], D1[28], D0[28]}), .Y(Y[28]));
mux_4X1 bit29 (.sel(sel), .D({D3[29], D2[29], D1[29], D0[29]}), .Y(Y[29]));
mux_4X1 bit30 (.sel(sel), .D({D3[30], D2[30], D1[30], D0[30]}), .Y(Y[30]));
mux_4X1 bit31 (.sel(sel), .D({D3[31], D2[31], D1[31], D0[31]}), .Y(Y[31]));
endmodule

