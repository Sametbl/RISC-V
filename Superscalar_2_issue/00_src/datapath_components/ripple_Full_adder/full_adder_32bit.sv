module full_adder_32bit (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic Invert_B, C_in,
    output logic [31:0] Sum,
    output logic C_out
);

logic Connect;
full_adder_16bit  First (.A(A[15:0]),  .B(B[15:0]),  .Invert_B(Invert_B), .C_in(C_in),    .Sum(Sum[15:0]),  .C_out(Connect));
full_adder_16bit  Second(.A(A[31:16]), .B(B[31:16]), .Invert_B(Invert_B), .C_in(Connect), .Sum(Sum[31:16]), .C_out(C_out) );
endmodule

