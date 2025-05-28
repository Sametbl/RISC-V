module Mul_f_32bit (
			input  logic [31:0] A, B,
			output logic [31:0] Mul_f
);

wire logic [7:0] bias, exp_A, exp_B, sum_exp, New_exp, Final_exp;
wire logic [22:0] frac_A, frac_B;
wire logic [31:0] New_mantissa;
wire logic [63:0] mul_frac;
wire logic Carry;

assign frac_A = A[22:0];
assign frac_B = B[22:0];

assign bias = 8'b10000001; // bias = -127
Full_Adder_8bit    biased_A     (.A(A[30:23]), .B(bias),  .Invert_B(1'b0), .C_in(1'b0), .Sum(exp_A),   .C_out() );
Full_Adder_8bit    biased_B     (.A(B[30:23]), .B(bias),  .Invert_B(1'b0), .C_in(1'b0), .Sum(exp_B),   .C_out() );
Full_Adder_8bit    initial_exp  (.A(exp_A),    .B(exp_B), .Invert_B(1'b0), .C_in(1'b0), .Sum(sum_exp), .C_out() );

// Extend to 32-bit (leading 1 included)
Multiplier_32X32   Mul_mantissa (.A({8'b0, 1'b1, frac_A}), .B({8'b0, 1'b1, frac_B}), .S(mul_frac) );

// mul_frac characteristic:
// 	24-bit x 24-bit = 48-bit   (2^24 x 2^24 = 2^48)
// 	There is always the leading 1 (24th bit) 
// 	There is always the bit 47th (the new leading 1)
// 	bit 48th is the carry 
//		There never be the 49th bit because (2^48 - 1) > (2^24 -1) x (2^24 -1)

assign Carry = mul_frac[47];

Mux_2X1_32bit      Nomallize (.Sel(Carry), .A({9'b0, mul_frac[45:23]}), .B({9'b0, mul_frac[46:24]}), .OUT(New_mantissa) );
Full_Adder_8bit    EXP_inc   (.A(sum_exp), .B(8'b0), .Invert_B(1'b0),  .C_in(Carry), .Sum(New_exp),   .C_out() );
Full_Adder_8bit    final_exp (.A(New_exp), .B(bias),  .Invert_B(1'b1), .C_in(1'b1),  .Sum(Final_exp), .C_out() );



assign Mul_f[30:23] = Final_exp;
assign Mul_f[22:0]  = New_mantissa[22:0];
assign Mul_f[31]    = A[31] ^ B[31];

endmodule








