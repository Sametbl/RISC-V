module down_counter_32bit(
        input  logic clk, rst_n, en,
        output logic [31:0] Q
);


D_flip_flop	Q0  (.clk(clk),   .en(en), .rst_n(rst_n),  .D(~Q[0]),  .Q(Q[0]));
D_flip_flop	Q1  (.clk(Q[0]),  .en(en), .rst_n(rst_n),  .D(~Q[1]),  .Q(Q[1]));
D_flip_flop	Q2  (.clk(Q[1]),  .en(en), .rst_n(rst_n),  .D(~Q[2]),  .Q(Q[2]));
D_flip_flop	Q3  (.clk(Q[2]),  .en(en), .rst_n(rst_n),  .D(~Q[3]),  .Q(Q[3]));
D_flip_flop	Q4  (.clk(Q[3]),  .en(en), .rst_n(rst_n),  .D(~Q[4]),  .Q(Q[4]));
D_flip_flop	Q5  (.clk(Q[4]),  .en(en), .rst_n(rst_n),  .D(~Q[5]),  .Q(Q[5]));
D_flip_flop	Q6  (.clk(Q[5]),  .en(en), .rst_n(rst_n),  .D(~Q[6]),  .Q(Q[6]));
D_flip_flop	Q7  (.clk(Q[6]),  .en(en), .rst_n(rst_n),  .D(~Q[7]),  .Q(Q[7]));
D_flip_flop	Q8  (.clk(Q[7]),  .en(en), .rst_n(rst_n),  .D(~Q[8]),  .Q(Q[8]));
D_flip_flop	Q9  (.clk(Q[8]),  .en(en), .rst_n(rst_n),  .D(~Q[9]),  .Q(Q[9]));
D_flip_flop	Q10 (.clk(Q[9]),  .en(en), .rst_n(rst_n),  .D(~Q[10]), .Q(Q[10]));
D_flip_flop	Q11 (.clk(Q[10]), .en(en), .rst_n(rst_n),  .D(~Q[11]), .Q(Q[11]));
D_flip_flop	Q12 (.clk(Q[11]), .en(en), .rst_n(rst_n),  .D(~Q[12]), .Q(Q[12]));
D_flip_flop	Q13 (.clk(Q[12]), .en(en), .rst_n(rst_n),  .D(~Q[13]), .Q(Q[13]));
D_flip_flop	Q14 (.clk(Q[13]), .en(en), .rst_n(rst_n),  .D(~Q[14]), .Q(Q[14]));
D_flip_flop	Q15 (.clk(Q[14]), .en(en), .rst_n(rst_n),  .D(~Q[15]), .Q(Q[15]));
D_flip_flop	Q16 (.clk(Q[15]), .en(en), .rst_n(rst_n),  .D(~Q[16]), .Q(Q[16]));
D_flip_flop	Q17 (.clk(Q[16]), .en(en), .rst_n(rst_n),  .D(~Q[17]), .Q(Q[17]));
D_flip_flop	Q18 (.clk(Q[17]), .en(en), .rst_n(rst_n),  .D(~Q[18]), .Q(Q[18]));
D_flip_flop	Q19 (.clk(Q[18]), .en(en), .rst_n(rst_n),  .D(~Q[19]), .Q(Q[19]));
D_flip_flop	Q20 (.clk(Q[19]), .en(en), .rst_n(rst_n),  .D(~Q[20]), .Q(Q[20]));
D_flip_flop	Q21 (.clk(Q[20]), .en(en), .rst_n(rst_n),  .D(~Q[21]), .Q(Q[21]));
D_flip_flop	Q22 (.clk(Q[21]), .en(en), .rst_n(rst_n),  .D(~Q[22]), .Q(Q[22]));
D_flip_flop	Q23 (.clk(Q[22]), .en(en), .rst_n(rst_n),  .D(~Q[23]), .Q(Q[23]));
D_flip_flop	Q24 (.clk(Q[23]), .en(en), .rst_n(rst_n),  .D(~Q[24]), .Q(Q[24]));
D_flip_flop	Q25 (.clk(Q[24]), .en(en), .rst_n(rst_n),  .D(~Q[25]), .Q(Q[25]));
D_flip_flop	Q26 (.clk(Q[25]), .en(en), .rst_n(rst_n),  .D(~Q[26]), .Q(Q[26]));
D_flip_flop	Q27 (.clk(Q[26]), .en(en), .rst_n(rst_n),  .D(~Q[27]), .Q(Q[27]));
D_flip_flop	Q28 (.clk(Q[27]), .en(en), .rst_n(rst_n),  .D(~Q[28]), .Q(Q[28]));
D_flip_flop	Q29 (.clk(Q[28]), .en(en), .rst_n(rst_n),  .D(~Q[29]), .Q(Q[29]));
D_flip_flop	Q30 (.clk(Q[29]), .en(en), .rst_n(rst_n),  .D(~Q[30]), .Q(Q[30]));
D_flip_flop	Q31 (.clk(Q[30]), .en(en), .rst_n(rst_n),  .D(~Q[31]), .Q(Q[31]));



endmodule 

//reg [5:0] Count;
//
//always_ff@(posedge clk, negedge reset, negedge load) begin
//		if(!reset)        Count    <= 6'b0;
//		else if(!load)    Count    <= ld_data;
//	   else if(en)       Count    <= Count - 1;
//end	
//
//assign Q = Count;
//endmodule
