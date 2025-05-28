module full_adder(
		input  logic A, B, C_in,
		output logic Sum, C_out
);
// Sum   = [A] XOR [B] XOR [C_in]
// C_out = A.B + (  [C_in].([A] XOR [B])  ) 
assign Sum   =  A ^ B ^ C_in;
assign C_out = (A & B) | ( C_in & (A ^ B) );
endmodule




