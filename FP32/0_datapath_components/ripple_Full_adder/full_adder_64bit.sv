module full_adder_64bit (
		input  logic [63:0] A, B,    
		input  logic Invert_B, C_in,   
		output logic [63:0] Sum,
		output logic C_out
);
wire logic Connect;
full_adder_32bit  First (.A(A[31:0]),  .B(B[31:0]),  .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[31:0]),  .C_out(Connect));
full_adder_32bit  Second(.A(A[63:32]), .B(B[63:32]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[63:32]), .C_out(C_out) );
endmodule


