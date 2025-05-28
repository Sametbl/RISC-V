module mux_2X1_32bit(
		input  logic sel,
		input  logic [31:0] A, B,
	    output logic [31:0] Y
);

mux_2X1   bit0  (.A(A[0]),  .B(B[0]),  .sel(sel), .Y(Y[0]));
mux_2X1   bit1  (.A(A[1]),  .B(B[1]),  .sel(sel), .Y(Y[1]));
mux_2X1   bit2  (.A(A[2]),  .B(B[2]),  .sel(sel), .Y(Y[2]));
mux_2X1   bit3  (.A(A[3]),  .B(B[3]),  .sel(sel), .Y(Y[3]));
mux_2X1   bit4  (.A(A[4]),  .B(B[4]),  .sel(sel), .Y(Y[4]));
mux_2X1   bit5  (.A(A[5]),  .B(B[5]),  .sel(sel), .Y(Y[5]));
mux_2X1   bit6  (.A(A[6]),  .B(B[6]),  .sel(sel), .Y(Y[6]));
mux_2X1   bit7  (.A(A[7]),  .B(B[7]),  .sel(sel), .Y(Y[7]));

mux_2X1   bit8  (.A(A[8]),  .B(B[8]),  .sel(sel), .Y(Y[8]));
mux_2X1   bit9  (.A(A[9]),  .B(B[9]),  .sel(sel), .Y(Y[9]));
mux_2X1   bit10 (.A(A[10]), .B(B[10]), .sel(sel), .Y(Y[10]));
mux_2X1   bit11 (.A(A[11]), .B(B[11]), .sel(sel), .Y(Y[11]));
mux_2X1   bit12 (.A(A[12]), .B(B[12]), .sel(sel), .Y(Y[12]));
mux_2X1   bit13 (.A(A[13]), .B(B[13]), .sel(sel), .Y(Y[13]));
mux_2X1   bit14 (.A(A[14]), .B(B[14]), .sel(sel), .Y(Y[14]));
mux_2X1   bit15 (.A(A[15]), .B(B[15]), .sel(sel), .Y(Y[15]));

mux_2X1   bit16 (.A(A[16]), .B(B[16]), .sel(sel), .Y(Y[16]));
mux_2X1   bit17 (.A(A[17]), .B(B[17]), .sel(sel), .Y(Y[17]));
mux_2X1   bit18 (.A(A[18]), .B(B[18]), .sel(sel), .Y(Y[18]));
mux_2X1   bit19 (.A(A[19]), .B(B[19]), .sel(sel), .Y(Y[19]));
mux_2X1   bit20 (.A(A[20]), .B(B[20]), .sel(sel), .Y(Y[20]));
mux_2X1   bit21 (.A(A[21]), .B(B[21]), .sel(sel), .Y(Y[21]));
mux_2X1   bit22 (.A(A[22]), .B(B[22]), .sel(sel), .Y(Y[22]));
mux_2X1   bit23 (.A(A[23]), .B(B[23]), .sel(sel), .Y(Y[23]));

mux_2X1   bit24 (.A(A[24]), .B(B[24]), .sel(sel), .Y(Y[24]));
mux_2X1   bit25 (.A(A[25]), .B(B[25]), .sel(sel), .Y(Y[25]));
mux_2X1   bit26 (.A(A[26]), .B(B[26]), .sel(sel), .Y(Y[26]));
mux_2X1   bit27 (.A(A[27]), .B(B[27]), .sel(sel), .Y(Y[27]));
mux_2X1   bit28 (.A(A[28]), .B(B[28]), .sel(sel), .Y(Y[28]));
mux_2X1   bit29 (.A(A[29]), .B(B[29]), .sel(sel), .Y(Y[29]));
mux_2X1   bit30 (.A(A[30]), .B(B[30]), .sel(sel), .Y(Y[30]));
mux_2X1   bit31 (.A(A[31]), .B(B[31]), .sel(sel), .Y(Y[31]));

endmodule

