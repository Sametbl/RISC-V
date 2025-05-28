import aqua_pkg::*;
module arbitrator (
  input logic             i_clk,
  input logic             i_rst_n,
  input logic             i_buff_en,
  input logic             i_invalidate,

  input decode_t          i_sch_arb_instr1,        //instruction 1 package
  input decode_t          i_sch_arb_instr2,        //instruction 2 package
  input rs_data_t         i_rf_arb_rs_data,        // Regfile data
  input forwarding_t      i_fw_arb_pkg,            // Forwarding select signal and data

  output alu_issue_t      o_arb_alu_pkg,           //package send to BRU
  output bru_issue_t      o_arb_bru_pkg,           //package send to ALU
  output agu_issue_t      o_arb_agu_pkg,           //package send to AGU


  output  debug_t         o_abt_alu_debug,         // Remove this when done debugging
  output  debug_t         o_abt_bru_debug,         // Remove this when done debugging
  output  debug_t         o_abt_agu_debug          // Remove this when done debugging


);

//------------------------Forwarding data select for source registers------------------------//
logic [14:0][31:0] fwd_data;       // Package for MUXs (seven 32-bti datas)
logic [31:0]   instr1_rs1_dat;     // Offical rs_data for the Execution unit
logic [31:0]   instr1_rs2_dat;
logic [31:0]   instr2_rs1_dat;
logic [31:0]   instr2_rs2_dat;

assign fwd_data[0]  = i_fw_arb_pkg.alu1_fwd_dat;
assign fwd_data[1]  = i_fw_arb_pkg.alu2_fwd_dat;
assign fwd_data[2]  = i_fw_arb_pkg.alu3_fwd_dat;
assign fwd_data[3]  = i_fw_arb_pkg.bru1_fwd_dat;
assign fwd_data[4]  = i_fw_arb_pkg.bru2_fwd_dat;
assign fwd_data[5]  = i_fw_arb_pkg.bru3_fwd_dat;
assign fwd_data[6]  = i_fw_arb_pkg.mem1_fwd_dat;
assign fwd_data[7]  = i_fw_arb_pkg.mem2_fwd_dat;

assign fwd_data[8]  = 32'b0;
assign fwd_data[9]  = 32'b0;
assign fwd_data[10] = 32'b0;
assign fwd_data[11] = 32'b0;
assign fwd_data[12] = 32'b0;
assign fwd_data[13] = 32'b0;
assign fwd_data[14] = 32'b0;

mux #(.WIDTH(32), .NUM_INPUT(16))  fwd_mux_1(
       .sel  (i_fw_arb_pkg.fwd_rs1_instr1)         ,
       .i_mux({fwd_data, i_rf_arb_rs_data.rs1_data_instr1}),
       .o_mux(instr1_rs1_dat)
);

mux #(.WIDTH(32), .NUM_INPUT(16))  fwd_mux_2(
       .sel(i_fw_arb_pkg.fwd_rs2_instr1)           ,
       .i_mux({fwd_data, i_rf_arb_rs_data.rs2_data_instr1}),
       .o_mux(instr1_rs2_dat)
);

mux #(.WIDTH(32), .NUM_INPUT(16))  fwd_mux_3(
       .sel(i_fw_arb_pkg.fwd_rs1_instr2),
       .i_mux({fwd_data, i_rf_arb_rs_data.rs1_data_instr2}),
       .o_mux(instr2_rs1_dat)
);

mux #(.WIDTH(32), .NUM_INPUT(16))  fwd_mux_4(
       .sel(i_fw_arb_pkg.fwd_rs2_instr2),
       .i_mux({fwd_data, i_rf_arb_rs_data.rs2_data_instr2}),
       .o_mux(instr2_rs2_dat)
);


//-------------------------------------------------------------------------------------------//
// Rename signals
funct_e       instr1_funct, instr2_funct;
logic         instr1_valid, instr2_valid;
logic         instr1_wr_en, instr2_wr_en;
operator_e    instr_op_1, instr_op_2;

assign instr1_valid = i_sch_arb_instr1.valid;
assign instr2_valid = i_sch_arb_instr2.valid;
assign instr1_funct = i_sch_arb_instr1.funct;
assign instr2_funct = i_sch_arb_instr2.funct;
assign instr_op_1   = i_sch_arb_instr1.instr_op;
assign instr_op_2   = i_sch_arb_instr2.instr_op;
assign instr1_wr_en = i_sch_arb_instr1.wr_en;
assign instr2_wr_en = i_sch_arb_instr2.wr_en;

