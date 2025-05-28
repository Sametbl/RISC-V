module decoder_3to8(
		input  logic [2:0] sel,
		input  logic en, 
		output logic [7:0] Y
); 
decoder_2to4		Bottom(.en(~sel[2] & en), .sel(sel[1:0]), .Y(Y[3:0]));
decoder_2to4		Top   (.en( sel[2] & en), .sel(sel[1:0]), .Y(Y[7:4]));
endmodule 

