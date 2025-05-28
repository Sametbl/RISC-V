module ctrl_unit(
	input  logic [31:0] instr,
	output logic rd_wren, mem_wren, br_unsigned,
	output logic BEQ, BNE, JAL, JALR, BLT_U, BGE_U, zero_op_a, // for LUI instruction
	output logic mem_byte, mem_halfword, MemRead, branch,
	output logic op_a_PC, op_b_imm, NONE_RS1, NONE_RS2, NONE_RD,
	output logic [3:0] alu_op,
	output logic [1:0] wb_sel 
);
// Havent build instructions: PAUSE, FENCE TSO 

/////////////////// READING INSTRUCTIONS //////////////////  
wire logic [6:0] opcode, funct7;
wire logic [2:0] funct3;	
wire logic ld_instr, st_instr, br_instr, op_imm_instr, op_instr;
wire logic LUI, AUIPC;

assign opcode = instr[6:0];
assign funct3 = instr[14:12]; // ignore when not use
assign funct7 = instr[31:25]; // ignore when not use

assign ld_instr     = ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0000011
assign st_instr     = ~opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0100011
assign br_instr     =  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 1100011
assign op_imm_instr = ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0010011
assign op_instr     = ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0110011
//assign sys_instr  =  opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 1110011

assign LUI      = ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0110111
assign AUIPC    = ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0010111
assign JAL      =  opcode[6] &  opcode[5] & ~opcode[4] &  opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]; // 7'b 1101111
assign JALR     =  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]; // 7'b 1100111
//assign FENCE  = ~opcode[6] & ~opcode[5] & ~opcode[4] &  opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0001111 


////////////////// COMMON funct3 AND funct7 VALUES //////////////////
wire logic funct3_0, funct3_1, funct3_2, funct3_3, funct3_4, funct3_5, funct3_6, funct3_7;
wire logic funct7_0, funct7_32;
 
assign funct3_0 = ~funct3[2] & ~funct3[1] & ~funct3[0];  // funct3 = 3'b000
assign funct3_1 = ~funct3[2] & ~funct3[1] &  funct3[0];  // funct3 = 3'b001
assign funct3_2 = ~funct3[2] &  funct3[1] & ~funct3[0];  // funct3 = 3'b010
assign funct3_3 = ~funct3[2] &  funct3[1] &  funct3[0];  // funct3 = 3'b011
assign funct3_4 =  funct3[2] & ~funct3[1] & ~funct3[0];  // funct3 = 3'b100
assign funct3_5 =  funct3[2] & ~funct3[1] &  funct3[0];  // funct3 = 3'b101
assign funct3_6 =  funct3[2] &  funct3[1] & ~funct3[0];  // funct3 = 3'b110
assign funct3_7 =  funct3[2] &  funct3[1] &  funct3[0];  // funct3 = 3'b111

assign funct7_0  = ~funct7[6] & ~funct7[5] & ~funct7[4] & ~funct7[3] & ~funct7[2] & ~funct7[1] & ~funct7[0];  // funct7 = 7'b0000000
assign funct7_32 = ~funct7[6] &  funct7[5] & ~funct7[4] & ~funct7[3] & ~funct7[2] & ~funct7[1] & ~funct7[0];  // funct7 = 7'b0100000


////////////////// THE INSTRUCTIONS SIGNAL //////////////////
// OP-IMM instructions
wire logic ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI;

//assign ADDI  = op_imm_instr & funct3_0;                 // Opcode = 0010011 & funct3 = 000
assign SLTI  = op_imm_instr & funct3_2;                 // Opcode = 0010011 & funct3 = 010
assign SLTIU = op_imm_instr & funct3_3;                 // Opcode = 0010011 & funct3 = 011
assign XORI  = op_imm_instr & funct3_4;                 // Opcode = 0010011 & funct3 = 100
assign ORI   = op_imm_instr & funct3_6;	                // Opcode = 0010011 & funct3 = 110
assign ANDI  = op_imm_instr & funct3_7;	                // Opcode = 0010011 & funct3 = 111
assign SLLI  = op_imm_instr & funct3_1 & funct7_0;      // Opcode = 0010011 & funct3 = 001 & funct7 = 0000000
assign SRLI  = op_imm_instr & funct3_5 & funct7_0;      // Opcode = 0010011 & funct3 = 101 & funct7 = 0000000
assign SRAI  = op_imm_instr & funct3_5 & funct7_32;     // Opcode = 0010011 & funct3 = 101 & funct7 = 0100000

// OP instructions
wire logic ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND;

