module FPU_mul_32bit (
			input  logic [31:0] A,
			input  logic [31:0] B,
			output logic [31:0] S,
			output logic        overflow,
			output logic        underflow,
			output logic        zero,
			output logic        NaN
);

// Extract data from Inputs
wire logic [7:0]  exp_A;
wire logic [7:0]  exp_B;
wire logic [22:0] fract_A;
wire logic [22:0] fract_B;

assign fract_A = A[22:0];
assign fract_B = B[22:0];
assign exp_A  = A[30:23];
assign exp_B  = B[30:23];

// Calculate the initial exponent sum
wire logic [7:0]  exp_A_dec;       // Unbiased exponent A 
wire logic [7:0]  exp_B_dec;       // Unbiased exponent B 
wire logic [7:0]  bias;            // Biased number
wire logic [7:0]  sum_exp_tmp;

assign bias = 8'b10000001; // bias = -127
full_adder_8bit   biased_A    (.A(exp_A), .B(bias), .Invert_B(1'b0), .C_in(1'b0), .Sum(exp_A_dec), .C_out() );
full_adder_8bit   biased_B    (.A(exp_B), .B(bias), .Invert_B(1'b0), .C_in(1'b0), .Sum(exp_B_dec), .C_out() );
full_adder_8bit   initial_exp (.A(exp_A_dec),
                               .B(exp_B_dec),
                               .Invert_B(1'b0),
                               .C_in(1'b0),
                               .Sum(sum_exp_tmp),
                               .C_out()
);

// Multiply Mantissa
// Extend to 32-bit (leading 1 included)
wire logic [63:0] mul_mantissa;
wire logic [31:0] mantissa_A;       // Extended to 32-bit
wire logic [31:0] mantissa_B;       // Extended to 32-bit
assign mantissa_A = {8'b0, 1'b1, fract_A};
assign mantissa_B = {8'b0, 1'b1, fract_B};
multiplier_32X32   Mantissa_mul  (.A(mantissa_A), .B(mantissa_B), .S(mul_mantissa) );


//  mul_mantissa characteristic:
// 	24-bit x 24-bit = 48-bit   (2^24 x 2^24 = 2^48)
// 	There is always the leading 1 (24th bit) 
// 	There is always the bit 47th (the new leading 1)
// 	bit 48th is the carry 
//	There never be the 49th bit because (2^48 - 1) > (2^24 -1) x (2^24 -1)

wire logic [31:0] new_mantissa;
wire logic        carry;

assign carry = mul_mantissa[47];
mux_2X1_32bit  Carry_sel    (.sel(carry),
                             .A({9'b0, mul_mantissa[45:23]}),
                             .B({9'b0, mul_mantissa[46:24]}),
                             .Y(new_mantissa) );


// Normalize the result
wire logic [7:0]  result_exp;
wire logic [7:0]  result_exp_biased;

full_adder_8bit    EXP_inc   (.A(sum_exp_tmp),
                              .B(8'b0),
                              .Invert_B(1'b0),
                              .C_in(carry),
                              .Sum(result_exp),
                              .C_out() );


full_adder_8bit    final_exp (.A(result_exp),
                              .B(bias),
                              .Invert_B(1'b1),
                              .C_in(1'b1),
                              .Sum(result_exp_biased),
                              .C_out() );


// Determine the special cases
wire logic    overflow_format;
wire logic    NaN_exception;
wire logic    zero_format;
wire logic    NaN_format;

exception_handler  format_exception (.i_float_A(A),
                                     .i_float_B(B),
                                     .o_overflow(overflow_format),
                                     .o_NaN(NaN_format),
                                     .o_zero()
);


wire logic  zero_mantissa_mul;
wire logic  inf_mul;
wire logic  zero_A;
wire logic  zero_B;
wire logic  inf_A;
wire logic  inf_B;


assign zero_A = ~(|A[30:0]);
assign zero_B = ~(|B[30:0]);
assign inf_A  = ~(|A[30:23]);
assign inf_B  = ~(|B[30:23]);

assign zero_mantissa_mul  = ~(|new_mantissa[22:0]);
assign inf_mul            = &result_exp_biased;

assign NaN_exception = (inf_mul & ~zero_mantissa_mul) |
                       (inf_A   &  zero_B) |
                       (inf_B   &  zero_A);   // zero X Infinity
  				

// OUTPUT
assign overflow  = ~NaN & (inf_A  | inf_B | inf_mul) | overflow_format;
assign underflow = 1'b0; // Reserved
assign NaN       =  NaN_format | NaN_exception;
assign zero      = ~NaN & (zero_A | zero_B); 

assign S[30:23] = result_exp_biased  & { 8{~(zero_A | zero_B)}};
assign S[22:0]  = new_mantissa[22:0] & {23{~(zero_A | zero_B)}};
assign S[31]    = A[31] ^ B[31];

endmodule