// Instructions Function indication signals
logic instr1_ALU_funct, instr1_AGU_funct, instr1_BRU_funct;
logic instr2_ALU_funct, instr2_AGU_funct, instr2_BRU_funct;

assign instr1_ALU_funct = ( instr1_funct == ALU);
assign instr1_BRU_funct = ( instr1_funct == CTRL_TRNSF);
assign instr1_AGU_funct = ((instr1_funct == LOAD) | (instr1_funct == STORE));

assign instr2_ALU_funct = ( instr2_funct == ALU);
assign instr2_BRU_funct = ( instr2_funct == CTRL_TRNSF) | (instr2_ALU_funct & instr1_ALU_funct);
assign instr2_AGU_funct = ((instr2_funct == LOAD) | (instr2_funct == STORE));




alu_issue_t instr1_tmp_alu_pkg, instr2_tmp_alu_pkg;
bru_issue_t instr1_tmp_bru_pkg, instr2_tmp_bru_pkg;
agu_issue_t instr1_tmp_agu_pkg, instr2_tmp_agu_pkg;
alu_issue_t ALU_data_pkg;
bru_issue_t BRU_data_pkg;
agu_issue_t AGU_data_pkg;

logic [31:0] instr1_alu_op_a, instr1_alu_op_b;
logic [31:0] instr2_alu_op_a, instr2_alu_op_b;

assign instr1_alu_op_a = (i_sch_arb_instr1.use_pc  == 1)? i_sch_arb_instr1.pc  : instr1_rs1_dat;
assign instr1_alu_op_b = (i_sch_arb_instr1.use_imm == 1)? i_sch_arb_instr1.imm : instr1_rs2_dat;

assign instr2_alu_op_a = (i_sch_arb_instr2.use_pc  == 1)? i_sch_arb_instr2.pc  : instr2_rs1_dat;
assign instr2_alu_op_b = (i_sch_arb_instr2.use_imm == 1)? i_sch_arb_instr2.imm : instr2_rs2_dat;


// ============================= DATA PACKAGE ASSIGNMENT ======================

// -------------------------- INSTRUCTION 1 ---------------------------------
assign instr1_tmp_alu_pkg.instr_op  =  i_sch_arb_instr1.instr_op;
assign instr1_tmp_alu_pkg.operand_a =  (instr_op_1 == LUI) ? 32'b0 : instr1_alu_op_a; // Lui equal 0 so it add 0
assign instr1_tmp_alu_pkg.operand_b =  instr1_alu_op_b;
assign instr1_tmp_alu_pkg.rd_addr   =  i_sch_arb_instr1.rd_addr;
assign instr1_tmp_alu_pkg.valid     =  instr1_ALU_funct & instr1_valid & ~i_invalidate;
assign instr1_tmp_alu_pkg.wr_en     =  instr1_ALU_funct & instr1_wr_en;
assign instr1_tmp_alu_pkg.is_instr2 =  1'b0;

assign instr1_tmp_bru_pkg.instr_op  =  i_sch_arb_instr1.instr_op;
assign instr1_tmp_bru_pkg.operand_a =  (instr_op_1 == LUI) ? 32'b0 : instr1_alu_op_a;
assign instr1_tmp_bru_pkg.operand_b =  instr1_alu_op_b;
assign instr1_tmp_bru_pkg.rs1_data  =  instr1_rs1_dat;
assign instr1_tmp_bru_pkg.rs2_data  =  instr1_rs2_dat;
assign instr1_tmp_bru_pkg.rd_addr   =  i_sch_arb_instr1.rd_addr;
assign instr1_tmp_bru_pkg.valid     =  instr1_BRU_funct & instr1_valid & ~i_invalidate;
assign instr1_tmp_bru_pkg.prd_en    =  i_sch_arb_instr1.prd_en;
assign instr1_tmp_bru_pkg.wr_en     =  instr1_BRU_funct & instr1_wr_en;
assign instr1_tmp_bru_pkg.pc        =  i_sch_arb_instr1.pc;
assign instr1_tmp_bru_pkg.is_instr2 =  1'b0;

