module encoder16_to_4(
    input  logic [15:0]  i_data,  // Input
    output logic [3:0]   o_data   // Encoded output
);

// i_data = 16'b0000_0000_0000_0001   =>    o_data = 4'b0000    // 0
// i_data = 16'b0000_0000_0000_0010   =>    o_data = 4'b0001    // 1
// i_data = 16'b0000_0000_0000_0100   =>    o_data = 4'b0010    // 2
// i_data = 16'b0000_0000_0000_1000   =>    o_data = 4'b0011    // 3
// i_data = 16'b0000_0000_0001_0000   =>    o_data = 4'b0100    // 4
// i_data = 16'b0000_0000_0010_0000   =>    o_data = 4'b0101    // 5
// i_data = 16'b0000_0000_0100_0000   =>    o_data = 4'b0110    // 6
// i_data = 16'b0000_0000_1000_0000   =>    o_data = 4'b0111    // 7
// i_data = 16'b0000_0001_0000_0000   =>    o_data = 4'b1000    // 8
// i_data = 16'b0000_0010_0000_0000   =>    o_data = 4'b1001    // 9
// i_data = 16'b0000_0100_0000_0000   =>    o_data = 4'b1010    // 10
// i_data = 16'b0000_1000_0000_0000   =>    o_data = 4'b1011    // 11
// i_data = 16'b0001_0000_0000_0000   =>    o_data = 4'b1100    // 12
// i_data = 16'b0010_0000_0000_0000   =>    o_data = 4'b1101    // 13
// i_data = 16'b0100_0000_0000_0000   =>    o_data = 4'b1110    // 14
// i_data = 16'b1000_0000_0000_0000   =>    o_data = 4'b1111    // 15

assign o_data[0] = i_data[1]  | i_data[3]  | i_data[5]  | i_data[7] |
                   i_data[9]  | i_data[11] | i_data[13] | i_data[15];

assign o_data[1] = i_data[2]  | i_data[3]  | i_data[6]  | i_data[7] |
                   i_data[10] | i_data[11] | i_data[14] | i_data[15];

assign o_data[2] = i_data[4]  | i_data[5]  | i_data[6]  | i_data[7] |
                   i_data[12] | i_data[13] | i_data[14] | i_data[15];

assign o_data[3] = i_data[8]  | i_data[9]  | i_data[10] | i_data[11] |
                   i_data[12] | i_data[13] | i_data[14] | i_data[15];


endmodule
