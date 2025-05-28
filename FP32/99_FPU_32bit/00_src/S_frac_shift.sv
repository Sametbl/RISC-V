module S_frac_shift( 
		input  logic [31:0] S_fract,
		input  logic [4:0] shift_amount,  
		input  logic Make_zero,
		output logic [31:0] Shifted_fract
);
// Number of shift is expected range: 0 -> 6 (max exp difference = -3 to 3)
// temp = Leading 1 ++ Fractional part ++ Extra bit 

wire logic [31:0] temp;
wire logic [4:0] shamt;
assign temp[31:24] = 8'b0;  // zero extend
assign temp[23]    = 1'b1;  // leading 1
assign temp[22:0]  = S_fract[22:0]; // the fraction

// Shifted small frac = 0 when once of A or B is zero or the exp_diff > 32. 
assign shamt = shift_amount | {5{Make_zero}}; 

// Right shift (to increase exp)
Shifter_32bit  Small_frac_shift (.data_in(temp), .shift_amount(shamt), .mode(2'b00), .data_out(Shifted_fract) );
	
endmodule 

