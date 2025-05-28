module register_8bit(
		input  logic en, clk, rst_n, 
		input  logic [7:0] D,
		output logic [7:0] Q
);


D_flip_flop			Q0  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[0]),  .Q(Q[0]));
D_flip_flop			Q1  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[1]),  .Q(Q[1]));
D_flip_flop			Q2  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[2]),  .Q(Q[2]));
D_flip_flop			Q3  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[3]),  .Q(Q[3]));
D_flip_flop			Q4  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[4]),  .Q(Q[4]));
D_flip_flop			Q5  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[5]),  .Q(Q[5]));
D_flip_flop			Q6  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[6]),  .Q(Q[6]));
D_flip_flop			Q7  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[7]),  .Q(Q[7]));

endmodule

