module encoder8_to_3(
    input  logic [7:0]   i_data,  // Input
    output logic [2:0]   o_data   // Encoded output
);

// i_data = 8'b0000_0001   =>    o_data = 3'b000
// i_data = 8'b0000_0010   =>    o_data = 3'b001
// i_data = 8'b0000_0100   =>    o_data = 3'b010
// i_data = 8'b0000_1000   =>    o_data = 3'b011
// i_data = 8'b0001_0000   =>    o_data = 3'b100
// i_data = 8'b0010_0000   =>    o_data = 3'b101
// i_data = 8'b0100_0000   =>    o_data = 3'b110
// i_data = 8'b1000_0000   =>    o_data = 3'b111

assign o_data[0] = i_data[1] | i_data[3] | i_data[5] | i_data[7];
assign o_data[1] = i_data[2] | i_data[3] | i_data[6] | i_data[7];
assign o_data[2] = i_data[4] | i_data[5] | i_data[6] | i_data[7];


endmodule
