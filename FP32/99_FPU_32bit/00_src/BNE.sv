// Boundary Nibble Encoder (BNE) 

module BNE(
    input  logic [7:0] a,
    output logic [2:0] y,
    output logic Q
);

// All_zero: When all four-bit local counter modules are zeros
assign Q    = a[7] & a[6] & a[5] & a[4] & a[3] & a[2] & a[1] & a[0];


assign y[2] = a[7] & a[6] & a[5] & a[4]; // NLZ > 15: When first 16 MSB are zero 

// Below are optimized boolean expression
assign y[1] = a[7] & a[6] & (~a[5] | ~a[4] | (a[3]&a[2]) );
assign y[0] = (a[7] & (~a[6] | (a[5]&~a[4]))) | (a[7] & a[5] & a[3] & (~a[2] | a[1]));

endmodule