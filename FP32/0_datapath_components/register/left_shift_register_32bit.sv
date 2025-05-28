module left_shift_register_32bit(
        input  logic        clk,
        input  logic        rst_n,
        input  logic        en,
        input  logic        c_in,
        input  logic        ld,
        input  logic [31:0] ld_data,
        output logic [31:0] Q
);

wire logic [31:0] D;
wire logic [31:0] shift_data;
wire logic        enable;
assign enable     = ld | en;
assign shift_data = {Q[30:0], c_in};

mux_2X1_32bit load (.sel(ld), .A(shift_data), .B(ld_data), .Y(D));

D_flip_flop   Q0   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[0]),  .Q(Q[0]));
D_flip_flop   Q1   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[1]),  .Q(Q[1]));
D_flip_flop   Q2   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[2]),  .Q(Q[2]));
D_flip_flop   Q3   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[3]),  .Q(Q[3]));
D_flip_flop   Q4   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[4]),  .Q(Q[4]));
D_flip_flop   Q5   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[5]),  .Q(Q[5]));
D_flip_flop   Q6   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[6]),  .Q(Q[6]));
D_flip_flop   Q7   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[7]),  .Q(Q[7]));
D_flip_flop   Q8   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[8]),  .Q(Q[8]));
D_flip_flop   Q9   (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[9]),  .Q(Q[9]));
D_flip_flop   Q10  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[10]), .Q(Q[10]));
D_flip_flop   Q11  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[11]), .Q(Q[11]));
D_flip_flop   Q12  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[12]), .Q(Q[12]));
D_flip_flop   Q13  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[13]), .Q(Q[13]));
D_flip_flop   Q14  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[14]), .Q(Q[14]));
D_flip_flop   Q15  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[15]), .Q(Q[15]));
D_flip_flop   Q16  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[16]), .Q(Q[16]));
D_flip_flop   Q17  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[17]), .Q(Q[17]));
D_flip_flop   Q18  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[18]), .Q(Q[18]));
D_flip_flop   Q19  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[19]), .Q(Q[19]));
D_flip_flop   Q20  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[20]), .Q(Q[20]));
D_flip_flop   Q21  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[21]), .Q(Q[21]));
D_flip_flop   Q22  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[22]), .Q(Q[22]));
D_flip_flop   Q23  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[23]), .Q(Q[23]));
D_flip_flop   Q24  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[24]), .Q(Q[24]));
D_flip_flop   Q25  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[25]), .Q(Q[25]));
D_flip_flop   Q26  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[26]), .Q(Q[26]));
D_flip_flop   Q27  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[27]), .Q(Q[27]));
D_flip_flop   Q28  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[28]), .Q(Q[28]));
D_flip_flop   Q29  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[29]), .Q(Q[29]));
D_flip_flop   Q30  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[30]), .Q(Q[30]));
D_flip_flop   Q31  (.clk(clk), .rst_n(rst_n), .en(enable), .D(D[31]), .Q(Q[31]));

endmodule

