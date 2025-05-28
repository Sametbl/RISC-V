module demux_1X16(
	input  logic D,
	input  logic [3:0] sel,
	output logic [15:0] S
);

assign  S[0]  = (D) & (~sel[3] & ~sel[2] & ~sel[1] & ~sel[0]);
assign  S[1]  = (D) & (~sel[3] & ~sel[2] & ~sel[1] &  sel[0]);
assign  S[2]  = (D) & (~sel[3] & ~sel[2] &  sel[1] & ~sel[0]);
assign  S[3]  = (D) & (~sel[3] & ~sel[2] &  sel[1] &  sel[0]);
assign  S[4]  = (D) & (~sel[3] &  sel[2] & ~sel[1] & ~sel[0]);
assign  S[5]  = (D) & (~sel[3] &  sel[2] & ~sel[1] &  sel[0]);
assign  S[6]  = (D) & (~sel[3] &  sel[2] &  sel[1] & ~sel[0]);
assign  S[7]  = (D) & (~sel[3] &  sel[2] &  sel[1] &  sel[0]);
assign  S[8]  = (D) & ( sel[3] & ~sel[2] & ~sel[1] & ~sel[0]);
assign  S[9]  = (D) & ( sel[3] & ~sel[2] & ~sel[1] &  sel[0]);
assign  S[10] = (D) & ( sel[3] & ~sel[2] &  sel[1] & ~sel[0]);
assign  S[11] = (D) & ( sel[3] & ~sel[2] &  sel[1] &  sel[0]);
assign  S[12] = (D) & ( sel[3] &  sel[2] & ~sel[1] & ~sel[0]);
assign  S[13] = (D) & ( sel[3] &  sel[2] & ~sel[1] &  sel[0]);
assign  S[14] = (D) & ( sel[3] &  sel[2] &  sel[1] & ~sel[0]);
assign  S[15] = (D) & ( sel[3] &  sel[2] &  sel[1] &  sel[0]);
endmodule

