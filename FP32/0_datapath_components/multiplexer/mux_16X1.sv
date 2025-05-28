module mux_16X1(
		input  logic [3:0] sel,
		input  logic [15:0] D,
		output logic Y
);
wire logic Top, Bottom;
mux_8X1		Layer1_1 (.sel(sel[2:0]), .D(D[7:0]),  .Y(Bottom));
mux_8X1		Layer1_2 (.sel(sel[2:0]), .D(D[15:8]), .Y(Top));
mux_2X1		Layer2   (.sel(sel[3]), .A(Bottom), .B(Top), .Y(Y));								
							
endmodule 

