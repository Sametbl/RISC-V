module comparator_32bit(
	input  logic [31:0] A, B,
	input  logic is_unsigned,
	output logic equal, larger, smaller
);

wire logic sign_diff, both_negative;
assign sign_diff     = ~is_unsigned & (A[31] ^ B[31]);

// Compare each 4-bit groups
wire logic [7:0] eq_4, la_4, sm_4;
comparator_4bit  Layer1_7 (.A(A[31:28]), .B(B[31:28]), .equal(eq_4[7]), .larger(la_4[7]), .smaller(sm_4[7]) );
comparator_4bit  Layer1_6 (.A(A[27:24]), .B(B[27:24]), .equal(eq_4[6]), .larger(la_4[6]), .smaller(sm_4[6]) );
comparator_4bit  Layer1_5 (.A(A[23:20]), .B(B[23:20]), .equal(eq_4[5]), .larger(la_4[5]), .smaller(sm_4[5]) );
comparator_4bit  Layer1_4 (.A(A[19:16]), .B(B[19:16]), .equal(eq_4[4]), .larger(la_4[4]), .smaller(sm_4[4]) );
comparator_4bit  Layer1_3 (.A(A[15:12]), .B(B[15:12]), .equal(eq_4[3]), .larger(la_4[3]), .smaller(sm_4[3]) );
comparator_4bit  Layer1_2 (.A(A[11:8]),  .B(B[11:8]),  .equal(eq_4[2]), .larger(la_4[2]), .smaller(sm_4[2]) );
comparator_4bit  Layer1_1 (.A(A[7:4]),   .B(B[7:4]),   .equal(eq_4[1]), .larger(la_4[1]), .smaller(sm_4[1]) );
comparator_4bit  Layer1_0 (.A(A[3:0]),   .B(B[3:0]),   .equal(eq_4[0]), .larger(la_4[0]), .smaller(sm_4[0]) );

// Compare each 4-bit groups with previous 4- segments 
wire logic [3:0] eq_8, la_8, sm_8;
assign eq_8[3] =   eq_4[7] &  eq_4[6];
assign la_8[3] =   la_4[7] | (eq_4[7] & la_4[6]);
assign sm_8[3] =   sm_4[7] | (eq_4[7] & sm_4[6]);

assign eq_8[2] =   eq_4[5] &  eq_4[4];
assign la_8[2] =   la_4[5] | (eq_4[5] & la_4[4]);
assign sm_8[2] =   sm_4[5] | (eq_4[5] & sm_4[4]);  

assign eq_8[1] =   eq_4[3] &  eq_4[2];
assign la_8[1] =   la_4[3] | (eq_4[3] & la_4[2]);
assign sm_8[1] =   sm_4[3] | (eq_4[3] & sm_4[2]);

assign eq_8[0] =   eq_4[1] &  eq_4[0];
assign la_8[0] =   la_4[1] | (eq_4[1] & la_4[0]);
assign sm_8[0] =   sm_4[1] | (eq_4[1] & sm_4[0]);

// Compare each 8- group
wire logic [1:0] eq_16, la_16, sm_16;
assign eq_16[1] =   eq_8[3] &   eq_8[2];
assign la_16[1] =   la_8[3] |  (eq_8[3] & la_8[2]);
assign sm_16[1] =   sm_8[3] |  (eq_8[3] & sm_8[2]);

assign eq_16[0] =   eq_8[1] &  eq_8[0];
assign la_16[0] =   la_8[1] | (eq_8[1] & la_8[0]);
assign sm_16[0] =   sm_8[1] |  (eq_8[1] & sm_8[0]);

// Compare each 16_ groups
wire logic eq_32, la_32, sm_32;
assign eq_32 =   eq_16[1] &  eq_16[0];
assign la_32 =   la_16[1] | (eq_16[1] & la_16[0]);
assign sm_32 =   sm_16[1] | (eq_16[1] & sm_16[0]);

// Conclusion
assign equal   = eq_32;
assign larger  = la_32 ^ sign_diff;  // Toggle la_32 if one of A, B are negative
assign smaller = sm_32 ^ sign_diff;
endmodule





