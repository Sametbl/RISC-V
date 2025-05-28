module Divider_fract(
    input  logic        i_clk,
	input  logic        i_rst_n,
	input  logic        i_start,         
    input  logic [31:0] i_fract_A,      // Including the leading_1
	input  logic [31:0] i_fract_B,      // Including the leading_1         
    output logic [31:0] o_fract,
    output logic        o_done                                 
);

typedef enum reg [1:0] {
    IDLE      = 2'b00,  // IDLE:      Wait for "start" signal
    PREPARE   = 2'b01,  // PREPARE:   Load data to registers 
    EXECUTE   = 2'b10,  // EXECUTE:   Start "shift and substract" operation
    WRITEBACK = 2'b11   // WRITEBACK: Write results into output registers
} states;		  

states            PreStep;
states            NextStep;
wire logic        Prepare;
wire logic        Execute;
wire logic        Writeback;
wire logic        done;						 

assign Prepare   = (PreStep == PREPARE);
assign Execute   = (PreStep == EXECUTE); 
assign Writeback = (PreStep == WRITEBACK);						 						 

always_ff @(posedge clk_i or negedge rst_n) 		
		if (!rst_n)    PreStep		<= IDLE;
		else           PreStep		<= NextStep;

// Control FSM state table
always_comb begin
    case (PreStep) 
         IDLE:     if(start)  NextStep = PREPARE;      else  NextStep = IDLE;    
         PREPARE:             NextStep = EXECUTE;   
         EXECUTE:  if(done)   NextStep = WRITEBACK;    else  NextStep = EXECUTE; 
         WRITEBACK:           NextStep = IDLE;
    endcase 
end


//--------------------  PREPARE STAGE -----------------------	
wire logic [31:0]  divident;
wire logic [31:0]  divisor;
wire logic [7:0]   iteration;		// Number of iteration of "Shift and subtract"																																															// Leading_0_counter_32bit    Find_Reduced_B (.data(B),  .NLZ(NLZ_B),  .all_zero(error));
wire logic [7:0]   counter;         // Counter for the looped operation

assign iteration = 8'd23;
assign divisor  = i_fract_B;	
assign done     = ~(|counter);     // done = (Counter == 0)

down_counter_8bit  for_loop        (.clk    (clk_i)    , 
                                    .rst_n  (rst_n)    ,
                                    .en     (Execute)  ,    // Start counting in EXCUTE stage
                                    .ld     (Prepare)  ,    // Load data in PREPARE stage
                                    .ld_data(iteration),
                                    .Q      (counter)
);

//-------------------- PREPARE and EXECUTE STAGES -------------------
// Shift and subtract method: Shift operation
// Shift register: next_A >> 1

// Shift register: divident = partial_remainder >> 1  with c_in = MSB of next_A 
wire logic [31:0] partial_remainder; 
wire logic [31:0] partial_divident; 
wire logic [31:0] divident_tmp;

assign partial_divident = {partial_remainder[30:0], 1'b0};

mux_2X1_32bit   rst_divident (.sel(Prepare), .A(partial_divident), .B(i_fract_A), .Y(divident_tmp));
register_32bit  st_divident  (.clk  (clk_i)            ,
                              .rst_n(rst_n)            , 
                              .en   (Prepare | Execute),
                              .D    (divident_tmp)     , 
                              .Q    (divident) 
);


// Shift and subtract method: Substract operation
// Extend full adder to 33-bit to extract sign bit
wire logic [31:0] sub_result;
wire logic        connect;
wire logic        sub_sign;

full_adder_32bit    Sub  (.A       (divident),
                          .B       (divisor),
                          .Invert_B(1'b1),
                          .C_in    (1'b1),
                          .Sum     (sub_result),
                          .C_out   (connect)
);

full_adder          Sign (.A    (1'b0)    ,
                          .B    (1'b1)    ,
                          .C_in (connect) ,
                          .Sum  (sub_sign),
                          .C_out()
);

// If result is negative, restore the divident
mux_2X1_32bit  hold  (.sel(sub_sign), .A(sub_result), .B(divident), .Y(partial_remainder) );


// Computing the quotient & remainder
// shift reigster: append 1 to the right of Quotient if sub_result > 0
//                 append 0 to the right of Quotient if sub_result < 0

wire logic [31:0] partial_quotient;
wire logic [31:0] remainder_update;
wire logic [31:0] quotient_update;
wire logic [31:0] quotient_tmp;
assign partial_quotient = {quotient_update[30:0], ~sub_sign};

mux_2X1_32bit   rst_Quotient (.sel(Prepare), .A(partial_quotient), .B(32'b0), .Y(quotient_tmp));
register_32bit  Upt_Quotient (.clk  (clk_i)            ,
                              .rst_n(rst_n)            ,
                              .en   (Prepare | Execute),
                              .D    (quotient_tmp)     ,
                              .Q    (quotient_update)
);  

// Output
register_32bit  Result_R (.clk(clk_i), .rst_n(rst_n), .en(Writeback), .D(quotient_update), .Q(o_fract));
assign o_done   =  (PreStep == IDLE);
    

endmodule

