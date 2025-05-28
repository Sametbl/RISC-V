module partial_product_generator_4X4(
    input  logic [3:0] A, B,
    output logic [3:0] PP0, PP1, PP2, PP3 // Partial Product
); 

// Partial Product: each bit of B AND with all bit of A respectively
assign PP0[0] = B[0] & A[0];
assign PP0[1] = B[0] & A[1];
assign PP0[2] = B[0] & A[2];
assign PP0[3] = B[0] & A[3];

assign PP1[0] = B[1] & A[0];
assign PP1[1] = B[1] & A[1];
assign PP1[2] = B[1] & A[2];
assign PP1[3] = B[1] & A[3];

assign PP2[0] = B[2] & A[0];
assign PP2[1] = B[2] & A[1];
assign PP2[2] = B[2] & A[2];
assign PP2[3] = B[2] & A[3];

assign PP3[0] = B[3] & A[0];
assign PP3[1] = B[3] & A[1];
assign PP3[2] = B[3] & A[2];
assign PP3[3] = B[3] & A[3];

endmodule

