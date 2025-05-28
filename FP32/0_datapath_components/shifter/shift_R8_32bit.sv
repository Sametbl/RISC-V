module shift_R8_32bit(
		input  logic [31:0] In,
		input  logic new_bit,
		output logic [31:0] Out
);

assign Out[31:24] = {8{new_bit}}; 
assign Out[23:0]  = In[31:8];
endmodule