//assign ADD  = op_instr & funct3_0 & funct7_0;   // Opcode = 0110011 & funct3 = 000 & funct7 = 0000000
assign SUB  = op_instr & funct3_0 & funct7_32; 	// Opcode = 0110011 & funct3 = 000 & funct7 = 0100000
assign SLL  = op_instr & funct3_1 & funct7_0; 	// Opcode = 0110011 & funct3 = 001 & funct7 = 0000000
assign SLT  = op_instr & funct3_2 & funct7_0; 	// Opcode = 0110011 & funct3 = 002 & funct7 = 0000000
assign SLTU = op_instr & funct3_3 & funct7_0;	// Opcode = 0110011 & funct3 = 003 & funct7 = 0000000
assign XOR  = op_instr & funct3_4 & funct7_0;	// Opcode = 0110011 & funct3 = 004 & funct7 = 0000000
assign SRL  = op_instr & funct3_5 & funct7_0; 	// Opcode = 0110011 & funct3 = 005 & funct7 = 0000000
assign SRA  = op_instr & funct3_5 & funct7_32;	// Opcode = 0110011 & funct3 = 005 & funct7 = 0100000
assign OR   = op_instr & funct3_6 & funct7_0;	// Opcode = 0110011 & funct3 = 006 & funct7 = 0000000
assign AND  = op_instr & funct3_7 & funct7_0; 	// Opcode = 0110011 & funct3 = 007 & funct7 = 0000000

// SYSTEM instruction (for future extension)
//wire logic ECALL, EBREAK;
//assign ECALL  = sys_instr; 		// Opcode = 1110011
//assign EBREAK = sys_instr & funct3_0 & (~instr[24] & ~instr[23] & ~instr[22] & ~instr[21] & instr[20]);	// Opcode = 1110011 = 0000 & instr[24:20] = 00001

// LOAD instrucitons
wire logic LB, LH, LBU, LHU;
assign LB  = ld_instr & funct3_0; 	// Opcode = 0000011 & funct3 = 000
assign LH  = ld_instr & funct3_1; 	// Opcode = 0000011 & funct3 = 001
//assign LW  = ld_instr & funct3_2; 	// Opcode = 0000011 & funct3 = 010
assign LBU = ld_instr & funct3_4; 	// Opcode = 0000011 & funct3 = 100
assign LHU = ld_instr & funct3_5;	// Opcode = 0000011 & funct3 = 101

// STORE instructions
wire logic SB, SH;
assign SB  = st_instr & funct3_0; 	// Opcode = 0100011 & funct3 = 000
assign SH  = st_instr & funct3_1; 	// Opcode = 0100011 & funct3 = 001

// BRANCH instructions
wire logic BLT, BGE, BLTU, BGEU;
assign BEQ  = br_instr & funct3_0; 	//Opcode = 1100011 & funct3 = 000
assign BNE  = br_instr & funct3_1; 	//Opcode = 1100011 & funct3 = 001
assign BLT  = br_instr & funct3_4; 	//Opcode = 1100011 & funct3 = 100
assign BGE  = br_instr & funct3_5; 	//Opcode = 1100011 & funct3 = 101
assign BLTU = br_instr & funct3_6; 	//Opcode = 1100011 & funct3 = 110
assign BGEU = br_instr & funct3_7; 	//Opcode = 1100011 & funct3 = 111

assign BLT_U = BLT | BLTU;
assign BGE_U = BGE | BGEU;

/////////////// CONTROL SIGNAL FOR PROCESSOR ///////////////

// Write data to Regfile
assign MemRead  = ld_instr;
assign mem_wren = st_instr;		// all the STORE instructions
assign rd_wren  = ld_instr | op_instr | op_imm_instr | JAL | JALR | LUI | AUIPC; // all the load, arithmetic instructions

			
assign op_a_PC   = JAL | AUIPC | br_instr; 
assign op_b_imm  = JAL | JALR  | AUIPC | LUI | op_imm_instr | ld_instr | br_instr | st_instr; // all the immedate arithmetic and load instructions
assign zero_op_a = LUI;

assign br_unsigned = BLTU | BGEU;
assign NONE_RS2 = JAL | JALR | AUIPC | LUI | ld_instr | op_imm_instr;
assign NONE_RS1 = LUI | JAL  | JALR;
assign NONE_RD  = br_instr | st_instr;

// default: wb_sel = 2'b00:   ALU			  
assign wb_sel[0] = ld_instr;
assign wb_sel[1] = JAL | JALR;

assign mem_byte      = LB | LBU | SB; 
assign mem_halfword  = LH | LHU | SH;

assign branch = br_instr | JAL | JALR;
// alu_op = 0000: ADD, 
// alu_op = 0001: SUB
// alu_op = 0010: SLT
// alu_op = 0011: STLU
// alu_op = 0100: XOR
// alu_op = 0101: OR
// alu_op = 0110: AND
// alu_op = 0111: SLL
// alu_op = 1000: SRL
// alu_op = 1001: SRA
// alu_op > 1001: Reserved

assign alu_op[0] = (SUB)      | (SLTU|SLTIU) | (OR|ORI)   | (SLL|SLLI) | (SRA|SRAI);
assign alu_op[1] = (SLT|SLTI) | (SLTU|SLTIU) | (AND|ANDI) | (SLL|SLLI); 
assign alu_op[2] = (XOR|XORI) | (OR|ORI)     | (AND|ANDI) | (SLL|SLLI);
assign alu_op[3] = (SRL|SRLI) | (SRA|SRAI);

endmodule




















