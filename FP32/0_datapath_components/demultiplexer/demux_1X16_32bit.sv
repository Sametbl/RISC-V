module demux_1X16_32bit(
	input  logic [31:0] D,
	input  logic [3:0] sel,
	output logic [31:0] S0, S1, S2, S3, S4, S5, S6, S7, S8,
	output logic [31:0] S9, S10, S11, S12, S13, S14, S15
);

demux_1X16   bit0  (.sel(sel), .D(D[0]),  .S({S15[0],  S14[0],  S13[0],  S12[0],  S11[0],  S10[0],  S9[0],  S8[0],  S7[0],  S6[0],  S5[0],  S4[0],  S3[0],  S2[0],  S1[0],  S0[0]}));
demux_1X16   bit1  (.sel(sel), .D(D[1]),  .S({S15[1],  S14[1],  S13[1],  S12[1],  S11[1],  S10[1],  S9[1],  S8[1],  S7[1],  S6[1],  S5[1],  S4[1],  S3[1],  S2[1],  S1[1],  S0[1]}));
demux_1X16   bit2  (.sel(sel), .D(D[2]),  .S({S15[2],  S14[2],  S13[2],  S12[2],  S11[2],  S10[2],  S9[2],  S8[2],  S7[2],  S6[2],  S5[2],  S4[2],  S3[2],  S2[2],  S1[2],  S0[2]}));
demux_1X16   bit3  (.sel(sel), .D(D[3]),  .S({S15[3],  S14[3],  S13[3],  S12[3],  S11[3],  S10[3],  S9[3],  S8[3],  S7[3],  S6[3],  S5[3],  S4[3],  S3[3],  S2[3],  S1[3],  S0[3]}));
demux_1X16   bit4  (.sel(sel), .D(D[4]),  .S({S15[4],  S14[4],  S13[4],  S12[4],  S11[4],  S10[4],  S9[4],  S8[4],  S7[4],  S6[4],  S5[4],  S4[4],  S3[4],  S2[4],  S1[4],  S0[4]}));
demux_1X16   bit5  (.sel(sel), .D(D[5]),  .S({S15[5],  S14[5],  S13[5],  S12[5],  S11[5],  S10[5],  S9[5],  S8[5],  S7[5],  S6[5],  S5[5],  S4[5],  S3[5],  S2[5],  S1[5],  S0[5]}));
demux_1X16   bit6  (.sel(sel), .D(D[6]),  .S({S15[6],  S14[6],  S13[6],  S12[6],  S11[6],  S10[6],  S9[6],  S8[6],  S7[6],  S6[6],  S5[6],  S4[6],  S3[6],  S2[6],  S1[6],  S0[6]}));
demux_1X16   bit7  (.sel(sel), .D(D[7]),  .S({S15[7],  S14[7],  S13[7],  S12[7],  S11[7],  S10[7],  S9[7],  S8[7],  S7[7],  S6[7],  S5[7],  S4[7],  S3[7],  S2[7],  S1[7],  S0[7]}));
demux_1X16   bit8  (.sel(sel), .D(D[8]),  .S({S15[8],  S14[8],  S13[8],  S12[8],  S11[8],  S10[8],  S9[8],  S8[8],  S7[8],  S6[8],  S5[8],  S4[8],  S3[8],  S2[8],  S1[8],  S0[8]}));
demux_1X16   bit9  (.sel(sel), .D(D[9]),  .S({S15[9],  S14[9],  S13[9],  S12[9],  S11[9],  S10[9],  S9[9],  S8[9],  S7[9],  S6[9],  S5[9],  S4[9],  S3[9],  S2[9],  S1[9],  S0[9]}));
demux_1X16   bit10 (.sel(sel), .D(D[10]), .S({S15[10], S14[10], S13[10], S12[10], S11[10], S10[10], S9[10], S8[10], S7[10], S6[10], S5[10], S4[10], S3[10], S2[10], S1[10], S0[10]}));
demux_1X16   bit11 (.sel(sel), .D(D[11]), .S({S15[11], S14[11], S13[11], S12[11], S11[11], S10[11], S9[11], S8[11], S7[11], S6[11], S5[11], S4[11], S3[11], S2[11], S1[11], S0[11]}));
demux_1X16   bit12 (.sel(sel), .D(D[12]), .S({S15[12], S14[12], S13[12], S12[12], S11[12], S10[12], S9[12], S8[12], S7[12], S6[12], S5[12], S4[12], S3[12], S2[12], S1[12], S0[12]}));
demux_1X16   bit13 (.sel(sel), .D(D[13]), .S({S15[13], S14[13], S13[13], S12[13], S11[13], S10[13], S9[13], S8[13], S7[13], S6[13], S5[13], S4[13], S3[13], S2[13], S1[13], S0[13]}));
demux_1X16   bit14 (.sel(sel), .D(D[14]), .S({S15[14], S14[14], S13[14], S12[14], S11[14], S10[14], S9[14], S8[14], S7[14], S6[14], S5[14], S4[14], S3[14], S2[14], S1[14], S0[14]}));
demux_1X16   bit15 (.sel(sel), .D(D[15]), .S({S15[15], S14[15], S13[15], S12[15], S11[15], S10[15], S9[15], S8[15], S7[15], S6[15], S5[15], S4[15], S3[15], S2[15], S1[15], S0[15]}));
demux_1X16   bit16 (.sel(sel), .D(D[16]), .S({S15[16], S14[16], S13[16], S12[16], S11[16], S10[16], S9[16], S8[16], S7[16], S6[16], S5[16], S4[16], S3[16], S2[16], S1[16], S0[16]}));
demux_1X16   bit17 (.sel(sel), .D(D[17]), .S({S15[17], S14[17], S13[17], S12[17], S11[17], S10[17], S9[17], S8[17], S7[17], S6[17], S5[17], S4[17], S3[17], S2[17], S1[17], S0[17]}));
demux_1X16   bit18 (.sel(sel), .D(D[18]), .S({S15[18], S14[18], S13[18], S12[18], S11[18], S10[18], S9[18], S8[18], S7[18], S6[18], S5[18], S4[18], S3[18], S2[18], S1[18], S0[18]}));
demux_1X16   bit19 (.sel(sel), .D(D[19]), .S({S15[19], S14[19], S13[19], S12[19], S11[19], S10[19], S9[19], S8[19], S7[19], S6[19], S5[19], S4[19], S3[19], S2[19], S1[19], S0[19]}));
demux_1X16   bit20 (.sel(sel), .D(D[20]), .S({S15[20], S14[20], S13[20], S12[20], S11[20], S10[20], S9[20], S8[20], S7[20], S6[20], S5[20], S4[20], S3[20], S2[20], S1[20], S0[20]}));
demux_1X16   bit21 (.sel(sel), .D(D[21]), .S({S15[21], S14[21], S13[21], S12[21], S11[21], S10[21], S9[21], S8[21], S7[21], S6[21], S5[21], S4[21], S3[21], S2[21], S1[21], S0[21]}));
demux_1X16   bit22 (.sel(sel), .D(D[22]), .S({S15[22], S14[22], S13[22], S12[22], S11[22], S10[22], S9[22], S8[22], S7[22], S6[22], S5[22], S4[22], S3[22], S2[22], S1[22], S0[22]}));
demux_1X16   bit23 (.sel(sel), .D(D[23]), .S({S15[23], S14[23], S13[23], S12[23], S11[23], S10[23], S9[23], S8[23], S7[23], S6[23], S5[23], S4[23], S3[23], S2[23], S1[23], S0[23]}));
demux_1X16   bit24 (.sel(sel), .D(D[24]), .S({S15[24], S14[24], S13[24], S12[24], S11[24], S10[24], S9[24], S8[24], S7[24], S6[24], S5[24], S4[24], S3[24], S2[24], S1[24], S0[24]}));
demux_1X16   bit25 (.sel(sel), .D(D[25]), .S({S15[25], S14[25], S13[25], S12[25], S11[25], S10[25], S9[25], S8[25], S7[25], S6[25], S5[25], S4[25], S3[25], S2[25], S1[25], S0[25]}));
demux_1X16   bit26 (.sel(sel), .D(D[26]), .S({S15[26], S14[26], S13[26], S12[26], S11[26], S10[26], S9[26], S8[26], S7[26], S6[26], S5[26], S4[26], S3[26], S2[26], S1[26], S0[26]}));
demux_1X16   bit27 (.sel(sel), .D(D[27]), .S({S15[27], S14[27], S13[27], S12[27], S11[27], S10[27], S9[27], S8[27], S7[27], S6[27], S5[27], S4[27], S3[27], S2[27], S1[27], S0[27]}));
demux_1X16   bit28 (.sel(sel), .D(D[28]), .S({S15[28], S14[28], S13[28], S12[28], S11[28], S10[28], S9[28], S8[28], S7[28], S6[28], S5[28], S4[28], S3[28], S2[28], S1[28], S0[28]}));
demux_1X16   bit29 (.sel(sel), .D(D[29]), .S({S15[29], S14[29], S13[29], S12[29], S11[29], S10[29], S9[29], S8[29], S7[29], S6[29], S5[29], S4[29], S3[29], S2[29], S1[29], S0[29]}));
demux_1X16   bit30 (.sel(sel), .D(D[30]), .S({S15[30], S14[30], S13[30], S12[30], S11[30], S10[30], S9[30], S8[30], S7[30], S6[30], S5[30], S4[30], S3[30], S2[30], S1[30], S0[30]}));
demux_1X16   bit31 (.sel(sel), .D(D[31]), .S({S15[31], S14[31], S13[31], S12[31], S11[31], S10[31], S9[31], S8[31], S7[31], S6[31], S5[31], S4[31], S3[31], S2[31], S1[31], S0[31]}));

endmodule





