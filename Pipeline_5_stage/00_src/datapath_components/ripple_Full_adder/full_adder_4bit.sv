module full_adder_4bit(
		input  logic [3:0] A, B,
		input  logic Invert_B, C_in,        
		output logic [3:0] Sum,
		output logic C_out
);
wire logic [3:0] cout;  
full_adder 	digit1 (.A(A[0]), .B(B[0] ^ Invert_B), .Sum(Sum[0]), .C_in(C_in),    .C_out(cout[0]));
full_adder	digit2 (.A(A[1]), .B(B[1] ^ Invert_B), .Sum(Sum[1]), .C_in(cout[0]), .C_out(cout[1]));
full_adder 	digit3 (.A(A[2]), .B(B[2] ^ Invert_B), .Sum(Sum[2]), .C_in(cout[1]), .C_out(cout[2]));
full_adder 	digit4 (.A(A[3]), .B(B[3] ^ Invert_B), .Sum(Sum[3]), .C_in(cout[2]), .C_out(cout[3]));
assign C_out = cout[3];
endmodule

	
