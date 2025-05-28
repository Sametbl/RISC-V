module Normalize( 
		input  logic [31:0] Temp_frac,
		input  logic [7:0]  Larger_exp,  
		output logic [22:0] Result_frac,
		output logic [7:0]  Result_exp,
		output logic Zero_detect                // Overflow, Underflow, 
);

// Temp_frac = { 7'b0000000, {Carry}, {Leading 1}, {Fraction} }
//              31        25/24     24/23         23/22      0
wire logic Carry, Zero_frac;
assign Carry = Temp_frac[24]; // Carry bit after add 2 leading ones

// Leading 0 counter before the 23th bit (leading 1 bit)
// Operation:  Left shift by 8 and counts leading 0  
wire logic [31:0] shift8_temp;
assign shift8_temp[31:8] = Temp_frac[23:0];
assign shift8_temp[7:0]  = 8'b0;

wire logic [4:0] NLZ; // Number of Leading Zero
Leading_0_counter_32bit   LZ_counter (.data(shift8_temp), .NLZ(NLZ), .all_zero(Zero_frac));
assign Zero_detect = Zero_frac & ~Carry; // Zero =  No frac after shift and also no carry


wire logic [31:0] shifted_frac;
wire logic [7:0]  added_exp;
wire logic [4:0]  shift_amount;
wire logic [1:0]  shift_mode;
assign shift_amount[0] = NLZ[0] |  Carry; // Shift left once, shift leading Carry exist
assign shift_amount[1] = NLZ[1] & ~Carry;
assign shift_amount[2] = NLZ[2] & ~Carry;
assign shift_amount[3] = NLZ[3] & ~Carry;
assign shift_amount[4] = NLZ[4] & ~Carry;

// shift_mode = 2'00: Right shift
// shift_mode = 2'01: Left shift
assign shift_mode[1] = 1'b0;
assign shift_mode[0] = ~Carry;

Shifter_32bit     Normalize_frac (.data_in(Temp_frac), .shift_amount(shift_amount), .mode(shift_mode), .data_out(shifted_frac) );		
Full_Adder_8bit   New_exp        (.A(Larger_exp), .B({3'b000, shift_amount}), .Invert_B(~Carry), .C_in(~Carry), .Sum(added_exp), .C_out() ); 

assign Result_exp  = added_exp & {8{~Zero_detect}};
assign Result_frac = shifted_frac[22:0];


// assign Underflow  
// assign Overflow  
			
endmodule
							 
							
						
			