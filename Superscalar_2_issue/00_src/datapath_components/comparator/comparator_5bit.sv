module comparator_5bit(
    input  logic [4:0] A, B,
    output logic equal, larger, smaller
);

logic [4:0] AB_eq;
assign AB_eq[4] = ~(A[4] ^ B[4]);
assign AB_eq[3] = ~(A[3] ^ B[3]);
assign AB_eq[2] = ~(A[2] ^ B[2]);
assign AB_eq[1] = ~(A[1] ^ B[1]);
assign AB_eq[0] = ~(A[0] ^ B[0]);

assign larger = (A[4] & ~B[4]) |
                (A[3] & ~B[3] & AB_eq[4]) |
                (A[2] & ~B[2] & AB_eq[4] & AB_eq[3]) |
                (A[1] & ~B[1] & AB_eq[4] & AB_eq[3] & AB_eq[2]) |
                (A[0] & ~B[0] & AB_eq[4] & AB_eq[3] & AB_eq[2] & AB_eq[1]);

assign equal  = AB_eq[4] & AB_eq[3] & AB_eq[2] & AB_eq[1] & AB_eq[0];
assign smaller = ~(equal | larger);
endmodule
