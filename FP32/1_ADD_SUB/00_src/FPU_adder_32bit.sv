module FPU_adder_32bit(
		input  logic [31:0] A, 
		input  logic [31:0] B, 
		input  logic        mode,
		output logic [31:0] S,
		output logic        overflow,
        output logic        underflow,
        output logic        zero,
        output logic        NaN 
);															

// --------------------------------------------------------------
// Extract data from Inputs
wire logic [22:0] fract_A, fract_B;
wire logic [7:0]  exp_A,  exp_B;
wire logic        zero_A;
wire logic        zero_B;

assign fract_A = A[22:0];
assign fract_B = B[22:0];
assign exp_A   = A[30:23];
assign exp_B   = B[30:23];

// --------------------------------------------------------------
// Determining A or B is larger/smaller
wire logic [31:0] mantissa_A;   // Extend to 32-bit
wire logic [31:0] mantissa_B;   // Extend to 32-bit
wire logic [31:0] large_mantissa;
wire logic [31:0] small_mantissa; // Only need 23 bits, but use 32 bit for convenient
wire logic [31:0] fract_dif;
wire logic [7:0]  shift_amount;
wire logic [7:0]  smaller_exp;
wire logic [7:0]  larger_exp;
wire logic [7:0]  exp_dif_2s;
wire logic [7:0]  exp_dif;
wire logic        fract_compare;  // exp_compare = 1 => exp_B > exp_A (fract_compare similarly)
wire logic        exp_compare;
wire logic        same_exp;
wire logic        mux_sel;

exp_unit          compare_exp  (.i_exp_A(exp_A),
                                .i_exp_B(exp_B),
                                .o_exp_diff(exp_dif),
                                .o_exp_compare(exp_compare),
                                .o_same_exp(same_exp)
);

fract_unit        compare_fract(.i_fract_A(fract_A),
                                .i_fract_B(fract_B),
                                .o_fract_diff(fract_dif),        // Extend to 32-bit
                                .o_fract_compare(fract_compare)
);

full_adder_8bit   complement_2 (.A(8'b0),
                                .B(exp_dif),
                                .Invert_B(1'b1),
                                .C_in(1'b1),
                                .Sum(exp_dif_2s),
                                .C_out()
);

assign mantissa_A = {9'b0, fract_A};
assign mantissa_B = {9'b0, fract_B};
assign mux_sel    = (~same_exp & exp_compare) | (same_exp & fract_compare); // when B > A

mux_2X1_8bit	 Large_exp   (.sel(mux_sel), .A(exp_A),      .B(exp_B),      .Y(larger_exp)     );
mux_2X1_8bit	 Small_exp   (.sel(mux_sel), .A(exp_B),      .B(exp_A),      .Y(smaller_exp)     );
mux_2X1_32bit	 Bigger_Num  (.sel(mux_sel), .A(mantissa_A), .B(mantissa_B), .Y(large_mantissa) );
mux_2X1_32bit	 Smaller_Num (.sel(mux_sel), .A(mantissa_B), .B(mantissa_A), .Y(small_mantissa) );
mux_2X1_8bit	 Shift_size  (.sel(mux_sel), .A(exp_dif),    .B(exp_dif_2s), .Y(shift_amount)   );


// --------------------------------------------------------------
// Right Shift the smaller float according to align the exponent of bigger float
wire logic [31:0] small_mantissa_aligned;
wire logic        shift_enable;
wire logic        sub_normal;
assign sub_normal = ~(|smaller_exp);
assign shift_enable = zero_A | zero_B;

mantissa_align_unit    Shift_fract  (.i_fract(small_mantissa),
                                     .i_enable_n(shift_enable),
                                     .i_is_subnormal(sub_normal),
                                     .i_shift_amount(shift_amount),
                                     .o_fract(small_mantissa_aligned)
);


// --------------------------------------------------------------
// Compute resulting mantissa
wire logic [31:0] large_mantissa_extended;
wire logic [31:0] temp_fract;
wire logic        sub_mode;

// Extend Bigger float's mantissa to 32 bit and include the leading_1
assign large_mantissa_extended = {8'b0, 1'b1, large_mantissa[22:0]}; 

// When Same sign but mode = 1	|| Difference sign but Mode = 0 
assign sub_mode  = A[31] ^ (B[31] ^ mode); 

full_adder_32bit    Different_adder (.A(large_mantissa_extended),
                                     .B(small_mantissa_aligned),
                                     .Invert_B(sub_mode),
                                     .C_in(sub_mode),
                                     .Sum(temp_fract),
                                     .C_out()
);

// --------------------------------------------------------------
// Normalize Computed mantissa
wire logic [22:0] result_fract;
wire logic [7:0]  result_exp;
wire logic        zero_normalize;
wire logic        overflow_normalize;
wire logic        underflow_normalize;
	
normalization_unit  Normalization  (.i_fract      (temp_fract)        ,
                                    .i_larger_exp (larger_exp)        , 
                                    .o_exp        (result_exp)        ,
                                    .o_mantissa   (result_fract)       ,
                                    .o_zero_detect(zero_normalize)    ,
                                    .o_overflow   (overflow_normalize), 
                                    .o_underflow  (underflow_normalize)
);

// --------------------------------------------------------------
// Determining the sign	
wire logic result_sign;

sign_unit    Result_sign   (.i_mode(mode),				
                            .i_sign_bit_A(A[31]), 	
                            .i_sign_bit_B(B[31]),	
                            .i_same_exp(same_exp),					
                            .i_exp_compare(exp_compare),	
                            .i_fract_compare(fract_compare),	
                            .o_sign(result_sign)				
);



// --------------------------------------------------------------
// Determining the Zero, Overflow and Underflow	
wire logic overflow_exception;
wire logic zero_exception;
wire logic NaN_format;

exception_handler  format_exception (.i_float_A(A),
                                     .i_float_B(B),
                                     .i_sub_mode(sub_mode),
                                     .o_overflow(overflow_exception),
                                     .o_zero(zero_exception),
                                     .o_NaN(NaN_format)
);



// Output 
assign underflow = underflow_normalize;
assign overflow  = overflow_normalize  | overflow_exception ;
assign zero      = zero_normalize      | zero_exception     ;
assign NaN       = NaN_format;

assign S[31]    =   result_sign;
assign S[30:23] =  (result_exp   & {8 {~(underflow | zero)   }}) | {8{overflow | NaN}};
assign S[22]    =   result_fract[22]   &     ~(underflow | overflow) | NaN; 
assign S[21:0]  =   result_fract[21:0] & {22{~(underflow | overflow)}};
endmodule
