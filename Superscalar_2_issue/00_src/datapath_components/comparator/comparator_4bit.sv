module comparator_4bit(
    input  logic [3:0] A, B,
    output logic equal, larger, smaller
);

logic [3:0] AB_eq;
assign AB_eq[3] = ~(A[3] ^ B[3]);
assign AB_eq[2] = ~(A[2] ^ B[2]);
assign AB_eq[1] = ~(A[1] ^ B[1]);
assign AB_eq[0] = ~(A[0] ^ B[0]);

assign larger = (A[3] & ~B[3]) |
                (A[2] & ~B[2] & AB_eq[3]) |
                (A[1] & ~B[1] & AB_eq[3] & AB_eq[2]) |
                (A[0] & ~B[0] & AB_eq[3] & AB_eq[2] & AB_eq[1]);

assign equal  = AB_eq[3] & AB_eq[2] & AB_eq[1] & AB_eq[0];
assign smaller = ~(equal | larger);
endmodule
