module fract_unit(
		input  logic [22:0] i_fract_A,			// Mantissa of number A
		input  logic [22:0] i_fract_B,          // Mantissa of number B
		output logic [31:0] o_fract_diff,	    // Mantissa different extended to 32-bit
		output logic        o_fract_compare	    // HIGH to indicates fractr(B) > fract(A)
);

wire logic [31:0] extend_fract_A;
wire logic [31:0] extend_fract_B;
wire logic [31:0] fract_diff;
assign extend_fract_A = {9'b0, i_fract_A};
assign extend_fract_B = {9'b0, i_fract_B};

// Use 32-bit adder for 23-bit substraction
full_adder_32bit    different_adder   (.A(extend_fract_A),
                                       .B(extend_fract_B),
						               .Invert_B(1'b1),
						               .C_in(1'b1),
						               .Sum(fract_diff),
						               .C_out() );

assign o_fract_diff = fract_diff;
assign o_fract_compare = o_fract_diff[31];	// Extract sign bit

endmodule : fract_unit
	