assign instr1_tmp_agu_pkg.instr_op  =  i_sch_arb_instr1.instr_op;
assign instr1_tmp_agu_pkg.data      =  instr1_rs2_dat;
assign instr1_tmp_agu_pkg.operand_a =  (instr_op_1 == LUI) ? 32'b0 : instr1_rs1_dat;
assign instr1_tmp_agu_pkg.operand_b =  i_sch_arb_instr1.imm;
assign instr1_tmp_agu_pkg.rd_addr   =  i_sch_arb_instr1.rd_addr;
assign instr1_tmp_agu_pkg.valid     =  instr1_AGU_funct & instr1_valid & ~i_invalidate;
assign instr1_tmp_agu_pkg.wr_en     =  instr1_AGU_funct & instr1_wr_en;
assign instr1_tmp_agu_pkg.is_instr2 =  1'b0;


// ----------------------------  INSTRUCTION 2 ----------------------------
assign instr2_tmp_alu_pkg.instr_op  =  i_sch_arb_instr2.instr_op;
assign instr2_tmp_alu_pkg.operand_a =  (instr_op_2 == LUI) ? 32'b0 : instr2_alu_op_a;
assign instr2_tmp_alu_pkg.operand_b =  instr2_alu_op_b;
assign instr2_tmp_alu_pkg.rd_addr   =  i_sch_arb_instr2.rd_addr;
assign instr2_tmp_alu_pkg.valid     =  instr2_ALU_funct & instr2_valid & ~i_invalidate;
assign instr2_tmp_alu_pkg.wr_en     =  instr2_ALU_funct & instr2_wr_en;
assign instr2_tmp_alu_pkg.is_instr2 =  1'b1;

assign instr2_tmp_bru_pkg.instr_op  =  i_sch_arb_instr2.instr_op;
assign instr2_tmp_bru_pkg.operand_a =  (instr_op_2 == LUI) ? 32'b0 : instr2_alu_op_a;
assign instr2_tmp_bru_pkg.operand_b =  instr2_alu_op_b;
assign instr2_tmp_bru_pkg.rs1_data  =  instr2_rs1_dat;
assign instr2_tmp_bru_pkg.rs2_data  =  instr2_rs2_dat;
assign instr2_tmp_bru_pkg.rd_addr   =  i_sch_arb_instr2.rd_addr;
assign instr2_tmp_bru_pkg.valid     =  instr2_BRU_funct & instr2_valid & ~i_invalidate;
assign instr2_tmp_bru_pkg.prd_en    =  i_sch_arb_instr2.prd_en;
assign instr2_tmp_bru_pkg.wr_en     =  instr2_BRU_funct & instr2_wr_en;
assign instr2_tmp_bru_pkg.pc        =  i_sch_arb_instr2.pc;
assign instr2_tmp_bru_pkg.is_instr2 =  1'b1;

assign instr2_tmp_agu_pkg.instr_op  =  i_sch_arb_instr2.instr_op;
assign instr2_tmp_agu_pkg.data      =  instr2_rs2_dat;
assign instr2_tmp_agu_pkg.operand_a =  (instr_op_2 == LUI) ? 32'b0 : instr2_rs1_dat;
assign instr2_tmp_agu_pkg.operand_b =  i_sch_arb_instr2.imm;
assign instr2_tmp_agu_pkg.rd_addr   =  i_sch_arb_instr2.rd_addr;
assign instr2_tmp_agu_pkg.valid     =  instr2_AGU_funct & instr2_valid & ~i_invalidate;
assign instr2_tmp_agu_pkg.wr_en     =  instr2_AGU_funct & instr2_wr_en;
assign instr2_tmp_agu_pkg.is_instr2 =  1'b1;



// ============================ ARBITRATING DATAS ===========================
logic instr2_to_ALU;  // ALU selects instr2
logic instr2_to_BRU;  // BRU selects instr2 when
logic instr2_to_AGU;  // AGU selects instr2 when

assign instr2_to_ALU =  instr2_valid & instr2_ALU_funct & ~(instr1_valid & instr1_ALU_funct);

assign instr2_to_BRU = (instr2_valid & instr2_ALU_funct &   instr1_valid & instr1_ALU_funct) |
                       (instr2_valid & instr2_BRU_funct);

assign instr2_to_AGU =  instr2_valid & instr2_AGU_funct;


