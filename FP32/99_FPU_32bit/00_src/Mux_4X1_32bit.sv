module Mux_4X1_32bit(
    input  logic [31:0] I0, I1, I2, I3,
    input  logic [1:0]  Sel,
    output logic [31:0] OUT
);

Mux_4X1 bit0  (.Sel(Sel), .I({I3[0], I2[0], I1[0], I0[0]}), .OUT(OUT[0]));
Mux_4X1 bit1  (.Sel(Sel), .I({I3[1], I2[1], I1[1], I0[1]}), .OUT(OUT[1]));
Mux_4X1 bit2  (.Sel(Sel), .I({I3[2], I2[2], I1[2], I0[2]}), .OUT(OUT[2]));
Mux_4X1 bit3  (.Sel(Sel), .I({I3[3], I2[3], I1[3], I0[3]}), .OUT(OUT[3]));
Mux_4X1 bit4  (.Sel(Sel), .I({I3[4], I2[4], I1[4], I0[4]}), .OUT(OUT[4]));
Mux_4X1 bit5  (.Sel(Sel), .I({I3[5], I2[5], I1[5], I0[5]}), .OUT(OUT[5]));
Mux_4X1 bit6  (.Sel(Sel), .I({I3[6], I2[6], I1[6], I0[6]}), .OUT(OUT[6]));
Mux_4X1 bit7  (.Sel(Sel), .I({I3[7], I2[7], I1[7], I0[7]}), .OUT(OUT[7]));
Mux_4X1 bit8  (.Sel(Sel), .I({I3[8], I2[8], I1[8], I0[8]}), .OUT(OUT[8]));
Mux_4X1 bit9  (.Sel(Sel), .I({I3[9], I2[9], I1[9], I0[9]}), .OUT(OUT[9]));
Mux_4X1 bit10 (.Sel(Sel), .I({I3[10], I2[10], I1[10], I0[10]}), .OUT(OUT[10]));
Mux_4X1 bit11 (.Sel(Sel), .I({I3[11], I2[11], I1[11], I0[11]}), .OUT(OUT[11]));
Mux_4X1 bit12 (.Sel(Sel), .I({I3[12], I2[12], I1[12], I0[12]}), .OUT(OUT[12]));
Mux_4X1 bit13 (.Sel(Sel), .I({I3[13], I2[13], I1[13], I0[13]}), .OUT(OUT[13]));
Mux_4X1 bit14 (.Sel(Sel), .I({I3[14], I2[14], I1[14], I0[14]}), .OUT(OUT[14]));
Mux_4X1 bit15 (.Sel(Sel), .I({I3[15], I2[15], I1[15], I0[15]}), .OUT(OUT[15]));
Mux_4X1 bit16 (.Sel(Sel), .I({I3[16], I2[16], I1[16], I0[16]}), .OUT(OUT[16]));
Mux_4X1 bit17 (.Sel(Sel), .I({I3[17], I2[17], I1[17], I0[17]}), .OUT(OUT[17]));
Mux_4X1 bit18 (.Sel(Sel), .I({I3[18], I2[18], I1[18], I0[18]}), .OUT(OUT[18]));
Mux_4X1 bit19 (.Sel(Sel), .I({I3[19], I2[19], I1[19], I0[19]}), .OUT(OUT[19]));
Mux_4X1 bit20 (.Sel(Sel), .I({I3[20], I2[20], I1[20], I0[20]}), .OUT(OUT[20]));
Mux_4X1 bit21 (.Sel(Sel), .I({I3[21], I2[21], I1[21], I0[21]}), .OUT(OUT[21]));
Mux_4X1 bit22 (.Sel(Sel), .I({I3[22], I2[22], I1[22], I0[22]}), .OUT(OUT[22]));
Mux_4X1 bit23 (.Sel(Sel), .I({I3[23], I2[23], I1[23], I0[23]}), .OUT(OUT[23]));
Mux_4X1 bit24 (.Sel(Sel), .I({I3[24], I2[24], I1[24], I0[24]}), .OUT(OUT[24]));
Mux_4X1 bit25 (.Sel(Sel), .I({I3[25], I2[25], I1[25], I0[25]}), .OUT(OUT[25]));
Mux_4X1 bit26 (.Sel(Sel), .I({I3[26], I2[26], I1[26], I0[26]}), .OUT(OUT[26]));
Mux_4X1 bit27 (.Sel(Sel), .I({I3[27], I2[27], I1[27], I0[27]}), .OUT(OUT[27]));
Mux_4X1 bit28 (.Sel(Sel), .I({I3[28], I2[28], I1[28], I0[28]}), .OUT(OUT[28]));
Mux_4X1 bit29 (.Sel(Sel), .I({I3[29], I2[29], I1[29], I0[29]}), .OUT(OUT[29]));
Mux_4X1 bit30 (.Sel(Sel), .I({I3[30], I2[30], I1[30], I0[30]}), .OUT(OUT[30]));
Mux_4X1 bit31 (.Sel(Sel), .I({I3[31], I2[31], I1[31], I0[31]}), .OUT(OUT[31]));
endmodule