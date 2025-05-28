import aqua_pkg::*;
module decoder(
    input  logic [31:0]  i_instr,
    input  logic [31:0]  i_pc,
    input  logic         i_instr2_indicator,     // To indicate if this decoder used for instr2
    input  logic         i_instr_vld,
    output decode_t      o_decode
);


logic        SYS_OP;
logic        L_TYPE;
logic        R_TYPE;
logic        I_TYPE;
logic        S_TYPE;
logic        B_TYPE;

// ================================ DECODING  INSTRUCTIONS ===========================
logic [31:0] instr;
logic [6:0]  opcode;
logic [7:0]  funct3;
logic [1:0]  funct7;       // Common value: funct7 = 0 and funct7= 32
logic [4:0]  rs1_addr;
logic [4:0]  rs2_addr;
logic [4:0]  rd_addr;
assign instr     = i_instr;
assign opcode    = instr[6:0];
assign rs1_addr  = instr[19:15];
assign rs2_addr  = instr[24:20];
assign rd_addr   = instr[11:7];

// ------------------------ COMMON funct3 AND funct7 VALUES ------------------------
// funct3 = instr[14:12];
assign funct3[0] = ~instr[14] & ~instr[13] & ~instr[12];  // funct3 = 3'b000
assign funct3[1] = ~instr[14] & ~instr[13] &  instr[12];  // funct3 = 3'b001
assign funct3[2] = ~instr[14] &  instr[13] & ~instr[12];  // funct3 = 3'b010
assign funct3[3] = ~instr[14] &  instr[13] &  instr[12];  // funct3 = 3'b011
assign funct3[4] =  instr[14] & ~instr[13] & ~instr[12];  // funct3 = 3'b100
assign funct3[5] =  instr[14] & ~instr[13] &  instr[12];  // funct3 = 3'b101
assign funct3[6] =  instr[14] &  instr[13] & ~instr[12];  // funct3 = 3'b110
assign funct3[7] =  instr[14] &  instr[13] &  instr[12];  // funct3 = 3'b111

// funct7 = instr[31:25];
assign funct7[0] = ~instr[31] & ~instr[30] & ~instr[29] & ~instr[28] &  // fucnt7 = 7'b000_0000
                   ~instr[27] & ~instr[26] & ~instr[25];

assign funct7[1] = ~instr[31] &  instr[30] & ~instr[29] & ~instr[28] &  // fucnt7 = 7'b010_0000
                   ~instr[27] & ~instr[26] & ~instr[25];


// ------------------------- GENERATING IMMEDIATE VALUES ----------------------------

logic [31:0]   imm_I_TYPE;     // Immediate value for I_TYPE instructions
logic [31:0]   imm_B_TYPE;     // Immediate value for B_TYPE instructions
logic [31:0]   imm_S_TYPE;     // Immediate value for S_TYPE and L_TYPE instructions
logic [31:0]   imm_AUIPC;      // Immediate value for AUIPC and LUI instructions
logic [31:0]   imm_SHIFT;      // Immedate shift amount (5-bit) for Shift Instructions
logic [31:0]   imm_JAL;        // Immediate value for JAL and JALR instructions

assign imm_SHIFT  = {27'b0, instr[24:20]};     // For shift immediate
assign imm_AUIPC  = {instr[31:12], 12'h0};     // Same for LUI
assign imm_I_TYPE = {{20{instr[31]}}, instr[31:20]};
assign imm_S_TYPE = {{20{instr[31]}}, instr[31:25], instr[11:7]};
assign imm_B_TYPE = {{19{instr[31]}}, instr[31], instr[7], instr[30:25],  instr[11:8],  1'b0};
assign imm_JAL    = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};


// --------------------------- DECODING TYPES OF INSTRUCTIONS ------------------------

assign L_TYPE   = ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] &     // 7'b000_0011
                  ~opcode[2] &  opcode[1] &  opcode[0];

assign S_TYPE   = ~opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] &     // 7'b010_0011
                  ~opcode[2] &  opcode[1] &  opcode[0];

assign B_TYPE   =  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] &     // 7'b110_0011
                  ~opcode[2] &  opcode[1] &  opcode[0];

assign I_TYPE   = ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] &     // 7'b001_0011
                  ~opcode[2] &  opcode[1] &  opcode[0];

assign R_TYPE   = ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &     // 7'b011_0011
                  ~opcode[2] &  opcode[1] &  opcode[0];

