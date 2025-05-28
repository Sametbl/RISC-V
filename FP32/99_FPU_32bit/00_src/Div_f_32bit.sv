module Div_f_32bit (
			input  logic clk_i, rst_ni, start, stop,
			input  logic [31:0] A, B,
			output logic [31:0] Div_f,
			output logic Done, Ready
);


typedef enum bit [1:0] {IDLE = 2'b00, FETCH = 2'b01, MANT = 2'b10, WRITE = 2'b11} states;		  
states  PreStep, NextStep;
wire logic Finish;

// IDLE:  Wait for start signal to load/save A and B for the div operation
// FETCH: Load A and B to register
// MANT:  Calculate Resulting Mantissa (require 20 cycles)
// WRITE: Write result to Sign, Exp, Mantissa register


always_ff @(posedge clk_i, negedge rst_ni) 		
		if (!rst_ni)    PreStep		<= IDLE;
		else            PreStep		<= NextStep;

// Control FSM state table
always @(*) begin		
		case (PreStep) 
		   IDLE:    if (start)        NextStep <= FETCH;      else NextStep <= IDLE;  
			FETCH:                     NextStep <= MANT;
			MANT:    if (Finish)       NextStep <= WRITE;
                  else if (stop)    NextStep <= IDLE;  
						else              NextStep <= MANT;
			WRITE:                     NextStep <= IDLE;
		endcase 
end


wire logic [31:0] A_fetched, B_fetched;
wire logic Fetch, Mant_cal, Write;
assign Fetch    = (PreStep == FETCH);
assign Mant_cal = (PreStep == MANT);
assign Write    = (PreStep == WRITE);
assign Done     = (PreStep == WRITE);
assign Ready    = (PreStep == IDLE);	
		
Register_32bit    Get_A  (.clk(clk_i), .reset(rst_ni), .En(Fetch), .D(A), .Q(A_fetched) );
Register_32bit    Get_B  (.clk(clk_i), .reset(rst_ni), .En(Fetch), .D(B), .Q(B_fetched) );
			
			
wire logic [7:0]  bias, exp_A, exp_B, diff_exp, New_exp, sum_exp;
wire logic [22:0] frac_A, frac_B;
wire logic [23:0] temp_frac;
wire logic [31:0] New_mantissa;
wire logic No_leading_1;

assign frac_A = A_fetched[22:0];
assign frac_B = B_fetched[22:0];
assign exp_A  = A_fetched[30:23];
assign exp_B  = B_fetched[30:23];


assign bias = 8'b01111111; // bias = 127
Full_Adder_8bit   Subttrac_exp (.A(exp_A),    .B(exp_B), .Invert_B(1'b1), .C_in(1'b1), .Sum(diff_exp),  .C_out() );
Full_Adder_8bit    final_exp   (.A(diff_exp), .B(bias),  .Invert_B(1'b0), .C_in(1'b0), .Sum(sum_exp), .C_out() );


Divider_frac  Main (.clk_i(clk_i), .rst_ni(rst_ni), .start(Mant_cal), .Done(Finish),
                    .frac_A({1'b1, frac_A}), .frac_B({1'b1, frac_B}), .frac_out(temp_frac) );
						
// Temp_frac = Not Normallized
// Most extreme case:      1 / 1.99999999 > 0.5
// The mantissa division always have result larger than 0.5
// This means only 1 left shift amount is necessary
		
assign No_leading_1 = ~temp_frac[23];

Mux_2X1_32bit     Normallize (.Sel(No_leading_1), .A({8'b0, temp_frac}), .B({8'b0, temp_frac[22:0], 1'b0}), .OUT(New_mantissa) );
Full_Adder_8bit   EXP_inc    (.A(sum_exp), .B({7'b0, No_leading_1}), .Invert_B(1'b1), .C_in(1'b1), .Sum(New_exp), .C_out() );




wire logic Result_sign;
wire logic [7:0]  Result_exp;
wire logic [22:0] Result_Mantissa;

assign Result_exp      = New_exp;
assign Result_Mantissa = New_mantissa[22:0];
assign Result_sign     = A_fetched[31] ^ B_fetched[31];

Register_32bit   Result  (.clk(clk_i), .reset(rst_ni), .En(Write), .Q(Div_f),                                      
                          .D({Result_sign, Result_exp, Result_Mantissa})      );
								 
								  

endmodule








