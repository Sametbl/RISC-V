module normalization_unit( 
		input  logic [7:0]  i_larger_exp,  
		input  logic [31:0] i_fract,
		output logic [7:0]  o_exp,
		output logic [22:0] o_mantissa,
		output logic        o_zero_detect,
		output logic        o_overflow, 
		output logic        o_underflow
);
// -------------------------------------------------------------
// --------------- COUNT NUMBER OF LEADING 0 -------------------

// i_fract = [ {7'b0}, {leading_2}, {leading_1}, {Mantissa} ]
wire logic        leading_2;       // Indicate carry-bit after adding two leading_1
wire logic        zero_fract;      // Indicate input fract is all zero before leading_2
wire logic [4:0]  NLZ;             // Number of Leading Zero before leading_1
wire logic [31:0] shift8_temp;     // Left shift input fract by 8 to counts leading 0  

assign leading_2    =  i_fract[24]; 
assign shift8_temp  = {i_fract[23:0], 8'b0};
LZC_32bit   LZ_counter (.i_data(shift8_temp), .o_NLZ(NLZ), .o_all_zero(zero_fract));

// ---------------------------------------------------------------
// --------------- SHIFT MANTISSA TO LEADING 1 -------------------
wire logic [31:0] shifted_fract;
wire logic [4:0]  shift_amount;		
wire logic [1:0]  shift_mode;		// shift_mode = 2'00: Right shift
                                    // shift_mode = 2'01: Left shift
assign shift_mode[1] = 1'b0;
assign shift_mode[0] = ~leading_2;

// if leading-2 exist, shift left once (shift_amount = 1)
// else right shift (shift_amount = number of leading 0 before leading_1)      
assign shift_amount[0] = NLZ[0] |  leading_2; 
assign shift_amount[1] = NLZ[1] & ~leading_2;	 
assign shift_amount[2] = NLZ[2] & ~leading_2;
assign shift_amount[3] = NLZ[3] & ~leading_2;
assign shift_amount[4] = NLZ[4] & ~leading_2;

shifter_32bit     Normalize_frac (.data_in(i_fract),
								  .mode(shift_mode),
                                  .shift_amount(shift_amount),
								  .data_out(shifted_fract)
);		

// -----------------------------------------------------------------
// ---------------  COMPUTE EXPONENT AFTER SHIFT -------------------
wire logic [7:0]  increased_exp;
wire logic [7:0]  added_exp;
wire logic        connect_1;		// FAs connection
wire logic        connect_2;        // FAs connection
wire logic        carry_bit;        // carry bit of combined 10-bit FA adder
wire logic        sign_bit;         // sign  bit of combined 10-bit FA adder
wire logic        inf;			    // Indicate added_exp = 8'hFF (infinity)

assign increased_exp = {3'b000, shift_amount};
// Extend to 10-bit full_adder
// 9th  Full_Adder: check for o_overflow  (exp > 255)
// 10th Full_Adder: check for o_underflow (exp < 0), acts as sign bit
full_adder_8bit   New_exp          (.A(i_larger_exp),
                                    .B(increased_exp),
									.Invert_B(~leading_2),
									.C_in(~leading_2),
									.Sum(added_exp),
									.C_out(connect_1)
); 
full_adder        Overflow_adder   (.A(1'b0),
                                    .B(~leading_2),
									.C_in(connect_1),
									.Sum(carry_bit),
									.C_out(connect_2)
);
full_adder        Underflow_adder  (.A(1'b0),
                                    .B(~leading_2),
                                    .C_in(connect_2),
                                    .Sum(sign_bit),
                                    .C_out()
);

assign inf = added_exp[7] & added_exp[6] & added_exp[5] & added_exp[4] &
             added_exp[3] & added_exp[2] & added_exp[1] & added_exp[0]; 



// Output 
assign o_exp         = added_exp;
assign o_mantissa    = shifted_fract[22:0];
assign o_zero_detect = zero_fract & ~leading_2;   
assign o_underflow   = sign_bit;		               // added_exp is negative
assign o_overflow    = (carry_bit & ~sign_bit) | inf;  // added_exp is possible but above 8'hFF
			
endmodule : normalization_unit

						
