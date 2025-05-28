module mux_8X1(
	 input  logic [2:0] sel,
	 input  logic [7:0] D,
	 output logic Y
);
 logic Bottom, Top;
 mux_4X1	Layer1_1 (.sel(sel[1:0]), .D(D[3:0]), .Y(Bottom));
 mux_4X1 	Layer1_2 (.sel(sel[1:0]), .D(D[7:4]), .Y(Top));
 mux_2X1	Layer2   (.sel(sel[2]), .A(Bottom), .B(Top), .Y(Y));
endmodule

