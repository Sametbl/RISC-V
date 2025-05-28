module Divider_frac(
    input  logic clk_i, rst_ni, start,           // rst_ni also used to start the dividing process
    input  logic [23:0] frac_A, frac_B,         
    output logic [23:0] frac_out,
    output logic Done                                 
);

typedef enum bit [2:0] {IDLE = 3'b000,    FETCH = 3'b001, WAIT = 3'b010, INIT = 3'b011,
                        EXECUTE = 3'b100, WRITE = 3'b101} states;		  
states  PreStep, NextStep;
wire logic finish;
// IDLE: Wait for START signal
// FETCH: Load A_in, B_in
// WAIT: Wait for datapath components to process datas (reduced_A, counter initial value).
// INIT: Load datas and initialize registers 
// EXECUTE: Enable Remainder and Quotient registers. Start calculating (shift and substract)
// WRITE: Write results into output register (Remainder, QUotient)

always_ff @(posedge clk_i, negedge rst_ni) 		
		if (!rst_ni)    PreStep		<= IDLE;
		else            PreStep		<= NextStep;


// Control FSM state table
always @(*) begin		
		case (PreStep) 
		   IDLE:    if (start)        NextStep <= FETCH;      else NextStep <= IDLE;  
			FETCH:                     NextStep <= WAIT;
			WAIT:                      NextStep <= INIT;
			INIT:                      NextStep <= EXECUTE;
			EXECUTE: if (finish)       NextStep <= WRITE;      else  NextStep <= EXECUTE;
			WRITE:                     NextStep <= IDLE;
		endcase 
end

			
wire logic [31:0] divisor, divident;
wire logic zero_A, Execute, Init, Fetch, Wait;
assign Fetch    = (PreStep == FETCH);
assign Wait     = (PreStep == WAIT); // Used as load signal for registers and select MUX
assign Init     = (PreStep == INIT);
assign Execute  = (PreStep == EXECUTE); 
assign Done     = (PreStep == WRITE);

								 						 
//--------------------- FETCH STAGE --------------------------------							 
wire logic [31:0] A, B;
Register_32bit    Get_A  (.clk(clk_i), .reset(rst_ni), .En(Fetch), .D({8'b0, frac_A}), .Q(A) );
Register_32bit    Get_B  (.clk(clk_i), .reset(rst_ni), .En(Fetch), .D({8'b0, frac_B}), .Q(B) );
assign divisor  = B;


//-------------------- INIT and EXECUTE STAGES -------------------
wire logic [31:0] P_remainder, P_remainder_2, temp_divident; 
wire logic [31:0] Pre_Quotient;
wire logic [5:0] Count;																																																// Leading_0_counter_32bit    Find_Reduced_B (.data(B),  .NLZ(NLZ_B),  .all_zero(error));
wire logic Connect, sign_P;


Down_counter_6bit   Start_count     (.clk(clk_i), .reset(rst_ni), .En(Execute), .load(~Init), .ld_data(6'b010111), .Q(Count)  );
assign finish = ~(Count[5] | Count[4] | Count[3] | Count[2] | Count[1] | Count[0]);

Mux_2X1_32bit       Init_divident   (.A({P_remainder_2[30:0], 1'b0}), .B(A), .Sel(Init), .OUT(temp_divident) );
Register_32bit      Temp_divident   (.clk(clk_i), .reset(rst_ni & ~(Wait)), .En(Init | Execute), .D(temp_divident), .Q(divident)   );

Full_Adder_32bit    Sub             (.A(divident), .B(divisor), .Invert_B(1'b1), .C_in(1'b1), .Sum(P_remainder), .C_out(Connect));
Full_Adder          Sign            (.A(1'b0), .B(1'b1), .C_in(Connect), .Sum(sign_P), .C_out() );
Mux_2X1_32bit       Partial_Remain  (.A(P_remainder), .B(divident), .Sel(sign_P), .OUT(P_remainder_2) );


Register_32bit      Temp_Quotient   (.clk(clk_i), .reset(rst_ni & ~(Init)), .En(1'b1), .D({Pre_Quotient[30:0], ~sign_P}), .Q(Pre_Quotient) );
  

//-------------------- WRITE STAGE -------------------
wire logic [31:0] temp;
Register_32bit      Final_Quotient  (.clk(clk_i), .reset(rst_ni), .En(Done), .D(Pre_Quotient), .Q(temp)  );
assign frac_out = temp[23:0];   

endmodule


  