module Mux_2X1_32bit(
		input  logic [31:0] A, B,
		input  logic Sel,
	   output logic [31:0] OUT
);

Mux_2X1   bit0  (.A(A[0]),  .B(B[0]),  .Sel(Sel), .OUT(OUT[0]));
Mux_2X1   bit1  (.A(A[1]),  .B(B[1]),  .Sel(Sel), .OUT(OUT[1]));
Mux_2X1   bit2  (.A(A[2]),  .B(B[2]),  .Sel(Sel), .OUT(OUT[2]));
Mux_2X1   bit3  (.A(A[3]),  .B(B[3]),  .Sel(Sel), .OUT(OUT[3]));
Mux_2X1   bit4  (.A(A[4]),  .B(B[4]),  .Sel(Sel), .OUT(OUT[4]));
Mux_2X1   bit5  (.A(A[5]),  .B(B[5]),  .Sel(Sel), .OUT(OUT[5]));
Mux_2X1   bit6  (.A(A[6]),  .B(B[6]),  .Sel(Sel), .OUT(OUT[6]));
Mux_2X1   bit7  (.A(A[7]),  .B(B[7]),  .Sel(Sel), .OUT(OUT[7]));

Mux_2X1   bit8  (.A(A[8]),  .B(B[8]),  .Sel(Sel), .OUT(OUT[8]));
Mux_2X1   bit9  (.A(A[9]),  .B(B[9]),  .Sel(Sel), .OUT(OUT[9]));
Mux_2X1   bit10 (.A(A[10]), .B(B[10]), .Sel(Sel), .OUT(OUT[10]));
Mux_2X1   bit11 (.A(A[11]), .B(B[11]), .Sel(Sel), .OUT(OUT[11]));
Mux_2X1   bit12 (.A(A[12]), .B(B[12]), .Sel(Sel), .OUT(OUT[12]));
Mux_2X1   bit13 (.A(A[13]), .B(B[13]), .Sel(Sel), .OUT(OUT[13]));
Mux_2X1   bit14 (.A(A[14]), .B(B[14]), .Sel(Sel), .OUT(OUT[14]));
Mux_2X1   bit15 (.A(A[15]), .B(B[15]), .Sel(Sel), .OUT(OUT[15]));

Mux_2X1   bit16 (.A(A[16]), .B(B[16]), .Sel(Sel), .OUT(OUT[16]));
Mux_2X1   bit17 (.A(A[17]), .B(B[17]), .Sel(Sel), .OUT(OUT[17]));
Mux_2X1   bit18 (.A(A[18]), .B(B[18]), .Sel(Sel), .OUT(OUT[18]));
Mux_2X1   bit19 (.A(A[19]), .B(B[19]), .Sel(Sel), .OUT(OUT[19]));
Mux_2X1   bit20 (.A(A[20]), .B(B[20]), .Sel(Sel), .OUT(OUT[20]));
Mux_2X1   bit21 (.A(A[21]), .B(B[21]), .Sel(Sel), .OUT(OUT[21]));
Mux_2X1   bit22 (.A(A[22]), .B(B[22]), .Sel(Sel), .OUT(OUT[22]));
Mux_2X1   bit23 (.A(A[23]), .B(B[23]), .Sel(Sel), .OUT(OUT[23]));

Mux_2X1   bit24 (.A(A[24]), .B(B[24]), .Sel(Sel), .OUT(OUT[24]));
Mux_2X1   bit25 (.A(A[25]), .B(B[25]), .Sel(Sel), .OUT(OUT[25]));
Mux_2X1   bit26 (.A(A[26]), .B(B[26]), .Sel(Sel), .OUT(OUT[26]));
Mux_2X1   bit27 (.A(A[27]), .B(B[27]), .Sel(Sel), .OUT(OUT[27]));
Mux_2X1   bit28 (.A(A[28]), .B(B[28]), .Sel(Sel), .OUT(OUT[28]));
Mux_2X1   bit29 (.A(A[29]), .B(B[29]), .Sel(Sel), .OUT(OUT[29]));
Mux_2X1   bit30 (.A(A[30]), .B(B[30]), .Sel(Sel), .OUT(OUT[30]));
Mux_2X1   bit31 (.A(A[31]), .B(B[31]), .Sel(Sel), .OUT(OUT[31]));

endmodule
