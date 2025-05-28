package aqua_pkg;
//---------------- Fetch ----------------------
typedef struct packed {
        logic        update_en;
        logic [31:0] pc_lookup;
        logic [31:0] target;
        logic        taken;
        logic        valid;
} branch_t ;


typedef enum bit [1:0] {
        NN = 2'b00,
        NT = 2'b01,
        TN = 2'b10,
        TT = 2'b11
} predictor_t ;

//---------------- Decode ---------------------
typedef enum logic [2:0] {
        NONE,              //0
        LOAD,              //1
        STORE,             //2
        ALU,               //3
        CTRL_TRNSF         //4
} funct_e;

typedef enum logic [4:0] {
        ADD,   // 0
        SUB,   // 1
        XOR,   // 2
        OR,    // 3
        AND,   // 4
        SRL,   // 5
        SRA,   // 6
        SLL,   // 7
        SLT,   // 8
        SLTU,  // 9
        BEQ,   // 10
        BNE,   // 11
        BLT,   // 12
        BGE,   // 13
        BLTU,  // 14
        BGEU,  // 15
        LB,    // 16
        LH,    // 17
        LW,    // 18
        LBU,   // 19
        LHU,   // 20
        SB,    // 21
        SH,    // 22
        SW,    // 23
        JAL,   // 24
        JALR,  // 25
        LUI,   // 26
        AUIPC  // 27
} operator_e;





typedef struct packed {
        funct_e           funct   ;
        operator_e        instr_op;
        logic      [4:0]  rs1_addr;
        logic      [4:0]  rs2_addr;
        logic      [4:0]  rd_addr ;
        logic      [31:0] imm     ;
        logic      [31:0] pc      ;
        logic             use_imm ;
        logic             use_pc  ;
        logic             prd_en  ;  // Enable updating Brnach Prediction BTB
        logic             ecall   ;
        logic             ebreak  ;
        logic             wr_en   ;
        logic             valid   ;
        debug_t           debug_data;    // Please remove this when done debugging
} decode_t ;

//---------------- Regfile --------------------
// Regfile doesn't need valid bit
typedef struct packed {
        logic [4:0] rs1_addr_instr1;
        logic [4:0] rs2_addr_instr1;
        logic [4:0] rs1_addr_instr2;
        logic [4:0] rs2_addr_instr2;
} rs_addr_t ;

typedef struct packed {
        logic [31:0] rs1_data_instr1;
        logic [31:0] rs2_data_instr1;
        logic [31:0] rs1_data_instr2;
        logic [31:0] rs2_data_instr2;
} rs_data_t ;


typedef struct packed {
        logic [4:0]  rd_addr_instr1;
        logic [4:0]  rd_addr_instr2;
        logic [31:0] rd_data_instr1;
        logic [31:0] rd_data_instr2;
        logic        wren_instr1;
        logic        wren_instr2;
} writeback_t ;




//---------------- Forwarding -----------------
typedef struct packed {
        logic         is_instr2;
        logic [4:0]   rd_buff;
        logic [31:0]  data_buff;
        logic         valid;
        logic         wr_en;
} uv_buff_t ;

typedef struct packed {
        logic [3:0]   fwd_rs1_instr1;    // Size of each signal = Number of forwaring Locations
        logic [3:0]   fwd_rs2_instr1;
        logic [3:0]   fwd_rs1_instr2;
        logic [3:0]   fwd_rs2_instr2;
        logic [31:0]  alu1_fwd_dat;
        logic [31:0]  alu2_fwd_dat;
        logic [31:0]  alu3_fwd_dat;
        logic [31:0]  bru1_fwd_dat;
        logic [31:0]  bru2_fwd_dat;
        logic [31:0]  bru3_fwd_dat;
        logic [31:0]  mem1_fwd_dat;
        logic [31:0]  mem2_fwd_dat;
} forwarding_t ;



//------------------ U & V-pipe -------------------------
typedef struct packed {
        logic         is_instr2;
        operator_e    instr_op;
        logic [31:0]  operand_a;
        logic [31:0]  operand_b;
        logic [4:0]   rd_addr;
        logic         wr_en;       // Enable forwarding (avoid operand == imm or PC)
        logic         valid;
} alu_issue_t;

