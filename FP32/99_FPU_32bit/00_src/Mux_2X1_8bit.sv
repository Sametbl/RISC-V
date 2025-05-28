module Mux_2X1_8bit(
		input  logic [7:0] A, B,
		input  logic Sel,
	   output logic [7:0] OUT
);

Mux_2X1   bit0  (.A(A[0]),  .B(B[0]),  .Sel(Sel), .OUT(OUT[0]));
Mux_2X1   bit1  (.A(A[1]),  .B(B[1]),  .Sel(Sel), .OUT(OUT[1]));
Mux_2X1   bit2  (.A(A[2]),  .B(B[2]),  .Sel(Sel), .OUT(OUT[2]));
Mux_2X1   bit3  (.A(A[3]),  .B(B[3]),  .Sel(Sel), .OUT(OUT[3]));
Mux_2X1   bit4  (.A(A[4]),  .B(B[4]),  .Sel(Sel), .OUT(OUT[4]));
Mux_2X1   bit5  (.A(A[5]),  .B(B[5]),  .Sel(Sel), .OUT(OUT[5]));
Mux_2X1   bit6  (.A(A[6]),  .B(B[6]),  .Sel(Sel), .OUT(OUT[6]));
Mux_2X1   bit7  (.A(A[7]),  .B(B[7]),  .Sel(Sel), .OUT(OUT[7]));

endmodule
