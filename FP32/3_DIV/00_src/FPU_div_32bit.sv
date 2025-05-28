module Div_f_32bit (
			input  logic        clk_i,
			input  logic        rst_n,
			input  logic        start,
			input  logic [31:0] A,
			input  logic [31:0] B,
			output logic [31:0] S,
			output logic        ready
			output logic        error,
			output logic        NaN,
			output logic        zero,
			output logic        overflow,
			output logic        underflow,
);

typedef enum bit [1:0] {
	IDLE      = 2'b00,    // IDLE:      Wait for start signal
	FETCH     = 2'b01,    // FETCH:     Store A and B to registers
	EXECUTE   = 2'b10,    // EXECUTE:   Calculate Resulting Mantissa (require 20 cycles)
	WRITEBACK = 2'b11     // WRITEBACK: Writeback result to Sign, Exp, Mantissa register
} states;

states       PreStep;
states       NextStep;
wire logic   exception;
wire logic   done;
wire logic   Fetch;
wire logic   Execute;
wire logic   Writeback;

assign Fetch      = (PreStep == FETCH);
assign Execute    = (PreStep == EXECUTE);
assign Writeback  = (PreStep == WRITEBACK);
assign exception  = NaN | error | overflow | underflow | zero;

always_ff @(posedge clk_i or negedge rst_n) begin	 
	if (!rst_n)    PreStep		<= IDLE;
	else           PreStep		<= NextStep;
end

always_comb begin		
	case (PreStep) 
	    IDLE:       if      (start)      NextStep <= FETCH;
		            else                 NextStep <= IDLE;  
		FETCH:                           NextStep <= EXECUTE;
		EXECUTE:    if      (done)       NextStep <= WRITEBACK;
                    else if (exception)  NextStep <= IDLE;  
				    else                 NextStep <= EXECUTE;
		WRITEBACK:                       NextStep <= IDLE;
	endcase 
end


//===================== FETCH STAGE ===========================							 
wire logic [31:0] A_fetched;
wire logic [31:0] B_fetched;
wire logic [22:0] fract_A;
wire logic [22:0] fract_B;
wire logic [7:0]  exp_A;
wire logic [7:0]  exp_B;
wire logic [7:0]  bias;
register_32bit  Get_A (.clk(clk_i), .rst_n(rst_n), .en(Fetch), .D(A), .Q(A_fetched) );
register_32bit  Get_B (.clk(clk_i), .rst_n(rst_n), .en(Fetch), .D(B), .Q(B_fetched) );
			
assign fract_A = A_fetched[22:0];
assign fract_B = B_fetched[22:0];
assign exp_A   = A_fetched[30:23];
assign exp_B   = B_fetched[30:23];
assign bias    = 8'b01111111;          // bias = 127


//===================== EXECUTE STAGE =========================		
//-------------- Initial exponent calculation ----------------
wire logic [7:0] diff_exp;
wire logic [7:0] bias_exp;
full_adder_8bit  Subttrac_exp (.A(exp_A),    .B(exp_B), .Invert_B(1'b1), .C_in(1'b1), .Sum(diff_exp),  .C_out() );
full_adder_8bit  Biasing      (.A(diff_exp), .B(bias),  .Invert_B(1'b0), .C_in(1'b0), .Sum(bias_exp), .C_out() );


//-------------- Mantissa division ----------------
wire logic [31:0] mantissa_A;      // Including the leading_1
wire logic [31:0] mantissa_B;      // Including the leading_1
wire logic [31:0] temp_mantissa;   
wire logic        start_div;	   // Start mantissa division process
assign mantissa_A = {8'b0, 1'b1, fract_A};
assign mantissa_B = {8'b0, 1'b1, fract_B};
assign start_div  = 

// Temp_fract = Not Normallized
// Most extreme case:      1 / 1.99999999 > 0.5
// This means only 1 left shift amount is necessary
Divider_fract   mantissa_fract(
    .i_clk(clk_i),
	.i_rst_n(rst_n),
	.i_start(start_div),         
    .i_fract_A(mantissa_A),      // Including the leading_1
	.i_fract_B(mantissa_B),      // Including the leading_1         
    .o_fract(temp_mantissa),
    .o_done(done)                                 
);


//-------------- Normalization ----------------
wire logic [31:0] new_mantissa;
wire logic [31:0] normalize_mantissa;
wire logic [7:0]  new_exp;
wire logic [7:0]  exp_dec;
wire logic        no_leading1;
assign normalize_mantissa = {temp_mantissa[31:1], 1'b0};
assign exp_dec            = {7'b0, no_leading1};
assign no_leading1        = ~temp_mantissa[23];

mux_2X1_32bit     Normallize (.sel(no_leading1), .A(temp_mantissa), .B(normalize_mantissa), .Y(new_mantissa) );
full_adder_8bit   EXP_dec    (.A(bias_exp), .B(exp_dec), .Invert_B(1'b1), .C_in(1'b1), .Sum(new_exp), .C_out() );





//-------------- Excepting handling ----------------
exception_handler    format_exception(
        .i_float_A(A),
        .i_float_B(B),
        .o_overflow(),
        .o_zero(),
        .o_NaN()
);

wire logic [31:0] S_tmp;
wire logic [22:0] result_mantissa;
wire logic [7:0]  result_exp;
wire logic        result_sign;

assign result_exp      =  new_exp            & { 8{~(zero_A | zero_B)}};
assign result_mantissa =  new_mantissa[22:0] & {23{~(zero_A | zero_B)}};
assign result_sign     =  A_fetched[31] ^ B_fetched[31];


// OUTPUT
assign overflow  = ~NaN & inf_A;
assign zero      = ~NaN & zero_A; 
assign error     =  zero_B | (~NaN & inf_A);
assign NaN       = (inf_A & inf_B) | NaN_A | NaN_B | (inf_B & zero_A);   // zero X Infinity
assign ready     = (PreStep == IDLE);	
assign S         = {Result_sign, Result_exp, Result_Mantissa};

								  

endmodule


 