mux #(.WIDTH($bits(ALU_data_pkg)), .NUM_INPUT(2)) ALU_package_mux (
       .sel   (instr2_to_ALU),
       .i_mux ({instr2_tmp_alu_pkg, instr1_tmp_alu_pkg}),
       .o_mux (ALU_data_pkg)
);


mux #(.WIDTH($bits(BRU_data_pkg)), .NUM_INPUT(2)) BRU_package_mux (
       .sel   (instr2_to_BRU),
       .i_mux ({instr2_tmp_bru_pkg, instr1_tmp_bru_pkg}),
       .o_mux (BRU_data_pkg)
);


mux #(.WIDTH($bits(AGU_data_pkg)), .NUM_INPUT(2)) AGU_package_mux (
       .sel   (instr2_to_AGU),
       .i_mux ({instr2_tmp_agu_pkg, instr1_tmp_agu_pkg}),
       .o_mux (AGU_data_pkg)
);


// ========================= OUTPUT BUFFERS =========================

register #(.WIDTH($bits(o_arb_alu_pkg))) ALU_input_buffer (
            .clk  (i_clk        ),
            .rst_n(i_rst_n      ),
            .en   (i_buff_en    ),
            .D    (ALU_data_pkg ),
            .Q    (o_arb_alu_pkg)
);
register #(.WIDTH($bits(o_arb_bru_pkg))) BRU_input_buffer (
            .clk  (i_clk        ),
            .rst_n(i_rst_n      ),
            .en   (i_buff_en    ),
            .D    (BRU_data_pkg ),
            .Q    (o_arb_bru_pkg)
);

register #(.WIDTH($bits(o_arb_agu_pkg))) AGU_input_buffer (
            .clk  (i_clk        ),
            .rst_n(i_rst_n      ),
            .en   (i_buff_en    ),
            .D    (AGU_data_pkg ),
            .Q    (o_arb_agu_pkg)
);








// ========================= Debug ===========================================
debug_instr     abt_db_instr_instr1;
register_idx    abt_db_rs1_addr_instr1;
register_idx    abt_db_rs2_addr_instr1;
register_idx    abt_db_rd_addr_instr1;
logic [31:0]    abt_db_rs1_data_instr1;
logic [31:0]    abt_db_rs2_data_instr1;
logic [31:0]    abt_db_rd_data_instr1;
logic [31:0]    abt_db_imm_instr1;
logic [31:0]    abt_db_pc_instr1;
logic [31:0]    abt_db_instr_asm_instr1;
logic           abt_db_wr_en_instr1;
logic           abt_db_valid_instr1;
logic           abt_db_prd_en_instr1;
logic           abt_db_is_instr2_instr1;

debug_instr     abt_db_instr_instr2;
register_idx    abt_db_rs1_addr_instr2;
register_idx    abt_db_rs2_addr_instr2;
register_idx    abt_db_rd_addr_instr2;
logic [31:0]    abt_db_rs1_data_instr2;
logic [31:0]    abt_db_rs2_data_instr2;
logic [31:0]    abt_db_rd_data_instr2;
logic [31:0]    abt_db_imm_instr2;
logic [31:0]    abt_db_pc_instr2;
logic [31:0]    abt_db_instr_asm_instr2;
logic           abt_db_wr_en_instr2;
logic           abt_db_valid_instr2;
logic           abt_db_prd_en_instr2;
logic           abt_db_is_instr2_instr2;





assign abt_db_instr_instr1      = i_sch_arb_instr1.debug_data.db_instr;
assign abt_db_rs1_addr_instr1   = i_sch_arb_instr1.debug_data.db_rs1_addr;
assign abt_db_rs2_addr_instr1   = i_sch_arb_instr1.debug_data.db_rs2_addr;
assign abt_db_rd_addr_instr1    = i_sch_arb_instr1.debug_data.db_rd_addr;
assign abt_db_rs1_data_instr1   = instr1_rs1_dat;
assign abt_db_rs2_data_instr1   = instr1_rs2_dat;
assign abt_db_rd_data_instr1    = i_sch_arb_instr1.debug_data.db_rd_data;
assign abt_db_imm_instr1        = i_sch_arb_instr1.debug_data.db_imm;
assign abt_db_pc_instr1         = i_sch_arb_instr1.debug_data.db_pc;
assign abt_db_instr_asm_instr1  = i_sch_arb_instr1.debug_data.db_instr_asm;
assign abt_db_wr_en_instr1      = i_sch_arb_instr1.debug_data.db_wr_en;
assign abt_db_valid_instr1      = i_sch_arb_instr1.debug_data.db_valid;
assign abt_db_prd_en_instr1     = i_sch_arb_instr1.debug_data.db_prd_en;
assign abt_db_is_instr2_instr1  = i_sch_arb_instr1.debug_data.db_is_instr2;

