// OR GATE
module OR_gate_32bit(
	input  logic [31:0] A, B,
	output logic [31:0] S
);

assign S = A | B;
endmodule


// AND GATE
module AND_gate_32bit(
	input  logic [31:0] A, B,
	output logic [31:0] S
);

assign S = A & B;
endmodule



// XOR GATE
module XOR_gate_32bit(
	input  logic [31:0] A, B,
	output logic [31:0] S
);

assign S = A ^ B;
endmodule