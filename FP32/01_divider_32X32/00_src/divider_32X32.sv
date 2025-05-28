module divider_32X32(
    input  logic        clk_i,        
    input  logic        rst_n,           // rst_n also used to start the dividing process
    input  logic        start,       
    input  logic [31:0] A,               // A divide by B
    input  logic [31:0] B,   
    output logic [31:0] quotient,        // Quo and Rei can be 32 bit if B = 1 or B > A
    output logic [31:0] remainder,    
    output logic        ready,      
    output logic        error            // Divide by 0
);

typedef enum reg [2:0] {
    IDLE      = 3'b000,  // IDLE:      Wait for "start" signal
    FETCH     = 3'b001,  // FETCH:     Fetch input A and B
    PREPARE   = 3'b010,  // PREPARE:   Load data to registers 
    EXECUTE   = 3'b011,  // EXECUTE:   Start "shift and substract" operation
    WRITEBACK = 3'b100   // WRITEBACK: Write results into output registers
} states;		  

states      PreStep;
states      NextStep;
wire logic  done;
 
always_ff @(posedge clk_i or negedge rst_n) 		
		if (!rst_n)    PreStep		<= IDLE;
		else           PreStep		<= NextStep;

// Control FSM state table
always_comb begin
    case (PreStep) 
         IDLE:     if(start)  NextStep = FETCH;      else  NextStep = IDLE;    
         FETCH:               NextStep = PREPARE;
         PREPARE:  if(error)  NextStep = IDLE;       else  NextStep = EXECUTE;   
         EXECUTE:  if(done)   NextStep = WRITEBACK;  else  NextStep = EXECUTE; 
         WRITEBACK:           NextStep = IDLE;
         default:             NextStep = IDLE;
    endcase 
end


wire logic Fetch;
wire logic Prepare;
wire logic Execute;
wire logic Writeback;
assign Fetch     = (PreStep == FETCH);
assign Prepare   = (PreStep == PREPARE);
assign Execute   = (PreStep == EXECUTE); 
assign Writeback = (PreStep == WRITEBACK);
 								 						 
								 
//--------------------- FETCH STAGE --------------------------------							 
wire logic [31:0] A_fetched;
wire logic [31:0] B_fetched;
register_32bit   fetch_A  (.clk(clk_i), .rst_n(rst_n), .en(Fetch), .D(A), .Q(A_fetched) );
register_32bit   fetch_B  (.clk(clk_i), .rst_n(rst_n), .en(Fetch), .D(B), .Q(B_fetched) );


//--------------------  PREPARE STAGE -----------------------	
wire logic [31:0]  divisor;
wire logic [31:0]  divident;
wire logic [31:0]  A_reduced;       // shifted to remove leading_0
wire logic [7:0]   iteration;		// Number of iteration of "Shift and subtract"																																															// Leading_0_counter_32bit    Find_Reduced_B (.data(B),  .NLZ(NLZ_B),  .all_zero(error));
wire logic [7:0]   counter;         // Counter for the looped operation
wire logic [4:0]   NLZ_A;           // Number of leading 0 of fetched A


LZC_32bit          Count_NLZ_A (.i_data    (A)    ,
                                .o_NLZ     (NLZ_A), 
                                .o_all_zero()
  
);   
shifter_32bit      Reduced_A    (.data_in    (A)    ,
                                .mode        (2'b01),  // Left shift
                                .shift_amount(NLZ_A),
                                .data_out    (A_reduced)
);

// Number of iteration of operations = 32 - NLA_A
full_adder_8bit    Reduced_count   (.A       (8'b00100000)    ,          
                                    .B       ({3'b000, NLZ_A}),    
                                    .Invert_B(1'b1)           ,
                                    .C_in    (1'b1)           ,
                                    .Sum     (iteration)      ,
                                    .C_out   ()
);

down_counter_8bit  for_loop        (.clk    (clk_i)    , 
                                    .rst_n  (rst_n)    ,
                                    .en     (Execute)  ,    // Start counting in EXCUTE stage
                                    .ld     (Prepare)  ,    // Load data in PREPARE stage
                                    .ld_data(iteration),
                                    .Q      (counter)
);

assign divisor  = B_fetched;	
assign done     = ~(|counter);     // done = (Counter == 0)


//-------------------- PREPARE and EXECUTE STAGES -------------------
// Shift and subtract method: Shift operation
// Shift register: next_A >> 1
wire logic [31:0] shifted_A;
wire logic [31:0] next_A;
wire logic [31:0] next_A_tmp;
assign shifted_A = {next_A[30:0], 1'b0};

mux_2X1_32bit   ld_shifter  (.sel(Prepare), .A(shifted_A), .B(A_reduced), .Y(next_A_tmp));
register_32bit  st_shifter  (.clk  (clk_i)            ,
                             .rst_n(rst_n)            ,
                             .en   (Prepare | Execute),
                             .D    (next_A_tmp)       ,
                             .Q    (next_A)
);



// Shift register: divident = partial_remainder >> 1  with c_in = MSB of next_A 
wire logic [31:0] partial_remainder; 
wire logic [31:0] partial_divident; 
wire logic [31:0] divident_tmp;
assign partial_divident = {partial_remainder[30:0], next_A[31]};

mux_2X1_32bit   rst_divident (.sel(Prepare), .A(partial_divident), .B(32'b0), .Y(divident_tmp));
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

register_32bit  Upt_Remainder (.clk  (clk_i)            ,
                               .rst_n(rst_n)            ,
                               .en   (Prepare | Execute),
                               .D    (partial_remainder),
                               .Q    (remainder_update) 
);
  
// Output
register_32bit  Result_R (.clk(clk_i), .rst_n(rst_n), .en(Writeback), .D(remainder_update), .Q(remainder) );
register_32bit  Result_Q (.clk(clk_i), .rst_n(rst_n), .en(Writeback), .D(quotient_update),  .Q(quotient)   );
assign ready    =   (PreStep == IDLE);
assign error    =  ~(|divisor);       // divisor == 0
    

endmodule


