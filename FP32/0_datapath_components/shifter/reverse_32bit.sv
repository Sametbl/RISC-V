module reverse_32bit(
		input  logic [31:0] orig,
		output logic [31:0] rev
);

assign rev[31] = orig[0];
assign rev[30] = orig[1];
assign rev[29] = orig[2];
assign rev[28] = orig[3];
assign rev[27] = orig[4];
assign rev[26] = orig[5];
assign rev[25] = orig[6];
assign rev[24] = orig[7];
assign rev[23] = orig[8];
assign rev[22] = orig[9];
assign rev[21] = orig[10];
assign rev[20] = orig[11];
assign rev[19] = orig[12];
assign rev[18] = orig[13];
assign rev[17] = orig[14];
assign rev[16] = orig[15];
assign rev[15] = orig[16];
assign rev[14] = orig[17];
assign rev[13] = orig[18];
assign rev[12] = orig[19];
assign rev[11] = orig[20];
assign rev[10] = orig[21];
assign rev[9]  = orig[22];
assign rev[8]  = orig[23];
assign rev[7]  = orig[24];
assign rev[6]  = orig[25];
assign rev[5]  = orig[26];
assign rev[4]  = orig[27];
assign rev[3]  = orig[28];
assign rev[2]  = orig[29];
assign rev[1]  = orig[30];
assign rev[0]  = orig[31];
endmodule


