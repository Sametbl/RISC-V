module Multiplier_8X8(
    input  logic [7:0] A, B,
    output logic [15:0] S
);

// Lower 4-bit of B (B[3:0])
wire logic [7:0] q0, q1, Q_1;
Multiplier_4X4      L_A0_A3 (.A(A[3:0]), .B(B[3:0]), .S(q0) );
Multiplier_4X4      L_A4_A7 (.A(A[7:4]), .B(B[3:0]), .S(q1) );
assign S[3:0] = q0[3:0];

Full_Adder_8bit   Add_low  (.A(q1), .B({4'b0000, q0[7:4]}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_1), .C_out() );

// Higher 4-bit of B (B[7:4])
wire logic [7:0] q2, q3;
wire logic [15:0] Q_2;
Multiplier_4X4      H_A0_A3 (.A(A[3:0]), .B(B[7:4]), .S(q2) );
Multiplier_4X4      H_A4_A7 (.A(A[7:4]), .B(B[7:4]), .S(q3) );

Full_Adder_16bit   Add_high (.A({4'b0000, q3, 4'b0000}), .B({8'b00000000, q2}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_2), .C_out() );


// Combine result
wire logic [15:0] Q_3;
Full_Adder_16bit  Combine  (.A(Q_2), .B({8'b00000000, Q_1}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_3), .C_out()    );
assign S[15:4] = Q_3[11:0];

endmodule