typedef struct packed {
        logic         is_instr2;
        operator_e    instr_op;
        logic [31:0]  pc;
        logic [31:0]  operand_a;
        logic [31:0]  operand_b;
        logic [31:0]  rs1_data;
        logic [31:0]  rs2_data;
        logic [4:0]   rd_addr;
        logic         wr_en;       // Enable forwarding (avoid operand == imm or PC)
        logic         prd_en;
        logic         valid;
} bru_issue_t;

typedef struct packed {
        logic         is_instr2;
        operator_e    instr_op;
        logic [31:0]  operand_a;
        logic [31:0]  operand_b;
        logic [31:0]  data;
        logic [4:0]   rd_addr;
        logic         wr_en;       // Enable forwarding (avoid operand == imm or PC)
        logic         valid;
} agu_issue_t ;


typedef struct packed {
        logic         is_instr2;
        operator_e    instr;
        logic [31:0]  target_addr;
        logic [31:0]  data;
        logic [4:0]   rd_addr;
        logic         wr_en;
        logic         valid;
} mem_req_t;

typedef struct packed {
        logic [31:0]    addr;
        logic [31:0]    wdata;
        logic [31:0]    rdata;
        logic [3:0]     bytemask;
        logic           wren;
        logic           valid;
} mem_ack_t ;




// ================= Debug package ==============
typedef enum logic [5:0] {
        NO_INSTRUCTION  = 6'd0,
        LUI_     =  6'd1,
        AUIPC_   =  6'd2,
        JAL_     =  6'd3,
        JALR_    =  6'd4,
        BEQ_     =  6'd5,
        BNE_     =  6'd6,
        BLT_     =  6'd7,
        BGE_     =  6'd8,
        BLTU_    =  6'd9,
        BGEU_    =  6'd10,
        LB_      =  6'd11,
        LH_      =  6'd12,
        LW_      =  6'd13,
        LBU_     =  6'd14,
        LHU_     =  6'd15,
        SB_      =  6'd16,
        SH_      =  6'd17,
        SW_      =  6'd18,
        ADDI_    =  6'd19,
        SLTI_    =  6'd20,  
        SLTIU_   =  6'd21,  
        XORI_    =  6'd22,  
        ORI_     =  6'd23,  
        ANDI_    =  6'd24,  
        SLLI_    =  6'd25,  
        SRLI_    =  6'd26,  
        SRAI_    =  6'd27,  
        ADD_     =  6'd28,  
        SUB_     =  6'd29,  
        SLL_     =  6'd30,  
        SLT_     =  6'd31,  
        SLTU_    =  6'd32,  
        SRL_     =  6'd33,  
        SRA_     =  6'd34,  
        XOR_     =  6'd35,  
        OR_      =  6'd36,  
        AND_     =  6'd37,  
        ECALL_   =  6'd38,  
        EBREAK_  =  6'd39
} debug_instr;

typedef enum logic [4:0] {
    r0  = 5'd0,
    r1  = 5'd1,
    r2  = 5'd2,
    r3  = 5'd3,
    r4  = 5'd4,
    r5  = 5'd5,
    r6  = 5'd6,
    r7  = 5'd7,
    r8  = 5'd8,
    r9  = 5'd9,
    r10 = 5'd10,
    r11 = 5'd11,
    r12 = 5'd12,
    r13 = 5'd13,
    r14 = 5'd14,
    r15 = 5'd15,
    r16 = 5'd16,
    r17 = 5'd17,
    r18 = 5'd18,
    r19 = 5'd19,
    r20 = 5'd20,
    r21 = 5'd21,
    r22 = 5'd22,
    r23 = 5'd23,
    r24 = 5'd24,
    r25 = 5'd25,
    r26 = 5'd26,
    r27 = 5'd27,
    r28 = 5'd28,
    r29 = 5'd29,
    r30 = 5'd30,
    r31 = 5'd31
} register_idx;


typedef struct packed {
        debug_instr     db_instr;
        register_idx    db_rs1_addr;
        register_idx    db_rs2_addr;
        register_idx    db_rd_addr;
        logic [31:0]    db_rs1_data;
        logic [31:0]    db_rs2_data;
        logic [31:0]    db_rd_data;
        logic [31:0]    db_imm;
        logic [31:0]    db_pc;
        logic [31:0]    db_instr_asm;
        logic           db_wr_en;
        logic           db_valid;
        logic           db_prd_en;
        logic           db_is_instr2;

} debug_t ;




endpackage : aqua_pkg
