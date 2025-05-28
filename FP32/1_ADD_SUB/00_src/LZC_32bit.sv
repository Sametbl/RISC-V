module LZC_32bit(                       // Leading Zero Counter 32-bit
    input  logic [31:0] i_data,         // input data
    output logic [4:0]  o_NLZ,          // Number of Leading Zero
    output logic        o_all_zero      // HIGH to indicates input is all zeros
);

wire logic [7:0] a;
wire logic [1:0] z0, z1, z2, z3, z4, z5, z6, z7;

NLC_4bit    NLC_7 (.i_data(i_data[31:28]), .zero(z7), .o_all_zero(a[7]) );
NLC_4bit    NLC_6 (.i_data(i_data[27:24]), .zero(z6), .o_all_zero(a[6]) );
NLC_4bit    NLC_5 (.i_data(i_data[23:20]), .zero(z5), .o_all_zero(a[5]) );
NLC_4bit    NLC_4 (.i_data(i_data[19:16]), .zero(z4), .o_all_zero(a[4]) );
NLC_4bit    NLC_3 (.i_data(i_data[15:12]), .zero(z3), .o_all_zero(a[3]) );
NLC_4bit    NLC_2 (.i_data(i_data[11:8]),  .zero(z2), .o_all_zero(a[2]) );
NLC_4bit    NLC_1 (.i_data(i_data[7:4]),   .zero(z1), .o_all_zero(a[1]) );
NLC_4bit    NLC_0 (.i_data(i_data[3:0]),   .zero(z0), .o_all_zero(a[0]) );

BNE   Boundary_Nibble_Encoder ( .a(a), .y(o_NLZ[4:2]), .Q(o_all_zero) );

wire logic [7:0] mux_data_1, mux_data_2;
assign mux_data_1 = {z0[0],  z1[0], z2[0], z3[0], z4[0], z5[0], z6[0], z7[0]};
assign mux_data_2 = {z0[1],  z1[1], z2[1], z3[1], z4[1], z5[1], z6[1], z7[1]};

mux_8X1    bit0_o_NLZ   (.sel(o_NLZ[4:2]), .D(mux_data_1), .Y(o_NLZ[0]) );                      
mux_8X1    bit1_o_NLZ   (.sel(o_NLZ[4:2]), .D(mux_data_2), .Y(o_NLZ[1]) );

endmodule : LZC_32bit
                  




// The Nibble Local Count (NLC) counts the number of zero of the 4 bit number:

module NLC_4bit (                  
    input  logic [3:0] i_data,
    output logic [1:0] zero,            // Number of zero-bits
    output logic       o_all_zero
);
// Extract each bit of input data
wire logic A, B ,C ,D;
assign A = i_data[3];
assign B = i_data[2];
assign C = i_data[1];
assign D = i_data[0];

assign zero[1]    = ~(A | B);           // High when two first MSB is LOW
assign zero[0]    = ~(A | (~B & C));    // High when {ABC} = 3'b01X , or {ABC} = 3'b000
assign o_all_zero = ~(A | B | C | D);
endmodule : NLC_4bit



// Boundary Nibble Encoder (BNE) 
module BNE(
    input  logic [7:0] a,
    output logic [2:0] y,
    output logic Q
);

// All_zero: When all four-bit local counter modules are zeros
assign Q    =  a[7] & a[6] & a[5] & a[4] & a[3] & a[2] & a[1] & a[0];
assign y[2] =  a[7] & a[6] & a[5] & a[4];           // o_NLZ > 15: When first 16 MSB are zero 
assign y[1] =  a[7] & a[6] & (~a[5] | ~a[4] | (a[3] & a[2]) );
assign y[0] = (a[7] & (~a[6] | ( a[5] & ~a[4]))) | (a[7] & a[5] & a[3] & (~a[2] | a[1]));

endmodule : BNE







