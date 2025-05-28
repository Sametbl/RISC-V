module full_adder_8bit(
		input  logic [7:0] A, B,
		input  logic Invert_B, C_in,        
		output logic [7:0] Sum,
		output logic C_out
);
wire logic Connect;
full_adder_4bit   fisrt (.A(A[3:0]), .B(B[3:0]), .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[3:0]), .C_out(Connect) );
full_adder_4bit   second(.A(A[7:4]), .B(B[7:4]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[7:4]), .C_out(C_out) );

endmodule




