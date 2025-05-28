module shifter_32bit(
		input  logic [31:0] data_in,        
		input  logic [4:0] shift_amount,   
		input  logic [1:0] mode,           
		output logic [31:0] data_out       
);
wire logic [31:0] reversed_in, reversed_out, bin_in;
wire logic [31:0] shift_R1, shift_R2, shift_R4, shift_R8, shift_R16;
wire logic [31:0] mux_R1, mux_R2, mux_R4, mux_R8, mux_R16;
wire logic Left_logic, Right_arith, Reserved;
wire logic New_bit;
                                            // mode = 2'b00 : shift Right logic (Default)
assign Left_logic  = ~mode[1] &  mode[0];   // mode = 2;b01 : shift Left  logic
assign Right_arith =  mode[1] & ~mode[0];   // mode = 2'b10 : shift Right Arithmetic
assign Reserved    =  mode[1] &  mode[0];   // mode = 2'b11 : Reserved

assign New_bit = Right_arith & data_in[31];  // For Right shift arithmetic, New_bit = Sign_bit 

//--------------------- Reverse Input for Left shift -------------------
reverse_32bit    reverse_in (.orig(data_in), .rev(reversed_in));
mux_2X1_32bit    mux_rev_in (.A(data_in),    .B(reversed_in),  .sel(Left_logic), .Y(bin_in));


//--------------------- Performing Right shift ---------------------

shift_R1_32bit   shift_1 (.In(bin_in), .new_bit(New_bit), .Out(shift_R1));
mux_2X1_32bit    mux_1   (.A(bin_in),  .B(shift_R1), .sel(shift_amount[0] & ~Reserved), .Y(mux_R1));

shift_R2_32bit   shift_2 (.In(mux_R1), .new_bit(New_bit), .Out(shift_R2));
mux_2X1_32bit    mux_2   (.A(mux_R1),  .B(shift_R2), .sel(shift_amount[1] & ~Reserved), .Y(mux_R2));
																					
shift_R4_32bit   shift_4 (.In(mux_R2), .new_bit(New_bit), .Out(shift_R4));
mux_2X1_32bit    mux_4   (.A(mux_R2),  .B(shift_R4), .sel(shift_amount[2] & ~Reserved), .Y(mux_R4));

shift_R8_32bit   shift_8 (.In(mux_R4), .new_bit(New_bit), .Out(shift_R8));
mux_2X1_32bit    mux_8   (.A(mux_R4),  .B(shift_R8), .sel(shift_amount[3] & ~Reserved), .Y(mux_R8));

shift_R16_32bit  shift_16(.In(mux_R8), .new_bit(New_bit), .Out(shift_R16));
mux_2X1_32bit    mux_16  (.A(mux_R8),  .B(shift_R16), .sel(shift_amount[4] & ~Reserved), .Y(mux_R16));


//--------------------- reverse Output for Left shift -----------------------
reverse_32bit    reverse_out (.orig(mux_R16), .rev(reversed_out));
mux_2X1_32bit    mux_rev_out (.A(mux_R16),    .B(reversed_out),  .sel(Left_logic), .Y(data_out));

endmodule
