module sign_bit(
		input  logic exp_AB, frac_AB,
		input  logic A_signbit, B_signbit, Mode, same_exp,
		output logic Sign				 // SIGN = 1: Negative
);

wire logic same_expo, sign_A, sign_B;

assign sign_B = Mode ^ B_signbit;      // Toggle sign of B in substraction mode
assign sign_A = A_signbit;

// If same_exp = 0: SIGN = sign_B when Exp_diff < 0
//                  SIGN = sign_A when Exp_diff > 0
// If same_exp = 1: SIGN = sign_B when Frac_diff < 0
//                  SIGN = sign_A when Frac_diff > 0 

// exp_AB  = 1: exp_B  > exp_A
// frac_AB = 1: frac_B > frac_A
assign Sign = (  ~same_exp & (exp_AB  & sign_B | ~exp_AB  & sign_A)  ) | 
              (   same_exp & (frac_AB & sign_B | ~frac_AB & sign_A)  );

endmodule





