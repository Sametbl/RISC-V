module Half_Adder(
    input  logic A, B,
    output logic Sum, C_out
);

assign Sum   = A ^ B;
assign C_out = A & B;

endmodule