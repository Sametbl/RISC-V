module D_flip_flop(
		input  logic rst_n, clk, en,
		input  logic D,
		output logic Q
);

always_ff@(posedge clk, negedge rst_n) begin
		if(!rst_n)				Q  <=  0;
		else if(en)     		Q  <=  D;
		else         			Q  <=  Q;
end
endmodule



