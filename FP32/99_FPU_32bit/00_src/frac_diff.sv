module frac_diff(
		input  logic [22:0] Frac_A, Frac_B, 
		output logic [31:0] frac_diff,
		output logic Co
);

Full_Adder_32bit   Diff (.A({9'b0, Frac_A}), .B({9'b0, Frac_B}), .Invert_B(1'b1), .C_in(1'b1), .Sum(frac_diff), .C_out() );

assign Co = frac_diff[31];

endmodule
	