assign SYS_OP   =  opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &     // 7'b111_0011
                  ~opcode[2] &  opcode[1] &  opcode[0];

// IMPORTANT NOTE: Using AND gates is more efficent than a bunch of comparators



// ======================== THE INSTRUCTIONS INDICATION SIGNAL ============================
logic _ADD,   _SUB,  _XOR, _OR,  _AND,  _SLL, _SRL, _SRA, _SLTU, _SLT;
logic _BEQ,   _BNE,  _BLT, _BGE, _BLTU, _BGEU;
logic _LB,    _LH,   _LW,  _LBU, _LHU;
logic _JAL,   _JALR, _LUI, _AUIPC;
logic _SLLI,  _SRLI, _SRAI;
logic _SB,    _SH,   _SW;
logic _ECALL, _EBREAK;

assign _ADD    = (R_TYPE | I_TYPE) & funct3[0] & funct7[0];  // 0
assign _SUB    = (R_TYPE)          & funct3[0] & funct7[1];  // 1
assign _XOR    = (R_TYPE | I_TYPE) & funct3[4] & funct7[0];  // 2
assign _OR     = (R_TYPE | I_TYPE) & funct3[6] & funct7[0];  // 3
assign _AND    = (R_TYPE | I_TYPE) & funct3[7] & funct7[0];  // 4
assign _SRL    = (R_TYPE | I_TYPE) & funct3[5] & funct7[0];  // 5
assign _SRA    = (R_TYPE | I_TYPE) & funct3[5] & funct7[1];  // 6
assign _SLL    = (R_TYPE | I_TYPE) & funct3[1] & funct7[0];  // 7
assign _SLT    = (R_TYPE | I_TYPE) & funct3[2] & funct7[0];  // 8
assign _SLTU   = (R_TYPE | I_TYPE) & funct3[3] & funct7[0];  // 9
assign _BEQ    = B_TYPE & funct3[0];                         // 10
assign _BNE    = B_TYPE & funct3[1];                         // 11
assign _BLT    = B_TYPE & funct3[4];                         // 12
assign _BGE    = B_TYPE & funct3[5];                         // 13
assign _BLTU   = B_TYPE & funct3[6];                         // 14
assign _BGEU   = B_TYPE & funct3[7];                         // 15
assign _LB     = L_TYPE & funct3[0];                         // 16
assign _LH     = L_TYPE & funct3[1];                         // 17
assign _LW     = L_TYPE & funct3[2];                         // 18
assign _LBU    = L_TYPE & funct3[4];                         // 19
assign _LHU    = L_TYPE & funct3[5];                         // 20
assign _SB     = S_TYPE & funct3[0];                         // 21
assign _SH     = S_TYPE & funct3[1];                         // 22
assign _SW     = S_TYPE & funct3[2];                         // 23
// 24
assign _JAL   =  opcode[6] &  opcode[5] & ~opcode[4] &  opcode[3] &     // 7'b110_1111
                 opcode[2] &  opcode[1] &  opcode[0];
// 25
assign _JALR  =  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] &     // 7'b110_0111
                 opcode[2] &  opcode[1] &  opcode[0];



// Same instr_op_MUX index as ADD
assign _LUI   = ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &     // 7'b011_0111
                 opcode[2] &  opcode[1] &  opcode[0];

// Same instr_op_MUX index as ADD
assign _AUIPC = ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] &     // 7'b001_0111
                 opcode[2] &  opcode[1] &  opcode[0];

// Same instr_op_MUX index as SRL, SRA， SLL
assign _SLLI   = I_TYPE & funct3[1] & funct7[0];
assign _SRLI   = I_TYPE & funct3[5] & funct7[0];
assign _SRAI   = I_TYPE & funct3[5] & funct7[1];

// Reserved
assign _ECALL  = SYS_OP;
assign _EBREAK = SYS_OP & funct3[0] & (~instr[24]& ~instr[23]& ~instr[22]& ~instr[21]& instr[20]);


//========================== CONTROL SIGNALS ==========================
funct_e      funct;
logic [31:0] immediate;
logic [31:0] selected_PC;
logic [4:0]  instr_op_sel;      // Select signal for "instr_op"
logic [2:0]  instr_imm_sel;     // Select signal for "imm"
logic        ALU_funct;         // Indication signal for ALL     function
logic        LOAD_funct;        // Indication signal for LOAD    function
logic        STORE_funct;       // Indication signal for STORE   function
logic        CTRL_funct;        // Indication signal for CONTROL function
logic        use_imm;
logic        use_pc;
logic        prd_en;
logic        ebreak;
logic        ecall;
logic        wr_en;
logic        valid;

