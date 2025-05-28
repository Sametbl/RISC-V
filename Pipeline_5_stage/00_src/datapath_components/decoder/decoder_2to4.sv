module decoder_2to4(
		input  logic en,
		input  logic [1:0] sel,
		output logic [3:0] Y
);

assign Y[0] = en & ~sel[1] & ~sel[0];
assign Y[1] = en & ~sel[1] &  sel[0];
assign Y[2] = en &  sel[1] & ~sel[0];
assign Y[3] = en &  sel[1] &  sel[0];
endmodule
