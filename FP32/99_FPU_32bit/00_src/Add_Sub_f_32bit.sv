module Add_Sub_f_32bit(
		input  logic [31:0] A, B, 
		input  logic mode, zero_A, zero_B,
		output logic [31:0] Add_Sub_f,
		output logic Zero_Sub
);															

wire logic [7:0] exp_A, exp_B;
wire logic [22:0] frac_A, frac_B;
assign exp_A  = A[30:23];
assign exp_B  = B[30:23];
assign frac_A = A[22:0];
assign frac_B = B[22:0];

// Determining A or B is larger/smaller
wire logic [31:0] frac_diff;
wire logic [7:0] exp_diff, exp_dif_2s, shift_N;
wire logic C_mux, same_exp, exp_AB , frac_AB;  //Exp_AB = 1 => Exp_B > Exp_A (Frac_AB similarly)

expo_diff         exp_compare  (.Exp_A(exp_A),   .Exp_B(exp_B),   .Exp_diff(exp_diff),   .Co(exp_AB), .Same_exp(same_exp) );
frac_diff         frac_compare (.Frac_A(frac_A), .Frac_B(frac_B), .frac_diff(frac_diff), .Co(frac_AB) );
Full_Adder_8bit   complement_2 (.A(8'b0), .B(exp_diff), .Invert_B(1'b1), .C_in(1'b1), .Sum(exp_dif_2s), .C_out() );

wire logic [31:0] big_frac, smol_frac; //Only need 23 bits, but use 32 bit for convenient
assign C_mux = (~same_exp & exp_AB) | (same_exp & frac_AB);

Mux_2X1_8bit	 Shift_size  (.Sel(C_mux), .A(exp_diff), .B(exp_dif_2s), .OUT(shift_N) );
Mux_2X1_32bit	 Bigger_Num  (.Sel(C_mux), .A({9'b0, frac_A}), .B({9'b0, frac_B}), .OUT(big_frac)  );
Mux_2X1_32bit	 Smaller_Num (.Sel(C_mux), .A({9'b0, frac_B}), .B({9'b0, frac_A}), .OUT(smol_frac) );



// Right Shift the smaller float according to match the exponent of bigger float (leading 1 included)
wire logic [31:0] Shifted_smol_frac;
wire logic Make_zero;
assign Make_zero = zero_A | zero_B | shift_N[5] | shift_N[6] | shift_N[7]; // Set shifted small frac = 0
S_frac_shift    Shift_Frac  (.S_fract(smol_frac), .shift_amount(shift_N[4:0]), .Make_zero(Make_zero), .Shifted_fract(Shifted_smol_frac) );


// Compute resulting mantissa
wire logic [31:0] Temp_frac, Extend_big_frac;
wire logic [7:0] larger_exp;
wire logic Sub;
assign Extend_big_frac = {8'b0, 1'b1, big_frac[22:0]}; // Extend Bigger float's mantissa to 32 bit and include the leading 1
assign Sub = A[31] ^ (B[31] ^ mode); // When Same sign but Mode = 1	 OR Difference sign but Mode = 0 

Full_Adder_32bit    Diff (.A(Extend_big_frac), .B(Shifted_smol_frac), .Invert_B(Sub), .C_in(Sub), .Sum(Temp_frac), .C_out() );



// Normalize Computed mantissa
Mux_2X1_8bit	 Large_exp (.Sel(C_mux), .A(exp_A), .B(exp_B), .OUT(larger_exp) );
Normalize       Normalize (.Larger_exp(larger_exp),    .Temp_frac(Temp_frac),
                           .Result_exp(Add_Sub_f[30:23]), .Result_frac(Add_Sub_f[22:0]),
                           .Zero_detect(Zero_Sub) );
	
	
// Determining the sign	
sign_bit       Result_sign(.exp_AB(exp_AB), .frac_AB(frac_AB), .Mode(mode), .same_exp(same_exp),
                           .A_signbit(A[31]),   .B_signbit(B[31]),     .Sign(Add_Sub_f[31]) );

									

endmodule
