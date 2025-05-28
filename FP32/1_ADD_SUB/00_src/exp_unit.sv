module exp_unit(
		input  logic [7:0] i_exp_A,		     // Signed exponent of A
		input  logic [7:0] i_exp_B,  	     // Signed exponent of B
		output logic [7:0] o_exp_diff,	     // Signed output exponential different
		output logic       o_same_exp,       // HIGH to indicates exp(B) = exp(A)
		output logic       o_exp_compare     // HIGH to indicates exp(B) > exp(A)
);

wire logic [7:0] exp_diff;
wire logic       connect;
wire logic       sign_bit;

// Combine Full_Adder 8-bit and 1-bit to form 9-bit Full_Adder
// Performing 9-bit operation: exp(A) - exp(B)

full_adder_8bit  different_adder (.A(i_exp_A),
                                  .B(i_exp_B),
                                  .Invert_B(1'b1),     // 2'complement: Invert B
                                  .C_in(1'b1),         // 2'complement: Add 1 to the inverted B
                                  .Sum(exp_diff),
                                  .C_out(connect)
);
full_adder      sign_adder       (.A(1'b0),            // Extend A to 9-bit
                                  .B(1'b1),            // Extend B to 9-bit (and inverted)
                                  .C_in(connect),      // Connect between adders
                                  .Sum(sign_bit),      // Sign bit of the 9-bit operation
                                  .C_out()
);

// Outrput
assign o_exp_compare = sign_bit;
assign o_exp_diff    = exp_diff;
assign o_same_exp    = ~(o_exp_diff[0] | o_exp_diff[1] |	// Check if exp(A) = exp(B)
                         o_exp_diff[2] | o_exp_diff[3] |
                         o_exp_diff[4] | o_exp_diff[5] |
					     o_exp_diff[6] | o_exp_diff[7]); 


endmodule : exp_unit










