module Leading_0_counter_32bit(
    input  logic [31:0] data,
    output logic [4:0] NLZ,
    output logic all_zero
);

wire logic [7:0] a;
wire logic [1:0] z0, z1, z2, z3, z4, z5, z6, z7;

NLC_4bit    NLC_7 (.X(data[31:28]), .Zero(z7), .all_zero(a[7]) );
NLC_4bit    NLC_6 (.X(data[27:24]), .Zero(z6), .all_zero(a[6]) );
NLC_4bit    NLC_5 (.X(data[23:20]), .Zero(z5), .all_zero(a[5]) );
NLC_4bit    NLC_4 (.X(data[19:16]), .Zero(z4), .all_zero(a[4]) );
NLC_4bit    NLC_3 (.X(data[15:12]), .Zero(z3), .all_zero(a[3]) );
NLC_4bit    NLC_2 (.X(data[11:8]),  .Zero(z2), .all_zero(a[2]) );
NLC_4bit    NLC_1 (.X(data[7:4]),   .Zero(z1), .all_zero(a[1]) );
NLC_4bit    NLC_0 (.X(data[3:0]),   .Zero(z0), .all_zero(a[0]) );

BNE   Boundary_Nibble_Encoder ( .a(a), .y(NLZ[4:2]), .Q(all_zero) );

wire logic [7:0] I_mux_1, I_mux_2;
assign I_mux_1 = {z0[0],  z1[0], z2[0], z3[0], z4[0], z5[0], z6[0], z7[0]};
assign I_mux_2 = {z0[1],  z1[1], z2[1], z3[1], z4[1], z5[1], z6[1], z7[1]};

Mux_8X1    bit0_NLZ   (.Sel(NLZ[4:2]), .I(I_mux_1), .OUT(NLZ[0]) );                      
Mux_8X1    bit1_NLZ   (.Sel(NLZ[4:2]), .I(I_mux_2), .OUT(NLZ[1]) );

endmodule
                  

