module exception_handler(
        input  logic [31:0] i_float_A,
        input  logic [31:0] i_float_B,
        input  logic        i_sub_mode,
        output logic        o_overflow,
        output logic        o_zero,
        output logic        o_NaN
);

// Rename signal
wire logic [31:0] A, B;
assign A = i_float_A;
assign B = i_float_B;


// Check for Infinity (Exp = 8'hFF)
wire logic   inf_A;
wire logic   inf_B;
assign inf_A = A[30] & A[29] & A[28] & A[27] & A[26] & A[25] & A[24] & A[23]; 
assign inf_B = B[30] & B[29] & B[28] & B[27] & B[26] & B[25] & B[24] & B[23];

// Check for Zero exponent (exp = 8'b0)
wire logic   zero_exp_A;
wire logic   zero_exp_B;
assign zero_exp_A = ~(A[30] | A[29] | A[28] | A[27] | A[26] | A[25] | A[24] | A[23]);  
assign zero_exp_B = ~(B[30] | B[29] | B[28] | B[27] | B[26] | B[25] | B[24] | B[23]);

// Check for Zero Mantissa (Mantissa = 23'b0)
wire logic   zero_mant_A;
wire logic   zero_mant_B;
assign zero_mant_A = ~(A[22] | A[21] | A[20] | A[19] | A[18] | A[17] | A[16] | A[15] | 
                       A[14] | A[13] | A[12] | A[11] | A[10] | A[9]  | A[8]  | A[7]  | 
                       A[6]  | A[5]  | A[4]  | A[3]  | A[2]  | A[1]  | A[0] );

assign zero_mant_B = ~(B[22] | B[21] | B[20] | B[19] | B[18] | B[17] | B[16] | B[15] | 
                       B[14] | B[13] | B[12] | B[11] | B[10] | B[9]  | B[8]  | B[7]  | 
                       B[6]  | B[5]  | B[4]  | B[3]  | B[2]  | B[1]  | B[0] );


// Check for NaN, Zero and Infinity cases
wire logic  NaN_A;
wire logic  NaN_B;	
wire logic  zero_A;
wire logic  zero_B;
wire logic  NaN_exception;

assign NaN_A  = inf_A & ~zero_mant_A;  // NaN number format
assign NaN_B  = inf_B & ~zero_mant_B;
assign zero_A = zero_exp_A & zero_mant_A;
assign zero_B = zero_exp_B & zero_mant_B;
assign NaN_exception = (inf_A & inf_B & i_sub_mode);  // Infinity - Infinity


// OUTPUT

assign o_NaN      =  NaN_A | NaN_B | NaN_exception; 
assign o_overflow = ~o_NaN  & (inf_A  | inf_B);
assign o_zero     = ~o_NaN  & (zero_A & zero_B); 
     		
endmodule : exception_handler
