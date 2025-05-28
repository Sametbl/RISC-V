module Shifter_32bit(
		input  logic [31:0] data_in,        
		input  logic [4:0] shift_amount,   
		input  logic [1:0] mode,           
		output logic [31:0] data_out       
);
wire logic [31:0] reversed_in, reversed_out, bin_in;
wire logic [31:0] Shift_R1, Shift_R2, Shift_R4, Shift_R8, Shift_R16;
wire logic [31:0] Mux_R1, Mux_R2, Mux_R4, Mux_R8, Mux_R16;
wire logic Left_logic, Right_arith, Reserved;
wire logic New_bit;
                                            // mode = 2'b00 : shift Right logic (Default)
assign Left_logic  = ~mode[1] &  mode[0];   // mode = 2;b01 : shift Left  logic
assign Right_arith =  mode[1] & ~mode[0];   // mode = 2'b10 : shift Right Arithmetic
assign Reserved    =  mode[1] &  mode[0];   // mode = 2'b11 : Reserved

assign New_bit = Right_arith & data_in[31];  // For Right shift arithmetic, New_bit = Sign_bit 

//--------------------- Reverse Input for Left shift -------------------
Reverse_32bit    Reverse_in (.orig(data_in), .rev(reversed_in));
Mux_2X1_32bit    Mux_rev_in (.A(data_in),    .B(reversed_in),  .Sel(Left_logic), .OUT(bin_in));


//--------------------- Performing Right shift ---------------------

Shift_R1_32bit   Shift_1 (.In(bin_in), .new_bit(New_bit), .Out(Shift_R1));
Mux_2X1_32bit    Mux_1   (.A(bin_in),  .B(Shift_R1), .Sel(shift_amount[0] & ~Reserved), .OUT(Mux_R1));

Shift_R2_32bit   Shift_2 (.In(Mux_R1), .new_bit(New_bit), .Out(Shift_R2));
Mux_2X1_32bit    Mux_2   (.A(Mux_R1),  .B(Shift_R2), .Sel(shift_amount[1] & ~Reserved), .OUT(Mux_R2));
																					
Shift_R4_32bit   Shift_4 (.In(Mux_R2), .new_bit(New_bit), .Out(Shift_R4));
Mux_2X1_32bit    Mux_4   (.A(Mux_R2),  .B(Shift_R4), .Sel(shift_amount[2] & ~Reserved), .OUT(Mux_R4));

Shift_R8_32bit   Shift_8 (.In(Mux_R4), .new_bit(New_bit), .Out(Shift_R8));
Mux_2X1_32bit    Mux_8   (.A(Mux_R4),  .B(Shift_R8), .Sel(shift_amount[3] & ~Reserved), .OUT(Mux_R8));

Shift_R16_32bit  Shift_16(.In(Mux_R8), .new_bit(New_bit), .Out(Shift_R16));
Mux_2X1_32bit    Mux_16  (.A(Mux_R8),  .B(Shift_R16), .Sel(shift_amount[4] & ~Reserved), .OUT(Mux_R16));


//--------------------- Reverse Output for Left shift -----------------------
Reverse_32bit    Reverse_out (.orig(Mux_R16), .rev(reversed_out));
Mux_2X1_32bit    Mux_rev_out (.A(Mux_R16),    .B(reversed_out),  .Sel(Left_logic), .OUT(data_out));

endmodule