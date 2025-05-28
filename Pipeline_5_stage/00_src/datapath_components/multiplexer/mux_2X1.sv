module mux_2X1(
	 input  logic A, B,
	 input  logic sel,
	 output logic Y
);
assign Y = (A & ~sel) | (B & sel);
endmodule


