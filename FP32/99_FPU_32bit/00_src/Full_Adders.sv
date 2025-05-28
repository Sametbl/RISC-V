module Full_Adder_128bit (
		input  logic [127:0] A, B,    
		input  logic Invert_B, C_in,   
		output logic [127:0] Sum,
		output logic C_out
);
wire logic Connect;
Full_Adder_64bit  First (.A(A[63:0]),   .B(B[63:0]),   .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[63:0]),   .C_out(Connect));
Full_Adder_64bit  Second(.A(A[127:64]), .B(B[127:64]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[127:64]), .C_out(C_out) );
endmodule




module Full_Adder_64bit (
		input  logic [63:0] A, B,    
		input  logic Invert_B, C_in,   
		output logic [63:0] Sum,
		output logic C_out
);
wire logic Connect;
Full_Adder_32bit  First (.A(A[31:0]),  .B(B[31:0]),  .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[31:0]),  .C_out(Connect));
Full_Adder_32bit  Second(.A(A[63:32]), .B(B[63:32]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[63:32]), .C_out(C_out) );
endmodule



module Full_Adder_32bit (
		input  logic [31:0] A, B,    
		input  logic Invert_B, C_in,   
		output logic [31:0] Sum,
		output logic C_out
);
wire logic Connect;
Full_Adder_16bit  First (.A(A[15:0]),  .B(B[15:0]),  .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[15:0]),  .C_out(Connect));
Full_Adder_16bit  Second(.A(A[31:16]), .B(B[31:16]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[31:16]), .C_out(C_out) );
endmodule		




module Full_Adder_16bit (
		input  logic [15:0] A, B,    
		input  logic Invert_B, C_in,
		output logic [15:0] Sum,
		output logic C_out
);
wire logic Connect;
Full_Adder_8bit  First (.A(A[7:0]),  .B(B[7:0]),  .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[7:0]),  .C_out(Connect));
Full_Adder_8bit  Second(.A(A[15:8]), .B(B[15:8]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[15:8]), .C_out(C_out) );
endmodule							

//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
module Full_Adder_8bit(
		input  logic [7:0] A, B,
		input  logic Invert_B, C_in,        
		output logic [7:0] Sum,
		output logic C_out
);
wire logic Connect;
Full_Adder_4bit   fisrt (.A(A[3:0]), .B(B[3:0]), .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[3:0]), .C_out(Connect) );
Full_Adder_4bit   second(.A(A[7:4]), .B(B[7:4]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[7:4]), .C_out(C_out) );

endmodule



	//-----------------------------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------------------------
	
module Full_Adder_4bit(
		input  logic [3:0] A, B,
		input  logic Invert_B, C_in,        
		output logic [3:0] Sum,
		output logic C_out
);
wire logic [3:0] cout;  
Full_Adder 	digit1 (.A(A[0]), .B(B[0] ^ Invert_B), .Sum(Sum[0]), .C_in(C_in),    .C_out(cout[0]));
Full_Adder	digit2 (.A(A[1]), .B(B[1] ^ Invert_B), .Sum(Sum[1]), .C_in(cout[0]), .C_out(cout[1]));
Full_Adder 	digit3 (.A(A[2]), .B(B[2] ^ Invert_B), .Sum(Sum[2]), .C_in(cout[1]), .C_out(cout[2]));
Full_Adder 	digit4 (.A(A[3]), .B(B[3] ^ Invert_B), .Sum(Sum[3]), .C_in(cout[2]), .C_out(cout[3]));
assign C_out = cout[3];
endmodule

	
	
	
	
module Full_Adder(
		input  logic A, B, C_in,
		output logic Sum, C_out
);
// Sum   = [A] XOR [B] XOR [C_in]
// C_out = A.B + (  [C_in].([A] XOR [B])  ) 
assign Sum   =  A ^ B ^ C_in;
assign C_out = (A & B) | ( C_in & (A ^ B) );
endmodule




