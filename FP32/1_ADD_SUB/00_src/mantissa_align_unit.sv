module mantissa_align_unit( 
		input  logic        i_enable_n,			// Negedge enable
		input  logic        i_is_subnormal,   	// Negedge enable
		input  logic [7:0]  i_shift_amount,  
		input  logic [31:0] i_fract,
		output logic [31:0] o_fract
);

wire logic [31:0] temp_float;	// Temporary floating point
wire logic [4:0]  shamt;		// Shift_amount for shifter
wire logic        enable;

// Shifted small frac = 0 when once of A or B is zero or the shamt > 32. 
assign enable = i_shift_amount[7] | i_shift_amount[6] | i_shift_amount[5] | i_enable_n;
assign shamt  = i_shift_amount[4:0] | {5{enable}}; 

// temp_float = Leading 1 ++ Fractional part ++ Extra bit 
assign temp_float[31:24] = 8'b0;             // zero extend
assign temp_float[23]    = ~i_is_subnormal;  // leading 1
assign temp_float[22:0]  = i_fract[22:0];    // the fraction

// Right shift (to increase exp)
shifter_32bit  New_small_fract  (.data_in(temp_float),
                                 .shift_amount(shamt),
								 .mode(2'b00),				// mode = 0: right shifter
								 .data_out(o_fract) );
	
endmodule : mantissa_align_unit

