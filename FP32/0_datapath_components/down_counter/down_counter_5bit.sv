module down_counter_5bit(
        input  logic [4:0] ld_data,
        input  logic load, clk, reset, En,
        output logic [4:0] Q
);
reg [4:0] Count;

always_ff@(posedge clk, negedge reset, negedge load) begin
		if(!reset)        Count    <= 5'b0;
		else if(!load)    Count    <= ld_data;
	   else if(En)       Count    <= Count - 1;
end	

assign Q = Count;
endmodule

//// Reset and Load of D_flipflop ar e ACTIVE LOW
//// "clear" and "load" are ACTIVE LOW
//wire logic [4:0] clear, preset;
//assign clear  = {5{reset}} & ( {5{load}} | ld_data );  // ACTIVE LOW clear: Negedge reset, or  ld_data = 0 and load = 0
//assign preset = ~ld_data | {5{load}};                  // ACTIVE LOW preset: ld_data = 1 and load = 0 
//
//D_flip_flop			Q0 (.clk(clk),  .En(En), .clear(clear[0]), .preset(preset[0]), .D(~Q[0]), .Q(Q[0]));
//D_flip_flop			Q1 (.clk(Q[0]), .En(En), .clear(clear[1]), .preset(preset[1]), .D(~Q[1]), .Q(Q[1]));
//D_flip_flop			Q2 (.clk(Q[1]), .En(En), .clear(clear[2]), .preset(preset[2]), .D(~Q[2]), .Q(Q[2]));
//D_flip_flop			Q3 (.clk(Q[2]), .En(En), .clear(clear[3]), .preset(preset[3]), .D(~Q[3]), .Q(Q[3]));
//D_flip_flop			Q4 (.clk(Q[3]), .En(En), .clear(clear[4]), .preset(preset[4]), .D(~Q[4]), .Q(Q[4]));

