module encoder32_to_5(
    input  logic [31:0]   i_data,  // Input
    output logic [4:0]    o_data   // Encoded output
);

assign o_data[0] = i_data[1]  | i_data[3]  | i_data[5]  | i_data[7]  |
                   i_data[9]  | i_data[11] | i_data[13] | i_data[15] |
                   i_data[17] | i_data[19] | i_data[21] | i_data[23] |
                   i_data[25] | i_data[27] | i_data[29] | i_data[31];

assign o_data[1] = i_data[2]  | i_data[3]  | i_data[6]  | i_data[7]  |
                   i_data[10] | i_data[11] | i_data[14] | i_data[15] |
                   i_data[18] | i_data[19] | i_data[22] | i_data[23] |
                   i_data[26] | i_data[27] | i_data[30] | i_data[31];

assign o_data[2] = i_data[4]  | i_data[5]  | i_data[6]  | i_data[7]  |
                   i_data[12] | i_data[13] | i_data[14] | i_data[15] |
                   i_data[20] | i_data[21] | i_data[22] | i_data[23] |
                   i_data[28] | i_data[29] | i_data[30] | i_data[31];


assign o_data[3] = i_data[8]  | i_data[9]  | i_data[10] | i_data[11] |
                   i_data[12] | i_data[13] | i_data[14] | i_data[15] |
                   i_data[24] | i_data[25] | i_data[26] | i_data[27] |
                   i_data[28] | i_data[29] | i_data[30] | i_data[31];

assign o_data[4] = i_data[16] | i_data[17] | i_data[18] | i_data[19] |
                   i_data[20] | i_data[21] | i_data[22] | i_data[23] |
                   i_data[24] | i_data[25] | i_data[26] | i_data[27] |
                   i_data[28] | i_data[29] | i_data[30] | i_data[31];


endmodule