assign abt_db_instr_instr2      = i_sch_arb_instr2.debug_data.db_instr;
assign abt_db_rs1_addr_instr2   = i_sch_arb_instr2.debug_data.db_rs1_addr;
assign abt_db_rs2_addr_instr2   = i_sch_arb_instr2.debug_data.db_rs2_addr;
assign abt_db_rd_addr_instr2    = i_sch_arb_instr2.debug_data.db_rd_addr;
assign abt_db_rs1_data_instr2   = instr2_rs1_dat;
assign abt_db_rs2_data_instr2   = instr2_rs2_dat;
assign abt_db_rd_data_instr2    = i_sch_arb_instr2.debug_data.db_rd_data;
assign abt_db_imm_instr2        = i_sch_arb_instr2.debug_data.db_imm;
assign abt_db_pc_instr2         = i_sch_arb_instr2.debug_data.db_pc;
assign abt_db_instr_asm_instr2  = i_sch_arb_instr2.debug_data.db_instr_asm;
assign abt_db_wr_en_instr2      = i_sch_arb_instr2.debug_data.db_wr_en;
assign abt_db_valid_instr2      = i_sch_arb_instr2.debug_data.db_valid;
assign abt_db_prd_en_instr2     = i_sch_arb_instr2.debug_data.db_prd_en;
assign abt_db_is_instr2_instr2  = 1'b1;




debug_instr     D_db_instr_alu,     D_db_instr_bru,     D_db_instr_agu;
register_idx    D_db_rs1_addr_alu,  D_db_rs1_addr_bru,  D_db_rs1_addr_agu;
register_idx    D_db_rs2_addr_alu,  D_db_rs2_addr_bru,  D_db_rs2_addr_agu;
register_idx    D_db_rd_addr_alu,   D_db_rd_addr_bru,   D_db_rd_addr_agu;
logic [31:0]    D_db_rs1_data_alu,  D_db_rs1_data_bru,  D_db_rs1_data_agu;
logic [31:0]    D_db_rs2_data_alu,  D_db_rs2_data_bru,  D_db_rs2_data_agu;
logic [31:0]    D_db_rd_data_alu,   D_db_rd_data_bru,   D_db_rd_data_agu;
logic [31:0]    D_db_imm_alu,       D_db_imm_bru,       D_db_imm_agu;
logic [31:0]    D_db_pc_alu,        D_db_pc_bru,        D_db_pc_agu;
logic [31:0]    D_db_instr_asm_alu, D_db_instr_asm_bru, D_db_instr_asm_agu;
logic           D_db_wr_en_alu,     D_db_wr_en_bru,     D_db_wr_en_agu;
logic           D_db_valid_alu,     D_db_valid_bru,     D_db_valid_agu;
logic           D_db_prd_en_alu,    D_db_prd_en_bru,    D_db_prd_en_agu;
logic           D_db_is_instr2_alu, D_db_is_instr2_bru, D_db_is_instr2_agu;



 

