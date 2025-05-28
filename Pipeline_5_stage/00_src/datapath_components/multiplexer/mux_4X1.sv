module mux_4X1(
	 input  logic [1:0] sel,
	 input  logic [3:0] D,
	 output logic Y
);
wire logic Top, Bottom;
mux_2X1      Layer1_1 (.sel(sel[0]), .A(D[0]),   .B(D[1]), .Y(Bottom));
mux_2X1      Layer1_2 (.sel(sel[0]), .A(D[2]),   .B(D[3]), .Y(Top));
mux_2X1      Layer2   (.sel(sel[1]), .A(Bottom), .B(Top),  .Y(Y));
endmodule

