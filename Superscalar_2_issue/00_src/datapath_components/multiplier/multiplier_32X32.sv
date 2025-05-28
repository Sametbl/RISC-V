module multiplier_32X32(
    input  logic [31:0] A, B,
    output logic [63:0] S
);

// Lower 16-bit of B (B[15:0])
wire logic [31:0] q0, q1, Q_1;
multiplier_16X16      L_A0_A15  (.A(A[15:0]),  .B(B[15:0]), .S(q0) );
multiplier_16X16      L_A16_A31 (.A(A[31:16]), .B(B[15:0]), .S(q1) );
assign S[15:0] = q0[15:0];

full_adder_32bit   Add_low  (.A(q1), .B({16'b0, q0[31:16]}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_1), .C_out() );

// Higher 16-bit of B (B[31:16])
wire logic [31:0] q2, q3;
wire logic [63:0] Q_2;
multiplier_16X16      H_A0_A15  (.A(A[15:0]),  .B(B[31:16]), .S(q2) );
multiplier_16X16      H_A16_A31 (.A(A[31:16]), .B(B[31:16]), .S(q3) );

full_adder_64bit  Add_high  (.A({16'b0, q3, 16'b0}), .B({32'b0, q2}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_2), .C_out() );


// Combine result
wire logic [63:0] Q_3;
full_adder_64bit  Combine  (.A(Q_2), .B({32'b0, Q_1}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_3), .C_out()    );
assign S[63:16] = Q_3[47:0];

endmodule

