module multiplier_16X16(
    input  logic [15:0] A, B,
    output logic [31:0] S
);

// Lower 8-bit of B (B[7:0])
wire logic [15:0] q0, q1, Q_1;
multiplier_8X8      L_A0_A7  (.A(A[7:0]),  .B(B[7:0]), .S(q0) );
multiplier_8X8      L_A8_A15 (.A(A[15:8]), .B(B[7:0]), .S(q1) );
assign S[7:0] = q0[7:0];

full_adder_16bit  Add_low   (.A(q1), .B({8'b0, q0[15:8]}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_1), .C_out() );

// Higher 8-bit of B (B[15:8])
wire logic [15:0] q2, q3;
wire logic [31:0] Q_2;
multiplier_8X8      H_A0_A7  (.A(A[7:0]),  .B(B[15:8]), .S(q2) );
multiplier_8X8      H_A8_A15 (.A(A[15:8]), .B(B[15:8]), .S(q3) );

full_adder_32bit   Add_high (.A({8'b0, q3, 8'b0}), .B({16'b0, q2}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_2), .C_out() );


// Combine result
wire logic [31:0] Q_3;
full_adder_32bit  Combine   (.A(Q_2), .B({16'b0, Q_1}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_3), .C_out()    );
assign S[31:8] = Q_3[23:0];

endmodule

