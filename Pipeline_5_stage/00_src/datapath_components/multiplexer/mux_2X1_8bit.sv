module mux_2X1_8bit(
	input  logic sel,
	input  logic [7:0] A, B,
	output logic [7:0] Y
);

mux_2X1   bit0  (.A(A[0]),  .B(B[0]),  .sel(sel), .Y(Y[0]));
mux_2X1   bit1  (.A(A[1]),  .B(B[1]),  .sel(sel), .Y(Y[1]));
mux_2X1   bit2  (.A(A[2]),  .B(B[2]),  .sel(sel), .Y(Y[2]));
mux_2X1   bit3  (.A(A[3]),  .B(B[3]),  .sel(sel), .Y(Y[3]));
mux_2X1   bit4  (.A(A[4]),  .B(B[4]),  .sel(sel), .Y(Y[4]));
mux_2X1   bit5  (.A(A[5]),  .B(B[5]),  .sel(sel), .Y(Y[5]));
mux_2X1   bit6  (.A(A[6]),  .B(B[6]),  .sel(sel), .Y(Y[6]));
mux_2X1   bit7  (.A(A[7]),  .B(B[7]),  .sel(sel), .Y(Y[7]));

endmodule

