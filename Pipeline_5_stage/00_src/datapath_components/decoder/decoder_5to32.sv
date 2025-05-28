module decoder_5to32(
		input  logic [4:0] sel,
		input  logic en, 
		output logic [31:0] Y
); 
decoder_4to16		Bottom(.en(~sel[4] & en), .sel(sel[3:0]), .Y(Y[15:0]));
decoder_4to16		Top   (.en( sel[4] & en), .sel(sel[3:0]), .Y(Y[31:16]));
endmodule 

