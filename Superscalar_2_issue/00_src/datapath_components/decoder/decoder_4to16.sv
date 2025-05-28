module decoder_4to16(
		input  logic [3:0] sel,
		input  logic en, 
		output logic [15:0] Y
); 
decoder_3to8		Bottom(.en(~sel[3] & en), .sel(sel[2:0]), .Y(Y[7:0]));
decoder_3to8		Top   (.en( sel[3] & en), .sel(sel[2:0]), .Y(Y[15:8]));
endmodule 

