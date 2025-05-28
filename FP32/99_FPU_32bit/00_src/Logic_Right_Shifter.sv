//----------------------- Right Shift By 16 -----------------
module Shift_R16_32bit(
		input  logic [31:0] In,
		input  logic new_bit,
		output logic [31:0] Out
);

assign Out[31:16] = {16{new_bit}}; 
assign Out[15:0]  = In[31:16];
endmodule



//----------------------- Right Shift By 8 -------------------
module Shift_R8_32bit(
		input  logic [31:0] In,
		input  logic new_bit,
		output logic [31:0] Out
);

assign Out[31:24] = {8{new_bit}}; 
assign Out[23:0]  = In[31:8];
endmodule



//----------------------- Right Shift By 4 -----------------
module Shift_R4_32bit(
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



//----------------------- Right Shift By 2 -----------------
module Shift_R2_32bit(
		input  logic [31:0] In,
		input  logic new_bit,
		output logic [31:0] Out
);

assign Out[31]   = new_bit; 
assign Out[30]   = new_bit; 
assign Out[29:0] = In[31:2];
endmodule


//---------------------- Right Shift by 1 -------------------


module Shift_R1_32bit(
		input  logic [31:0] In,
		input  logic new_bit,
		output logic [31:0] Out
);

assign Out[31]   = new_bit; 
assign Out[30:0] = In[31:1];
endmodule