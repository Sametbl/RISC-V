module shift_R16_32bit(
		input  logic [31:0] In,
		input  logic new_bit,
		output logic [31:0] Out
);

assign Out[31:16] = {16{new_bit}}; 
assign Out[15:0]  = In[31:16];
endmodule


