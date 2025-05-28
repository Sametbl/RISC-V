module register_4bit(
		input  logic [3:0] D,
		input  logic en, clk, rst_n, // reset is active LOW
		output logic [3:0] Q
);
D_flip_flop			Q0 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[0]),  .Q(Q[0]));
D_flip_flop			Q1 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[1]),  .Q(Q[1]));
D_flip_flop			Q2 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[2]),  .Q(Q[2]));
D_flip_flop			Q3 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[3]),  .Q(Q[3]));

endmodule

