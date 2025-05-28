module imm_gen(
		input  logic [31:0] instr,
		output logic [31:0] imm
);

wire logic imm_sign;
wire logic [31:0] imm_UI, imm_JAL, imm_op, imm_br, imm_st, imm_shift;
assign imm_sign  = instr[31];
assign imm_UI    = {instr[31:12], 12'b0};                                          // LUI , AUIPC
assign imm_JAL   = {{12{imm_sign}}, instr[19:12], instr[20], instr[30:21], 1'b0};  // JAL
assign imm_op    = {{20{imm_sign}}, instr[31:20]};                                 // JALR, load and immediate arithmetic instrucitons
assign imm_br    = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};   // Brnach instructions
assign imm_st    = {{20{instr[31]}}, instr[31:25], instr[11:7]};                   // Store instructions
assign imm_shift = {27'b0, instr[24:20] };                                         // 5-bit immediate shift amount

///////////////// READING INSTRUCTIONS //////////////
wire logic [6:0] opcode;
wire logic ld_instr, st_instr, br_instr, op_imm_instr, shift_op, funct7_0, funct3_1_5;
wire logic LUI, AUIPC, JAL, JALR;

assign opcode = instr[6:0];

assign ld_instr	    = ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0000011
assign st_instr	    = ~opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0100011
assign br_instr     =  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 1100011
assign op_imm_instr = ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0010011

assign funct7_0     = ~instr[31] & ~instr[30] & ~instr[29] & ~instr[28] & ~instr[27] & ~instr[26] & ~instr[25]; 
assign funct3_1_5   = ~instr[13] &  instr[12];
assign shift_op     = op_imm_instr & funct7_0 & funct3_1_5;


//assign LUI        = ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0110111
//assign AUIPC      = ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0010011
assign JAL          =  opcode[6] &  opcode[5] & ~opcode[4] &  opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]; // 7'b 1101111
assign JALR         =  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]; // 7'b 1100111

// Output shift amount when op_imm_instr = 1 and funct3 = 001 , or funct3 = 101 



///////////////// IMMEDIATE GENREATING ///////////////
wire logic [2:0] sel_imm;

// sel_imm = 000 : imm_UI    (LUI, AUIPC)
// sel_imm = 001 : imm_JAL   (JAL)
// sel_imm = 010 : imm_op    (op_imm_instr, ld_instr, JALR)
// sel_imm = 011 : imm_br    (br_instr)
// sel_imm = 100 : imm_st    (st_instr)
// sel_imm = 101 : imm_shift (shift_op)
// sel_imm = 110 : shamt     (SLLI, SRLI, SRAI)
// sel_imm = 111 : 0

assign sel_imm[0] = (JAL) | (br_instr) | (shift_op);
assign sel_imm[1] = (op_imm_instr | ld_instr | JALR) | (br_instr);
assign sel_imm[2] = (st_instr) | (shift_op);

Mux_8X1_32bit   Imm_select  (.Sel(sel_imm), .OUT(imm),   .I5(32'b0),  .I6(32'b0),  .I0(imm_UI),
                             .I1(imm_JAL),  .I2(imm_op), .I3(imm_br), .I4(imm_st), .I7(imm_shift) );

endmodule