assign ALU_funct   = R_TYPE | I_TYPE | _LUI | _AUIPC;
assign LOAD_funct  = L_TYPE;
assign STORE_funct = S_TYPE;
assign CTRL_funct  = B_TYPE | _JAL   | _JALR;

assign instr_imm_sel[0] = (_AUIPC) | (_LUI) | (B_TYPE) | (I_TYPE | L_TYPE | _JALR);
assign instr_imm_sel[1] = (_JAL)   | (B_TYPE) | (S_TYPE);
assign instr_imm_sel[2] = (_JAL)   | (_AUIPC) | (_LUI) | (I_TYPE & (_SLLI | _SRLI | _SRAI));

assign instr_op_sel[0] = _SUB|_OR  |_SRL|_SLL|_SLTU|_BNE|_BGE |_BGEU|_LH |_LBU|_SB|_SW|_JALR | _AUIPC;
assign instr_op_sel[1] = _XOR|_OR  |_SRA|_SLL|_BEQ |_BNE|_BLTU|_BGEU|_LW |_LBU|_SH|_SW | _LUI | _AUIPC;
assign instr_op_sel[2] = _AND|_SRL |_SRA|_SLL|_BLT |_BGE|_BLTU|_BGEU|_LHU|_SB |_SH|_SW;
assign instr_op_sel[3] = _SLT|_SLTU|_BEQ|_BNE|_BLT |_BGE|_BLTU|_BGEU|_JAL| _JALR | _LUI | _AUIPC;
assign instr_op_sel[4] = _LB |_LH  |_LW |_LBU|_LHU |_SB |_SH  |_SW  |_JAL| _JALR | _LUI | _AUIPC;

// ------------------------- MULTIPLEXING CONTROL SIGNAL ---------------------------
always_comb begin : MUXs
    case({CTRL_funct, ALU_funct, STORE_funct, LOAD_funct})
        4'b0001:  begin   funct  = LOAD;
                          valid  = i_instr_vld;
                          prd_en = 1'b0;
                  end
        4'b0010:  begin   funct  = STORE;
                          valid  = i_instr_vld;
                          prd_en = 1'b0;

                  end
        4'b0100:  begin   funct  = ALU;
                          valid  = i_instr_vld;
                          prd_en = 1'b0;

                  end
        4'b1000:  begin   funct  = CTRL_TRNSF;
                          valid  = i_instr_vld;
                          prd_en = 1'b1;

                  end
        default:  begin   funct  = NONE;
                          valid  = 1'b0;
                          prd_en = 1'b0;

        end
    endcase

    case(instr_op_sel)
        5'b00000:    o_decode.instr_op = ADD ;
        5'b00001:    o_decode.instr_op = SUB ;
        5'b00010:    o_decode.instr_op = XOR ;
        5'b00011:    o_decode.instr_op = OR  ;
        5'b00100:    o_decode.instr_op = AND ;
        5'b00101:    o_decode.instr_op = SRL ;
        5'b00110:    o_decode.instr_op = SRA ;
        5'b00111:    o_decode.instr_op = SLL ;
        5'b01000:    o_decode.instr_op = SLT ;
        5'b01001:    o_decode.instr_op = SLTU;
        5'b01010:    o_decode.instr_op = BEQ ;
        5'b01011:    o_decode.instr_op = BNE ;
        5'b01100:    o_decode.instr_op = BLT ;
        5'b01101:    o_decode.instr_op = BGE ;
        5'b01110:    o_decode.instr_op = BLTU;
        5'b01111:    o_decode.instr_op = BGEU;
        5'b10000:    o_decode.instr_op = LB  ;
        5'b10001:    o_decode.instr_op = LH  ;
        5'b10010:    o_decode.instr_op = LW  ;
        5'b10011:    o_decode.instr_op = LBU ;
        5'b10100:    o_decode.instr_op = LHU ;
        5'b10101:    o_decode.instr_op = SB  ;
        5'b10110:    o_decode.instr_op = SH  ;
        5'b10111:    o_decode.instr_op = SW  ;
        5'b11000:    o_decode.instr_op = JAL ;
        5'b11001:    o_decode.instr_op = JALR ;
        5'b11010:    o_decode.instr_op = LUI ;
        5'b11011:    o_decode.instr_op = AUIPC ;
        default:     o_decode.instr_op = ADD ;
    endcase


    case(instr_imm_sel)
        3'b001:     immediate =  imm_I_TYPE; // 1
        3'b010:     immediate =  imm_S_TYPE; // 2
        3'b011:     immediate =  imm_B_TYPE; // 3
        3'b100:     immediate =  imm_SHIFT;  // 4
        3'b101:     immediate =  imm_AUIPC ; // 5
        3'b110:     immediate =  imm_JAL;    // 6
        default:    immediate =  32'b0;
    endcase
