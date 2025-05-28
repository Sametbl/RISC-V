module FPU_32bit(
		input  logic clk_i, rst_ni, start,
		input  logic [31:0] A, B, 
		input  logic [1:0] Mode,
		output logic [31:0] S,
		output logic Zero, NaN, Inf, Done, Error, Ready  // Ready signal to inform when to load next inputs
);															


// IDLE:  Wait for start signal to load/save A and B for the div operation
// FETCH: Load A and B to register
// CALC:  Calculate  
// WRITE: Write result to Sign, Exp, Mantissa register

typedef enum bit [1:0] {IDLE = 2'b00, FETCH = 2'b01, CALC = 2'b10, WRITE = 2'b11} states;		  
states  PreStep, NextStep;
wire logic Finish;

always_ff @(posedge clk_i, negedge rst_ni) 		
		if (!rst_ni)    PreStep		<= IDLE;
		else            PreStep		<= NextStep;


// Control FSM state table
wire logic stop;
assign stop = NaN | Error | Inf | Zero;
always @(*) begin		
		case (PreStep) 
		   IDLE:    if (start)        NextStep <= FETCH;      else NextStep <= IDLE;  
			FETCH:                     NextStep <= CALC;
			CALC:    if (Finish)       NextStep <= WRITE;
                  else if (stop)    NextStep <= IDLE;  
						else              NextStep <= CALC;
			WRITE:                     NextStep <= IDLE;
		endcase 
end



wire logic [31:0] A_reg, B_reg;
wire logic [31:0] S_Add_Sub, S_Mul, S_Div;
wire logic Fetch, Calc, Write;
wire logic ADD, SUB, MUL, DIV;
wire logic zero_A, zero_B;
wire logic [1:0] mode;

