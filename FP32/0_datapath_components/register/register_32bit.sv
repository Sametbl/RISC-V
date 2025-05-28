module register_32bit(
		input  logic en, clk, rst_n, 
		input  logic [31:0] D,
		output logic [31:0] Q
);


D_flip_flop			Q0  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[0]),  .Q(Q[0]));
D_flip_flop			Q1  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[1]),  .Q(Q[1]));
D_flip_flop			Q2  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[2]),  .Q(Q[2]));
D_flip_flop			Q3  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[3]),  .Q(Q[3]));
D_flip_flop			Q4  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[4]),  .Q(Q[4]));
D_flip_flop			Q5  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[5]),  .Q(Q[5]));
D_flip_flop			Q6  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[6]),  .Q(Q[6]));
D_flip_flop			Q7  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[7]),  .Q(Q[7]));
D_flip_flop			Q8  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[8]),  .Q(Q[8]));
D_flip_flop			Q9  (.clk(clk), .en(en), .rst_n(rst_n), .D(D[9]),  .Q(Q[9]));
D_flip_flop			Q10 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[10]), .Q(Q[10]));
D_flip_flop			Q11 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[11]), .Q(Q[11]));
D_flip_flop			Q12 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[12]), .Q(Q[12]));
D_flip_flop			Q13 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[13]), .Q(Q[13]));
D_flip_flop			Q14 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[14]), .Q(Q[14]));
D_flip_flop			Q15 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[15]), .Q(Q[15]));
D_flip_flop			Q16 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[16]), .Q(Q[16]));
D_flip_flop			Q17 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[17]), .Q(Q[17]));
D_flip_flop			Q18 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[18]), .Q(Q[18]));
D_flip_flop			Q19 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[19]), .Q(Q[19]));
D_flip_flop			Q20 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[20]), .Q(Q[20]));
D_flip_flop			Q21 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[21]), .Q(Q[21]));
D_flip_flop			Q22 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[22]), .Q(Q[22]));
D_flip_flop			Q23 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[23]), .Q(Q[23]));
D_flip_flop			Q24 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[24]), .Q(Q[24]));
D_flip_flop			Q25 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[25]), .Q(Q[25]));
D_flip_flop			Q26 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[26]), .Q(Q[26]));
D_flip_flop			Q27 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[27]), .Q(Q[27]));
D_flip_flop			Q28 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[28]), .Q(Q[28]));
D_flip_flop			Q29 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[29]), .Q(Q[29]));
D_flip_flop			Q30 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[30]), .Q(Q[30]));
D_flip_flop			Q31 (.clk(clk), .en(en), .rst_n(rst_n), .D(D[31]), .Q(Q[31]));

endmodule

