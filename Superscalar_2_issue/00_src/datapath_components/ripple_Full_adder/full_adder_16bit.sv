module full_adder_16bit (
		input  logic [15:0] A, B,    
		input  logic Invert_B, C_in,
		output logic [15:0] Sum,
		output logic C_out
);
wire logic Connect;
full_adder_8bit  First (.A(A[7:0]),  .B(B[7:0]),  .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[7:0]),  .C_out(Connect));
full_adder_8bit  Second(.A(A[15:8]), .B(B[15:8]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[15:8]), .C_out(C_out) );
endmodule							

