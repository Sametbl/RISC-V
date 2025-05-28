module mux_32X1(
		input  logic [4:0] sel,
		input  logic [31:0] D,
		output logic Y
);
wire logic Top, Bottom;
mux_16X1	 Layer1_1 (.sel(sel[3:0]), .D(D[15:0]),  .Y(Bottom));
mux_16X1	 Layer1_2 (.sel(sel[3:0]), .D(D[31:16]), .Y(Top));
mux_2X1		 Layer2   (.sel(sel[4]), .A(Bottom), .B(Top), .Y(Y));											
endmodule 

