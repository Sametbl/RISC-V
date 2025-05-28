module down_counter_8bit(
        input  logic       clk, 
        input  logic       rst_n,
        input  logic       en,
        input  logic       ld,
        input  logic [7:0] ld_data,
        output logic [7:0] Q
);

wire logic [7:0] D;
wire logic [7:0] toggle;

mux_2X1_8bit   data_in (.sel(ld), .A(~Q), .B(ld_data), .Y(D));

assign toggle[0] = ld | (en);              // LSB toggles when enable is active
assign toggle[1] = ld | (en & ~Q[0]);
assign toggle[2] = ld | (en & ~Q[0] & ~Q[1]);
assign toggle[3] = ld | (en & ~Q[0] & ~Q[1] & ~Q[2]);
assign toggle[4] = ld | (en & ~Q[0] & ~Q[1] & ~Q[2] & ~Q[3]);
assign toggle[5] = ld | (en & ~Q[0] & ~Q[1] & ~Q[2] & ~Q[3] & ~Q[4]);
assign toggle[6] = ld | (en & ~Q[0] & ~Q[1] & ~Q[2] & ~Q[3] & ~Q[4] & ~Q[5]);
assign toggle[7] = ld | (en & ~Q[0] & ~Q[1] & ~Q[2] & ~Q[3] & ~Q[4] & ~Q[5] & ~Q[6]);


D_flip_flop	   Q0  (.clk(clk), .rst_n(rst_n), .en(toggle[0]), .D(D[0]), .Q(Q[0]));
D_flip_flop	   Q1  (.clk(clk), .rst_n(rst_n), .en(toggle[1]), .D(D[1]), .Q(Q[1]));
D_flip_flop	   Q2  (.clk(clk), .rst_n(rst_n), .en(toggle[2]), .D(D[2]), .Q(Q[2]));
D_flip_flop	   Q3  (.clk(clk), .rst_n(rst_n), .en(toggle[3]), .D(D[3]), .Q(Q[3]));
D_flip_flop	   Q4  (.clk(clk), .rst_n(rst_n), .en(toggle[4]), .D(D[4]), .Q(Q[4]));
D_flip_flop	   Q5  (.clk(clk), .rst_n(rst_n), .en(toggle[5]), .D(D[5]), .Q(Q[5]));
D_flip_flop	   Q6  (.clk(clk), .rst_n(rst_n), .en(toggle[6]), .D(D[6]), .Q(Q[6]));
D_flip_flop	   Q7  (.clk(clk), .rst_n(rst_n), .en(toggle[7]), .D(D[7]), .Q(Q[7]));


endmodule 