end

assign use_pc  = _AUIPC | _JAL | B_TYPE;
assign use_imm = _AUIPC | _JAL | _JALR | _LUI | L_TYPE | I_TYPE | S_TYPE | B_TYPE;
assign wr_en   = _AUIPC | _JAL | _JALR | _LUI | L_TYPE | I_TYPE | R_TYPE;
assign ecall   = _ECALL;
assign ebreak  = _EBREAK;


// Instruction 1: PC = input PC
// Instruction 2: PC = input PC + 4
mux #(.WIDTH(32), .NUM_INPUT(2)) mux_PC (
            .sel   (i_instr2_indicator   ),
            .i_mux ({ i_pc + 32'd4, i_pc}),
            .o_mux (selected_PC          )
);




// ========================== OUTPUT PACKAGE ASSIGNMENT =================
assign o_decode.funct    = funct;
assign o_decode.rs1_addr = rs1_addr;   // There is no default, ignore when not use
assign o_decode.rs2_addr = rs2_addr;   // There is no default, ignore when not use
assign o_decode.rd_addr  = rd_addr;    // There is no default, ignore when not use
assign o_decode.use_imm  = use_imm;
assign o_decode.use_pc   = use_pc;
assign o_decode.imm      = immediate;
assign o_decode.pc       = selected_PC;
assign o_decode.wr_en    = wr_en;
assign o_decode.valid    = valid;
assign o_decode.prd_en   = prd_en;
assign o_decode.ebreak   = ebreak;
assign o_decode.ecall    = ecall;


// Remove this when done debugging
debug_t debug_package;
assign o_decode.debug_data = debug_package;


















































// ================== Debug signals ============
logic _DEBUG_LUI;
logic _DEBUG_AUIPC;
logic _DEBUG_JAL;
logic _DEBUG_JALR;
logic _DEBUG_BEQ;
logic _DEBUG_BNE;
logic _DEBUG_BLT;
logic _DEBUG_BGE;
logic _DEBUG_BLTU;
logic _DEBUG_BGEU;
logic _DEBUG_LB;
logic _DEBUG_LH;
logic _DEBUG_LW;
logic _DEBUG_LBU;
logic _DEBUG_LHU;
logic _DEBUG_SB;
logic _DEBUG_SH;
logic _DEBUG_SW;
logic _DEBUG_ADDI;
logic _DEBUG_SLTI;
logic _DEBUG_SLTIU;
logic _DEBUG_XORI;
logic _DEBUG_ORI;
logic _DEBUG_ANDI;
logic _DEBUG_SLLI;
logic _DEBUG_SRLI;
logic _DEBUG_SRAI;
logic _DEBUG_ADD;
logic _DEBUG_SUB;
logic _DEBUG_SLL;
logic _DEBUG_SLT;
logic _DEBUG_SLTU;
logic _DEBUG_SRL;
logic _DEBUG_SRA;
logic _DEBUG_XOR;
logic _DEBUG_OR;
logic _DEBUG_AND;
logic _DEBUG_ECALL;
logic _DEBUG_EBREAK;


assign _DEBUG_LUI    = _LUI;                            // 0
assign _DEBUG_AUIPC  = _AUIPC;                          // 1 
assign _DEBUG_JAL    = _JAL;                            // 2
assign _DEBUG_JALR   = _JALR;                           // 3 
assign _DEBUG_BEQ    = B_TYPE & funct3[0];              // 4
assign _DEBUG_BNE    = B_TYPE & funct3[1];              // 5
assign _DEBUG_BLT    = B_TYPE & funct3[4];              // 6
assign _DEBUG_BGE    = B_TYPE & funct3[5];              // 7
assign _DEBUG_BLTU   = B_TYPE & funct3[6];              // 8
assign _DEBUG_BGEU   = B_TYPE & funct3[7];              // 9
assign _DEBUG_LB     = L_TYPE & funct3[0];              // 10
assign _DEBUG_LH     = L_TYPE & funct3[1];              // 11
assign _DEBUG_LW     = L_TYPE & funct3[2];              // 12
assign _DEBUG_LBU    = L_TYPE & funct3[4];              // 13
assign _DEBUG_LHU    = L_TYPE & funct3[5];              // 14
assign _DEBUG_SB     = S_TYPE & funct3[0];              // 15
assign _DEBUG_SH     = S_TYPE & funct3[1];              // 16
assign _DEBUG_SW     = S_TYPE & funct3[2];              // 17
assign _DEBUG_ADDI   = I_TYPE & funct3[0] & funct7[0];  // 18
assign _DEBUG_SLTI   = I_TYPE & funct3[2] & funct7[0];  // 19
assign _DEBUG_SLTIU  = I_TYPE & funct3[3] & funct7[0];  // 20
assign _DEBUG_XORI   = I_TYPE & funct3[4] & funct7[0];  // 21
assign _DEBUG_ORI    = I_TYPE & funct3[6] & funct7[0];  // 22
assign _DEBUG_ANDI   = I_TYPE & funct3[7] & funct7[0];  // 23
assign _DEBUG_SLLI   = I_TYPE & funct3[1] & funct7[0];  // 24
assign _DEBUG_SRLI   = I_TYPE & funct3[5] & funct7[0];  // 25
assign _DEBUG_SRAI   = I_TYPE & funct3[5] & funct7[1];  // 26
assign _DEBUG_ADD    = R_TYPE & funct3[0] & funct7[0];  // 27
assign _DEBUG_SUB    = R_TYPE & funct3[0] & funct7[1];  // 28
assign _DEBUG_SLL    = R_TYPE & funct3[1] & funct7[0];  // 29
assign _DEBUG_SLT    = R_TYPE & funct3[2] & funct7[0];  // 30
assign _DEBUG_SLTU   = R_TYPE & funct3[3] & funct7[0];  // 31
assign _DEBUG_SRL    = R_TYPE & funct3[5] & funct7[0];  // 32
assign _DEBUG_SRA    = R_TYPE & funct3[5] & funct7[1];  // 33
assign _DEBUG_XOR    = R_TYPE & funct3[4] & funct7[0];  // 34
assign _DEBUG_OR     = R_TYPE & funct3[6] & funct7[0];  // 35
assign _DEBUG_AND    = R_TYPE & funct3[7] & funct7[0];  // 36
assign _DEBUG_ECALL  = _ECALL;                          // 37
assign _DEBUG_EBREAK = _EBREAK;                         // 38



always_comb begin
        if      (_DEBUG_LUI    == 1'b1)   debug_package.db_instr = LUI_; 
        else if (_DEBUG_AUIPC  == 1'b1)   debug_package.db_instr = AUIPC_; 
        else if (_DEBUG_JAL    == 1'b1)   debug_package.db_instr = JAL_; 
        else if (_DEBUG_JALR   == 1'b1)   debug_package.db_instr = JALR_; 
        else if (_DEBUG_BEQ    == 1'b1)   debug_package.db_instr = BEQ_; 
        else if (_DEBUG_BNE    == 1'b1)   debug_package.db_instr = BNE_; 
        else if (_DEBUG_BLT    == 1'b1)   debug_package.db_instr = BLT_; 
        else if (_DEBUG_BGE    == 1'b1)   debug_package.db_instr = BGE_; 
        else if (_DEBUG_BLTU   == 1'b1)   debug_package.db_instr = BLTU_; 
        else if (_DEBUG_BGEU   == 1'b1)   debug_package.db_instr = BGEU_; 
        else if (_DEBUG_LB     == 1'b1)   debug_package.db_instr = LB_; 
        else if (_DEBUG_LH     == 1'b1)   debug_package.db_instr = LH_; 
        else if (_DEBUG_LW     == 1'b1)   debug_package.db_instr = LW_; 
        else if (_DEBUG_LBU    == 1'b1)   debug_package.db_instr = LBU_; 
        else if (_DEBUG_LHU    == 1'b1)   debug_package.db_instr = LHU_; 
        else if (_DEBUG_SB     == 1'b1)   debug_package.db_instr = SB_; 
        else if (_DEBUG_SH     == 1'b1)   debug_package.db_instr = SH_; 
        else if (_DEBUG_SW     == 1'b1)   debug_package.db_instr = SW_; 
        else if (_DEBUG_ADDI   == 1'b1)   debug_package.db_instr = ADDI_; 
        else if (_DEBUG_SLTI   == 1'b1)   debug_package.db_instr = SLTI_; 
        else if (_DEBUG_SLTIU  == 1'b1)   debug_package.db_instr = SLTIU_; 
        else if (_DEBUG_XORI   == 1'b1)   debug_package.db_instr = XORI_; 
        else if (_DEBUG_ORI    == 1'b1)   debug_package.db_instr = ORI_; 
        else if (_DEBUG_ANDI   == 1'b1)   debug_package.db_instr = ANDI_; 
        else if (_DEBUG_SLLI   == 1'b1)   debug_package.db_instr = SLLI_; 
        else if (_DEBUG_SRLI   == 1'b1)   debug_package.db_instr = SRLI_; 
        else if (_DEBUG_SRAI   == 1'b1)   debug_package.db_instr = SRAI_; 
        else if (_DEBUG_ADD    == 1'b1)   debug_package.db_instr = ADD_; 
        else if (_DEBUG_SUB    == 1'b1)   debug_package.db_instr = SUB_; 
        else if (_DEBUG_SLL    == 1'b1)   debug_package.db_instr = SLL_; 
        else if (_DEBUG_SLT    == 1'b1)   debug_package.db_instr = SLT_; 
        else if (_DEBUG_SLTU   == 1'b1)   debug_package.db_instr = SLTU_; 
        else if (_DEBUG_SRL    == 1'b1)   debug_package.db_instr = SRL_; 
        else if (_DEBUG_SRA    == 1'b1)   debug_package.db_instr = SRA_; 
        else if (_DEBUG_XOR    == 1'b1)   debug_package.db_instr = XOR_; 
        else if (_DEBUG_OR     == 1'b1)   debug_package.db_instr = OR_; 
        else if (_DEBUG_AND    == 1'b1)   debug_package.db_instr = AND_; 
        else if (_DEBUG_ECALL  == 1'b1)   debug_package.db_instr = ECALL_; 
        else if (_DEBUG_EBREAK == 1'b1)   debug_package.db_instr = EBREAK_; 
        else                              debug_package.db_instr = NO_INSTRUCTION;
end


assign debug_package.db_rs1_addr   = register_idx'(rs1_addr);
assign debug_package.db_rs2_addr   = register_idx'(rs2_addr);
assign debug_package.db_rd_addr    = register_idx'(rd_addr);
assign debug_package.db_rs1_data   = 32'b0;     
assign debug_package.db_rs2_data   = 32'b0;
assign debug_package.db_rd_data    = 32'b0;
assign debug_package.db_imm        = immediate;
assign debug_package.db_pc         = selected_PC;
assign debug_package.db_instr_asm  = instr;
assign debug_package.db_wr_en      = wr_en;
assign debug_package.db_valid      = valid;
assign debug_package.db_is_instr2  = 1'b0;
assign debug_package.db_prd_en     = prd_en;


debug_instr     decode_db_instr     = debug_package.db_instr;
register_idx    decode_db_rs1_addr  = debug_package.db_rs1_addr;
register_idx    decode_db_rs2_addr  = debug_package.db_rs2_addr;
register_idx    decode_db_rd_addr   = debug_package.db_rd_addr;
logic [31:0]    decode_db_rs1_data  = debug_package.db_rs1_data;
logic [31:0]    decode_db_rs2_data  = debug_package.db_rs2_data;
logic [31:0]    decode_db_rd_data   = debug_package.db_rd_data;
logic [31:0]    decode_db_imm       = debug_package.db_imm;
logic [31:0]    decode_db_pc        = debug_package.db_pc;
logic [31:0]    decode_db_instr_asm = debug_package.db_instr_asm;
logic           decode_db_wr_en     = debug_package.db_wr_en;
logic           decode_db_valid     = debug_package.db_valid;
logic           decode_db_prd_en    = debug_package.db_prd_en;
logic           decode_db_is_instr2 = debug_package.db_is_instr2;


endmodule





