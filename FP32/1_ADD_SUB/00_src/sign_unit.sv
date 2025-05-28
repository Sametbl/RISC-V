module sign_unit(
		input  logic i_mode,				// HIGH indicate subtraction mode
		input  logic i_sign_bit_A, 			// sign bit of number A
		input  logic i_sign_bit_B,			// sign bit of number B
		input  logic i_same_exp,			// HIGH to indicates exp(B)   = exp(A)				
		input  logic i_exp_compare,			// HIGH to indicates exp(B)   > exp(A)
		input  logic i_fract_compare,		// HIGH to indicates fract(B) > fract(A)
		output logic o_sign				 // SIGN = 1: Negative
);

wire logic sign_A, sign_B;
wire logic case_1, case_2;
assign sign_B = i_sign_bit_B ^ i_mode;      // Toggle sign of B in substraction mode
assign sign_A = i_sign_bit_A;

// For substraction mode (still true for addition mode):
// Case 1: If i_same_exp = 0: SIGN = sign_B when exp(B) > exp(A)
//                            SIGN = sign_A when exp(B) < exp(A)
assign case_1 = ~i_same_exp & (i_exp_compare & sign_B | ~i_exp_compare & sign_A);


// Case 2: If i_same_exp = 1: SIGN = sign_B when fract(B) > fract(A)
//                            SIGN = sign_A when fract(B) < fract(A)

assign case_2 = i_same_exp & (i_fract_compare & sign_B | ~i_fract_compare & sign_A);

// Output
assign o_sign = case_1 | case_2; 
       
endmodule : sign_unit





