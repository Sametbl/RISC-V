module expo_diff(
		input  logic [7:0] Exp_A, Exp_B,   // both are signed 
		output logic [7:0] Exp_diff,
		output logic Same_exp, Co     // C_out = 1, choose B (Exp_B > Exp_A)
);

// Combine Full_Adder 8bit and 1bit to form 9-bit Full_Adder
wire logic Connect;
Full_Adder_8bit  diff (.A(Exp_A), .B(Exp_B), .Invert_B(1'b1), .C_in(1'b1),    .Sum(Exp_diff), .C_out(Connect) );
Full_Adder       sign (.A(1'b0),  .B(1'b1), .C_in(Connect), .Sum(Co), .C_out() );

assign Same_exp  = ~(Exp_diff[0] | Exp_diff[1] | Exp_diff[2] | Exp_diff[3] |
                     Exp_diff[4] | Exp_diff[5] | Exp_diff[6] | Exp_diff[7]	); 
endmodule










