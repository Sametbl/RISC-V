module multiplier_4X4(
    input  logic [3:0] A, B,
    output logic [7:0] S
);

wire logic [3:0] P0, P1, P2, P3;
partial_product_generator_4X4    Partial_Product (.A(A), .B(B), .PP0(P0), .PP1(P1), .PP2(P2), .PP3(P3)  ); 

//                              A3     A2     A1     A0
//                              B3     B2     B1     B0
//------------------------------------------------------------
//                              P0[3]  P0[2]  P0[1]  P0[0]       ; Row 1
//                       P1[3]  P1[2]  P1[1]  P1[0]              ; Row 2 
//                P2[3]  P2[2]  P2[1]  P2[0]                     ; Row 3
//         P3[3]  P3[2]  P3[1]  P3[0]                            ; Row 4
//------------------------------------------------------------
//  C_out   S[6]   S[5]   S[4]   S[3]   S[2]   S[1]   S[0]       

//   7      6      5      4      3      2      1       0         ; Column


// First Digit
assign S[0] = P0[0];


// Stage 1 (S1): Add the first 2 or 3 PPs 
wire logic T1_S0, T1_S1, T1_S2, T1_S3; // Stage 1: Sum 0, 1, 2, 3 
wire logic T1_C0, T1_C1, T1_C2, T1_C3; // Stage 1: Carry out 0, 1, 2, 3
half_adder   a0 (.A(P0[1]), .B(P1[0]),               .Sum(T1_S0), .C_out(T1_C0) );
full_adder   a1 (.A(P0[2]), .B(P1[1]), .C_in(P2[0]), .Sum(T1_S1), .C_out(T1_C1) );
full_adder   a2 (.A(P0[3]), .B(P1[2]), .C_in(P2[1]), .Sum(T1_S2), .C_out(T1_C2) );
half_adder   a3 (.A(P1[3]), .B(P2[2]),               .Sum(T1_S3), .C_out(T1_C3) );
assign S[1] = T1_S0;

// Stage 2 (S2): Continue adding the previous Sum with the next PPs and Carry out 
wire logic T2_S0, T2_S1, T2_S2, T2_S3; // Stage 2: Sum 0, 1, 2, 3 
wire logic T2_C0, T2_C1, T2_C2, T2_C3; // Stage 2: Carry out 0, 1, 2, 3
half_adder   b0 (.A(T1_C0), .B(T1_S1),               .Sum(T2_S0), .C_out(T2_C0) );
full_adder   b1 (.A(T1_C1), .B(T1_S2), .C_in(P3[0]), .Sum(T2_S1), .C_out(T2_C1) );
full_adder   b2 (.A(T1_C2), .B(T1_S3), .C_in(P3[1]), .Sum(T2_S2), .C_out(T2_C2) );
full_adder   b3 (.A(T1_C3), .B(P2[3]), .C_in(P3[2]), .Sum(T2_S3), .C_out(T2_C3) );
assign S[2] = T2_S0;


// Stage 3 (S3): Add the last P3[3] and all they Sum and Carries together
wire logic T3_S0, T3_S1, T3_S2, T3_S3; // Stage 3: Sum 0, 1, 2, 3 
wire logic T3_C0, T3_C1, T3_C2, T3_C3; // Stage 3: Carry out 0, 1, 2, 3
half_adder   c0 (.A(T2_C0), .B(T2_S1),               .Sum(T3_S0), .C_out(T3_C0) );
full_adder   c1 (.A(T2_C1), .B(T2_S2), .C_in(T3_C0), .Sum(T3_S1), .C_out(T3_C1) );
full_adder   c2 (.A(T2_C2), .B(T2_S3), .C_in(T3_C1), .Sum(T3_S2), .C_out(T3_C2) );
full_adder   c3 (.A(T2_C3), .B(P3[3]), .C_in(T3_C2), .Sum(T3_S3), .C_out(T3_C3) );

assign S[3] = T3_S0;
assign S[4] = T3_S1;
assign S[5] = T3_S2;
assign S[6] = T3_S3;
assign S[7] = T3_C3;

endmodule