Register_32bit    Get_A  (.clk(clk_i), .reset(rst_ni), .En(Fetch), .D(A), .Q(A_reg) );
Register_32bit    Get_B  (.clk(clk_i), .reset(rst_ni), .En(Fetch), .D(B), .Q(B_reg) );
D_flip_flop       Mode_0 (.clk(clk_i), .clear(rst_ni), .preset(1'b1), .En(Fetch), .D(Mode[0]), .Q(mode[0]) );
D_flip_flop       Mode_1 (.clk(clk_i), .clear(rst_ni), .preset(1'b1), .En(Fetch), .D(Mode[1]), .Q(mode[1]) );

assign Fetch    = (PreStep == FETCH);
assign Calc     = (PreStep == CALC);
assign Write    = (PreStep == WRITE);
assign Done     = (PreStep == WRITE);
assign Ready    = (PreStep == IDLE);	
	
assign ADD  = ~mode[1] & ~mode[0];
assign SUB  = ~mode[1] &  mode[0];
assign MUL  =  mode[1] & ~mode[0];
assign DIV  =  mode[1] &  mode[0];	
		
			
	
// Because Addition, Subtraction, Multiplication are combinational,
// I use Down_counter to adjust the amount of cycles these operations need during CALC stage
// The Down_counter is adjustable according on the delay of ADD, SUB, MUL operations
// The Down_counter also used to inform FSM when CALC is finished
wire logic [5:0] Comb_Count;
wire logic Comb_done, En_comb_count;
assign En_comb_count = Calc & ~DIV; // During Calc stage and not DIV mode
assign Comb_done = ~( Comb_Count[5] | Comb_Count[4] | Comb_Count[3] | Comb_Count[2] | Comb_Count[1] | Comb_Count[0]);

Down_counter_6bit    Comb_timer  (.clk(clk_i), .reset(rst_ni), .En(En_comb_count), .ld_data(6'b000010), .load(~Fetch), .Q(Comb_Count) );
	
	
wire logic Div_done, Zero_Sub;			
Add_Sub_f_32bit   Add_Sub (.A(A_reg), .B(B_reg), .Add_Sub_f(S_Add_Sub), .mode(SUB), .Zero_Sub(Zero_Sub), .zero_A(zero_A), .zero_B(zero_B) ); 
Mul_f_32bit       Mul     (.A(A_reg), .B(B_reg), .Mul_f(S_Mul) );
Div_f_32bit       Dif     (.A(A_reg), .B(B_reg), .Div_f(S_Div), .clk_i(clk_i), .rst_ni(rst_ni), .stop(stop),
                           .start(Calc), .Done(Div_done), .Ready() );
														
assign Finish = Comb_done | Div_done;

wire logic [31:0] S_temp;			
Mux_4X1_32bit     Output  (.I0(S_Add_Sub), .I1(S_Add_Sub), .I2(S_Mul), .I3(S_Div), .Sel(mode), .OUT(S_temp) );



// ----------------------------------- SUBNORMAL --------------------------------
wire logic zero_exp_A, zero_exp_B;
assign zero_exp_A = ~(A_reg[30] | A_reg[29] | A_reg[28] | A_reg[27] | A_reg[26] | A_reg[25] | A_reg[24] | A_reg[23]); // exp = 8'b00000000 
assign zero_exp_B = ~(B_reg[30] | B_reg[29] | B_reg[28] | B_reg[27] | B_reg[26] | B_reg[25] | B_reg[24] | B_reg[23]);

wire logic Mantissa_A, Mantissa_B, Mantissa_S;
wire logic NaN_A, NaN_B, NaN_S;
assign Mantissa_A =  (A_reg[22] | A_reg[21] | A_reg[20] | A_reg[19] | A_reg[18] | A_reg[17] | A_reg[16] | A_reg[15] | 
                      A_reg[14] | A_reg[13] | A_reg[12] | A_reg[11] | A_reg[10] | A_reg[9]  | A_reg[8]  | A_reg[7]  | 
                      A_reg[6]  | A_reg[5]  | A_reg[4]  | A_reg[3]  | A_reg[2]  | A_reg[1]  | A_reg[0] );

assign Mantissa_B =  (B_reg[22] | B_reg[21] | B_reg[20] | B_reg[19] | B_reg[18] | B_reg[17] | B_reg[16] | B_reg[15] | 
                      B_reg[14] | B_reg[13] | B_reg[12] | B_reg[11] | B_reg[10] | B_reg[9]  | B_reg[8]  | B_reg[7]  | 
                      B_reg[6]  | B_reg[5]  | B_reg[4]  | B_reg[3]  | B_reg[2]  | B_reg[1]  | B_reg[0] );

							 
assign Mantissa_S =  (S_temp[22] | S_temp[21] | S_temp[20] | S_temp[19] | S_temp[18] | S_temp[17] | S_temp[16] | S_temp[15] | 
                      S_temp[14] | S_temp[13] | S_temp[12] | S_temp[11] | S_temp[10] | S_temp[9]  | S_temp[8]  | S_temp[7]  | 
                      S_temp[6]  | S_temp[5]  | S_temp[4]  | S_temp[3]  | S_temp[2]  | S_temp[1]  | S_temp[0] );
								 				 
							 

wire logic inf_A, inf_B, inf_S;
assign inf_A  = A_reg[30] & A_reg[29] & A_reg[28] & A_reg[27] & A_reg[26] & A_reg[25] & A_reg[24] & A_reg[23]; // exp = 8'b11111111
assign inf_B  = B_reg[30] & B_reg[29] & B_reg[28] & B_reg[27] & B_reg[26] & B_reg[25] & B_reg[24] & B_reg[23];
assign inf_S  = S_temp[7] & S_temp[6] & S_temp[5] & S_temp[4] & S_temp[3] & S_temp[2] & S_temp[1] & S_temp[0];		

						 
assign NaN_A  = inf_A & Mantissa_A;  // NaN number format
assign NaN_B  = inf_B & Mantissa_B;
assign NaN_S  = inf_S & Mantissa_S;
assign zero_A = zero_exp_A & ~Mantissa_A;
assign zero_B = zero_exp_B & ~Mantissa_B;


wire logic NaN_AddSub, NaN_Mul, NaN_Div;
wire logic Inf_AddSub, Inf_Mul, Inf_Div;
wire logic Zero_AddSub, Zero_Mul, Zero_Div; 


assign Inf_AddSub  = (ADD | SUB) &  ~NaN & (inf_A  | inf_B);
assign Zero_AddSub = (ADD | SUB) & (~NaN & zero_A & zero_B) | Zero_Sub; 
assign NaN_AddSub  = SUB & inf_A & inf_B;  // Infinity - Infinity

assign Inf_Mul     = MUL & ~NaN & (inf_A | inf_B);
assign Zero_Mul    = MUL & ~NaN & (zero_A | zero_B); 
assign NaN_Mul     = MUL & (inf_A & inf_B)  | (inf_A & zero_B) | (inf_B & zero_A);   // Infinity X Infinity,  Zero X Infinity
  				

assign Inf_Div     = DIV & ~NaN & inf_A;
assign Zero_Div    = DIV & ~NaN & zero_A; 
assign Error       = zero_B | (~NaN & inf_A);
assign NaN_Div     = DIV & (inf_A & inf_B) |  (inf_B & zero_A);   // Infivity / Infinity, 0/ Infinity
  				
assign NaN  = NaN_A | NaN_B | NaN_S | NaN_AddSub | NaN_Mul | NaN_Div;
assign Inf  = Inf_AddSub  | Inf_Mul | Inf_Div | inf_S;
assign Zero = Zero_AddSub | Zero_Mul | Zero_Div;


//----------------------------------------------------------------------------------------------------------------

wire logic Result_sign;
wire logic [7:0]  Result_exp;
wire logic [22:0] Result_Mantissa;

assign Result_exp      = S_temp[30:23] & { 8{~Zero_Div | Zero_Mul}};
assign Result_Mantissa = S_temp[22:0]  & {23{~Zero_Div | Zero_Mul}};
assign Result_sign     = S_temp[31];

Register_32bit  Result  (.clk(clk_i), .reset(rst_ni), .En(Write), .D({Result_sign, Result_exp, Result_Mantissa}), .Q(S)  );


endmodule
