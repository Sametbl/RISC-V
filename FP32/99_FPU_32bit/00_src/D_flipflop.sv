module D_flip_flop(
		input  logic D, clear, preset, clk, En,
		output logic Q
);

always_ff@(posedge clk, negedge clear, negedge preset) begin
		if(!clear)				Q  <=  0;
		else if(!preset)     Q  <=  1;
		else if(En)				Q  <=  D;
end
endmodule