assign D_db_instr_alu      = (ALU_data_pkg.is_instr2 == 1'b1) ? abt_db_instr_instr2     : abt_db_instr_instr1;
assign D_db_rs1_addr_alu   = (ALU_data_pkg.is_instr2 == 1'b1) ? abt_db_rs1_addr_instr2  : abt_db_rs1_addr_instr1;
assign D_db_rs2_addr_alu   = (ALU_data_pkg.is_instr2 == 1'b1) ? abt_db_rs2_addr_instr2  : abt_db_rs2_addr_instr1;
assign D_db_rs1_data_alu   = (ALU_data_pkg.is_instr2 == 1'b1) ? instr1_rs2_dat          : instr1_rs1_dat;
assign D_db_rs2_data_alu   = (ALU_data_pkg.is_instr2 == 1'b1) ? instr2_rs2_dat          : instr2_rs1_dat;
assign D_db_rd_data_alu    = (ALU_data_pkg.is_instr2 == 1'b1) ? abt_db_rd_data_instr2   : abt_db_rd_data_instr1;
assign D_db_imm_alu        = (ALU_data_pkg.is_instr2 == 1'b1) ? abt_db_imm_instr2       : abt_db_imm_instr1;
assign D_db_pc_alu         = (ALU_data_pkg.is_instr2 == 1'b1) ? abt_db_pc_instr2        : abt_db_pc_instr1;
assign D_db_instr_asm_alu  = (ALU_data_pkg.is_instr2 == 1'b1) ? abt_db_instr_asm_instr2 : abt_db_instr_asm_instr1;
assign D_db_rd_addr_alu    = register_idx'(ALU_data_pkg.rd_addr);
assign D_db_wr_en_alu      = ALU_data_pkg.wr_en;
assign D_db_valid_alu      = ALU_data_pkg.valid;
assign D_db_is_instr2_alu  = ALU_data_pkg.is_instr2;
assign D_db_prd_en_alu     = 1'b0;




assign D_db_instr_bru      = (BRU_data_pkg.is_instr2 == 1'b1) ? abt_db_instr_instr2     : abt_db_instr_instr1;
assign D_db_rs1_addr_bru   = (BRU_data_pkg.is_instr2 == 1'b1) ? abt_db_rs1_addr_instr2  : abt_db_rs1_addr_instr1;
assign D_db_rs2_addr_bru   = (BRU_data_pkg.is_instr2 == 1'b1) ? abt_db_rs2_addr_instr2  : abt_db_rs2_addr_instr1;
assign D_db_rs1_data_bru   = (BRU_data_pkg.is_instr2 == 1'b1) ? instr1_rs2_dat          : instr1_rs1_dat;
assign D_db_rs2_data_bru   = (BRU_data_pkg.is_instr2 == 1'b1) ? instr2_rs2_dat          : instr2_rs1_dat;
assign D_db_rd_data_bru    = (BRU_data_pkg.is_instr2 == 1'b1) ? abt_db_rd_data_instr2   : abt_db_rd_data_instr1;
assign D_db_imm_bru        = (BRU_data_pkg.is_instr2 == 1'b1) ? abt_db_imm_instr2       : abt_db_imm_instr1;
assign D_db_pc_bru         = (BRU_data_pkg.is_instr2 == 1'b1) ? abt_db_pc_instr2        : abt_db_pc_instr1;
assign D_db_instr_asm_bru  = (BRU_data_pkg.is_instr2 == 1'b1) ? abt_db_instr_asm_instr2 : abt_db_instr_asm_instr1;
assign D_db_rd_addr_bru    = register_idx'(BRU_data_pkg.rd_addr);
assign D_db_wr_en_bru      = BRU_data_pkg.wr_en;
assign D_db_valid_bru      = BRU_data_pkg.valid;
assign D_db_is_instr2_bru  = BRU_data_pkg.is_instr2;
assign D_db_prd_en_bru     = BRU_data_pkg.prd_en;


assign D_db_instr_agu      = (AGU_data_pkg.is_instr2 == 1'b1) ? abt_db_instr_instr2     : abt_db_instr_instr1;
assign D_db_rs1_addr_agu   = (AGU_data_pkg.is_instr2 == 1'b1) ? abt_db_rs1_addr_instr2  : abt_db_rs1_addr_instr1;
assign D_db_rs2_addr_agu   = (AGU_data_pkg.is_instr2 == 1'b1) ? abt_db_rs2_addr_instr2  : abt_db_rs2_addr_instr1;
assign D_db_rs1_data_agu   = (AGU_data_pkg.is_instr2 == 1'b1) ? instr1_rs2_dat          : instr1_rs1_dat;
assign D_db_rs2_data_agu   = (AGU_data_pkg.is_instr2 == 1'b1) ? instr2_rs2_dat          : instr2_rs1_dat;
assign D_db_rd_data_agu    = (AGU_data_pkg.is_instr2 == 1'b1) ? abt_db_rd_data_instr2   : abt_db_rd_data_instr1;
assign D_db_imm_agu        = (AGU_data_pkg.is_instr2 == 1'b1) ? abt_db_imm_instr2       : abt_db_imm_instr1;
assign D_db_pc_agu         = (AGU_data_pkg.is_instr2 == 1'b1) ? abt_db_pc_instr2        : abt_db_pc_instr1;
assign D_db_instr_asm_agu  = (AGU_data_pkg.is_instr2 == 1'b1) ? abt_db_instr_asm_instr2 : abt_db_instr_asm_instr1;
assign D_db_rd_addr_agu    = register_idx'(AGU_data_pkg.rd_addr);
assign D_db_wr_en_agu      = AGU_data_pkg.wr_en;
assign D_db_valid_agu      = AGU_data_pkg.valid;
assign D_db_is_instr2_agu  = AGU_data_pkg.is_instr2;
assign D_db_prd_en_agu     = 1'b0;


always_ff @(posedge i_clk, negedge i_rst_n) begin : debug_buffer
       o_abt_alu_debug.db_instr      <=    D_db_instr_alu;
       o_abt_alu_debug.db_rs1_addr   <=    D_db_rs1_addr_alu;
       o_abt_alu_debug.db_rs2_addr   <=    D_db_rs2_addr_alu;
       o_abt_alu_debug.db_rd_addr    <=    D_db_rd_addr_alu;
       o_abt_alu_debug.db_rs1_data   <=    D_db_rs1_data_alu;
       o_abt_alu_debug.db_rs2_data   <=    D_db_rs2_data_alu;
       o_abt_alu_debug.db_rd_data    <=    D_db_rd_data_alu;
       o_abt_alu_debug.db_imm        <=    D_db_imm_alu;
       o_abt_alu_debug.db_pc         <=    D_db_pc_alu;
       o_abt_alu_debug.db_instr_asm  <=    D_db_instr_asm_alu;
       o_abt_alu_debug.db_wr_en      <=    D_db_wr_en_alu;
       o_abt_alu_debug.db_valid      <=    D_db_valid_alu;
       o_abt_alu_debug.db_prd_en     <=    D_db_prd_en_alu;
       o_abt_alu_debug.db_is_instr2  <=    D_db_is_instr2_alu; //


       o_abt_bru_debug.db_instr      <=    D_db_instr_bru;
       o_abt_bru_debug.db_rs1_addr   <=    D_db_rs1_addr_bru;
       o_abt_bru_debug.db_rs2_addr   <=    D_db_rs2_addr_bru;
       o_abt_bru_debug.db_rd_addr    <=    D_db_rd_addr_bru;
       o_abt_bru_debug.db_rs1_data   <=    D_db_rs1_data_bru;
       o_abt_bru_debug.db_rs2_data   <=    D_db_rs2_data_bru;
       o_abt_bru_debug.db_rd_data    <=    D_db_rd_data_bru;
       o_abt_bru_debug.db_imm        <=    D_db_imm_bru;
       o_abt_bru_debug.db_pc         <=    D_db_pc_bru;
       o_abt_bru_debug.db_instr_asm  <=    D_db_instr_asm_bru;
       o_abt_bru_debug.db_wr_en      <=    D_db_wr_en_bru;
       o_abt_bru_debug.db_valid      <=    D_db_valid_bru;
       o_abt_bru_debug.db_prd_en     <=    D_db_prd_en_bru;
       o_abt_bru_debug.db_is_instr2  <=    D_db_is_instr2_bru; //


       o_abt_agu_debug.db_instr      <=    D_db_instr_agu;
       o_abt_agu_debug.db_rs1_addr   <=    D_db_rs1_addr_agu;
       o_abt_agu_debug.db_rs2_addr   <=    D_db_rs2_addr_agu;
       o_abt_agu_debug.db_rd_addr    <=    D_db_rd_addr_agu;
       o_abt_agu_debug.db_rs1_data   <=    D_db_rs1_data_agu;
       o_abt_agu_debug.db_rs2_data   <=    D_db_rs2_data_agu;
       o_abt_agu_debug.db_rd_data    <=    D_db_rd_data_agu;
       o_abt_agu_debug.db_imm        <=    D_db_imm_agu;
       o_abt_agu_debug.db_pc         <=    D_db_pc_agu;
       o_abt_agu_debug.db_instr_asm  <=    D_db_instr_asm_agu;
       o_abt_agu_debug.db_wr_en      <=    D_db_wr_en_agu;
       o_abt_agu_debug.db_valid      <=    D_db_valid_agu;
       o_abt_agu_debug.db_prd_en     <=    D_db_prd_en_agu;
       o_abt_agu_debug.db_is_instr2  <=    D_db_is_instr2_agu;
end

endmodule


