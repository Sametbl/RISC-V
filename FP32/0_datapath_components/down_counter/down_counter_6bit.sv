module down_counter_6bit(
        input  logic clk, rst_n, en,
        output logic [5:0] Q
);

D_flip_flop	Q0 (.clk(clk),  .en(en), .rst_n(rst_n), .D(~Q[0]), .Q(Q[0]));
D_flip_flop	Q1 (.clk(Q[0]), .en(en), .rst_n(rst_n), .D(~Q[1]), .Q(Q[1]));
D_flip_flop	Q2 (.clk(Q[1]), .en(en), .rst_n(rst_n), .D(~Q[2]), .Q(Q[2]));
D_flip_flop	Q3 (.clk(Q[2]), .en(en), .rst_n(rst_n), .D(~Q[3]), .Q(Q[3]));
D_flip_flop	Q4 (.clk(Q[3]), .en(en), .rst_n(rst_n), .D(~Q[4]), .Q(Q[4]));
D_flip_flop	Q5 (.clk(Q[4]), .en(en), .rst_n(rst_n), .D(~Q[5]), .Q(Q[5]));

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
