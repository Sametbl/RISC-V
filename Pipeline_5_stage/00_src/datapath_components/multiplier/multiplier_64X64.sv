module multiplier_64X64(
    input  logic [63:0]  A, B,
    output logic [127:0] S
);

// Lower 32-bit of B (B[31:0])
wire logic [63:0] q0, q1, Q_1;
multiplier_32X32      L_A0_A31  (.A(A[31:0]),  .B(B[31:0]), .S(q0) );
multiplier_32X32      L_A32_A63 (.A(A[63:32]), .B(B[31:0]), .S(q1) );
assign S[31:0] = q0[31:0];
 
full_adder_64bit     Add_low   (.A(q1), .B({32'b0, q0[63:32]}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_1), .C_out() );

// Higher 32-bit of B (B[63:32])
wire logic [63:0]  q2, q3;
wire logic [127:0] Q_2;
multiplier_32X32      H_A0_A31  (.A(A[31:0]),  .B(B[63:32]), .S(q2) );
multiplier_32X32      H_A32_A63 (.A(A[63:32]), .B(B[63:32]), .S(q3) );

full_adder_128bit    Add_high  (.A({32'b0, q3, 32'b0}), .B({64'b0, q2}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_2), .C_out() );


// Combine result
wire logic [127:0] Q_3;
full_adder_128bit    Combine   (.A(Q_2), .B({64'b0, Q_1}), .Invert_B(1'b0), .C_in(1'b0), .Sum(Q_3), .C_out()    );
assign S[127:32] = Q_3[95:0];

endmodule

