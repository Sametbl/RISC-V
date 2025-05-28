module full_adder_128bit (
		input  logic [127:0] A, B,    
		input  logic Invert_B, C_in,   
		output logic [127:0] Sum,
		output logic C_out
);
wire logic Connect;
full_adder_64bit  First (.A(A[63:0]),   .B(B[63:0]),   .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[63:0]),   .C_out(Connect));
full_adder_64bit  Second(.A(A[127:64]), .B(B[127:64]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[127:64]), .C_out(C_out) );
endmodule


