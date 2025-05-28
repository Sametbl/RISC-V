module right_shift_register_8bit(
        input  logic clk, rst_n, en,
        input  logic D_in,
        output logic [7:0] Q
);

D_flip_flop Q7 (.clk(clk), .en(en), .rst_n(rst_n), .D(D_in),   .Q(Q[7]));
D_flip_flop Q6 (.clk(clk), .en(en), .rst_n(rst_n), .D(Q[7]),   .Q(Q[6]));
D_flip_flop Q5 (.clk(clk), .en(en), .rst_n(rst_n), .D(Q[6]),   .Q(Q[5]));
D_flip_flop Q4 (.clk(clk), .en(en), .rst_n(rst_n), .D(Q[5]),   .Q(Q[4]));
D_flip_flop Q3 (.clk(clk), .en(en), .rst_n(rst_n), .D(Q[4]),   .Q(Q[3]));
D_flip_flop Q2 (.clk(clk), .en(en), .rst_n(rst_n), .D(Q[3]),   .Q(Q[2]));
D_flip_flop Q1 (.clk(clk), .en(en), .rst_n(rst_n), .D(Q[2]),   .Q(Q[1]));
D_flip_flop Q0 (.clk(clk), .en(en), .rst_n(rst_n), .D(Q[1]),   .Q(Q[0]));

endmodule 

