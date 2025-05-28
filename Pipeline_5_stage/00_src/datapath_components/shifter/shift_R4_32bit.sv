module shift_R4_32bit(
		input  logic [31:0] In,
		input  logic new_bit,
		output logic [31:0] Out
);

assign Out[31]   = new_bit; 
assign Out[30]   = new_bit; 
assign Out[29]   = new_bit; 
assign Out[28]   = new_bit; 

assign Out[27:0] = In[31:4];
endmodule


