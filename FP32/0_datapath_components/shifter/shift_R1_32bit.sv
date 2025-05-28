module shift_R1_32bit(
		input  logic [31:0] In,
		input  logic new_bit,
		output logic [31:0] Out
);

assign Out[31]   = new_bit; 
assign Out[30:0] = In[31:1];
endmodule


