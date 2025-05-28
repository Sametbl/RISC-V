// The NLC counts the number of zero of the 4 bit number: Zero[1:0] (From 0 to 3)
// If all bits are zero (4 zeros) then singal "all_zero" will represent this case.

module NLC_4bit (
    input  logic [3:0] X,
    output logic [1:0] Zero,
    output logic all_zero
);
wire logic A, B , C , D;
assign A = X[3];
assign B = X[2];
assign C = X[1];
assign D = X[0];

assign all_zero = ~(A | B | C | D);
assign Zero[1]  = ~(A | B);           // High when two first MSB is LOW
assign Zero[0]  = ~( (~B & C) | A );  // High when {ABC} = 3'b01X , or {ABC} = 3'b000


endmodule