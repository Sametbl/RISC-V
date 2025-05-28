import aqua_pkg::*;

module bru(
    input  bru_issue_t     i_abt_bru_pkg,
    output uv_buff_t       o_bru_buff_pkg,
    output branch_t        o_bru_prd_pkg,     // From BRU to "Branch Prediction Unit"


    input  debug_t         i_abt_bru_debug



);

// Rename signal for readability
logic [31:0] operand_a, operand_b;
logic [31:0] rs1_data,  rs2_data;        // Comparing for branch condition
logic [4:0]  rd_addr;
operator_e   instr_op;
logic        is_instr2;
logic        wr_en;
logic        valid;

assign instr_op  = i_abt_bru_pkg.instr_op;
assign operand_a = i_abt_bru_pkg.operand_a;  // oprand_a = PC if brnach instruction
assign operand_b = i_abt_bru_pkg.operand_b;  // oprand_b = imm if branch instruction
assign rs1_data  = i_abt_bru_pkg.rs1_data;   // rs1_data = register_A, compare with rs2_data
assign rs2_data  = i_abt_bru_pkg.rs2_data;   // rs2_data = register_B
assign valid     = i_abt_bru_pkg.valid;
assign wr_en     = i_abt_bru_pkg.wr_en;
assign rd_addr   = i_abt_bru_pkg.rd_addr;
assign is_instr2 = i_abt_bru_pkg.is_instr2;

// Control signal
logic signed_cmp;     // Select signed or unsigned branch condition
logic rs1_eq_rs2;     // rs1 == rs2    (Equal)
logic rs1_lt_rs2;     // rs1 <  rs2    (Less Than)
logic br_taken;       // Actual result of branch instructions

assign signed_cmp = (instr_op == BLTU) | (instr_op == BGEU);

comparator_32bit  branch_condition (
                    .A          (rs1_data  ),
                    .B          (rs2_data  ),
                    .is_unsigned(signed_cmp),
                    .equal      (rs1_eq_rs2),
                    .smaller    (rs1_lt_rs2),
                    .larger     (          )
);

alu_issue_t    bru_alu_pkg_in;     // Input  Package for internal ALU
uv_buff_t      bru_alu_pkg_out;    // Output package of  internal ALU

logic [31:0]   prd_target;         // Calculated Target address for Branch prediction unit
logic [31:0]   rd_data;            // The selected Output/Writeback data
logic [1:0]    rd_data_sel;        // Select signal for Output data
logic          J_type;             // HIGH when branch instructions are JUMP


// ALU input package assignment
assign bru_alu_pkg_in.instr_op   = instr_op;
assign bru_alu_pkg_in.operand_a  = operand_a;    // Operand_a = (rs1_data) or (PC)
assign bru_alu_pkg_in.operand_b  = operand_b;    // Operand_b = (rs2_data) or (imm)
assign bru_alu_pkg_in.rd_addr    = i_abt_bru_pkg.rd_addr;
assign bru_alu_pkg_in.wr_en      = wr_en;
assign bru_alu_pkg_in.valid      = valid;
assign bru_alu_pkg_in.is_instr2  = is_instr2;

// ALU module
alu    alu_of_bru (.i_abt_alu_pkg(bru_alu_pkg_in),
                   .o_alu_buff_pkg(bru_alu_pkg_out),
                   .i_abt_alu_debug(i_abt_bru_debug)          // REMOVE THIS WHEN DONE DEBUGGING
);


// Branch Prediction Unit feedback
assign J_type   =  (instr_op == JAL)  | (instr_op == JALR);
assign br_taken = ((instr_op == BEQ)  &  rs1_eq_rs2) |   // Brnach if Equal
                  ((instr_op == BNE)  & ~rs1_eq_rs2) |   // Branch if Not Equal
                  ((instr_op == BLT)  &  rs1_lt_rs2) |   // Branch if Less Than
                  ((instr_op == BGE)  & ~rs1_lt_rs2) |   // Branch if Greater or Equal
                  ((instr_op == BLTU) &  rs1_lt_rs2) |   // Branch if Less Than - Unsigned
                  ((instr_op == BGEU) & ~rs1_lt_rs2) |   // Branch if Greater or Equal - Unsigned
                  (J_type);


// Output data selection

// rd_data_sel = 2'b00 : BRU acts as a second ALU ==>  rd_data = ALU
// rd_data_sel = 2'b01 : Save return PC to regfile when instruction 1 is JUMP ==> rd_data =  pc    + 4
// rd_data_sel = 2'b10 : Save return PC to regfile when instruction 2 is JUMP ==> rd_daat = (pc+4) + 4
// rd_data_sel = 2'b11 : Reserved

logic [3:0][31:0] rd_data_mux_in;

assign rd_data_sel[0]    = J_type & ~is_instr2;
assign rd_data_sel[1]    = J_type &  is_instr2;

assign rd_data_mux_in[0] = bru_alu_pkg_out.data_buff;
assign rd_data_mux_in[1] = i_abt_bru_pkg.pc + 32'd4;
assign rd_data_mux_in[2] = i_abt_bru_pkg.pc + 32'd4;
assign rd_data_mux_in[3] = 32'b0;

mux #(.WIDTH(32), .NUM_INPUT(4)) mux_PC_four (
            .sel   (rd_data_sel   ),
            .i_mux (rd_data_mux_in),
            .o_mux (rd_data       )
);




// UV_pipe buffer
assign o_bru_buff_pkg.is_instr2 = bru_alu_pkg_out.is_instr2;
assign o_bru_buff_pkg.rd_buff   = bru_alu_pkg_out.rd_buff;
assign o_bru_buff_pkg.data_buff = rd_data;
assign o_bru_buff_pkg.valid     = bru_alu_pkg_out.valid;
assign o_bru_buff_pkg.wr_en     = bru_alu_pkg_out.wr_en;

// Branch prediction unit feedback signals
assign o_bru_prd_pkg.update_en = i_abt_bru_pkg.prd_en;
assign o_bru_prd_pkg.pc_lookup = operand_a;
assign o_bru_prd_pkg.target    = bru_alu_pkg_out.data_buff;
assign o_bru_prd_pkg.taken     = br_taken;
assign o_bru_prd_pkg.valid     = valid;
//debug
logic prd_en_db;
assign prd_en_db = i_abt_bru_pkg.prd_en;






// DEBUG
debug_instr     bru_db_instr;
register_idx    bru_db_rs1_addr;
register_idx    bru_db_rs2_addr;
register_idx    bru_db_rd_addr;
logic [31:0]    bru_db_rs1_data;
logic [31:0]    bru_db_rs2_data;
logic [31:0]    bru_db_rd_data;
logic [31:0]    bru_db_imm;
logic [31:0]    bru_db_pc;
logic [31:0]    bru_db_instr_asm;
logic           bru_db_wr_en;
logic           bru_db_valid;
logic           bru_db_prd_en;
logic           bru_db_is_instr2;


assign bru_db_instr      = i_abt_bru_debug.db_instr; 
assign bru_db_rs1_addr   = i_abt_bru_debug.db_rs1_addr; 
assign bru_db_rs2_addr   = i_abt_bru_debug.db_rs2_addr; 
assign bru_db_rd_addr    = i_abt_bru_debug.db_rd_addr; 
assign bru_db_rs1_data   = i_abt_bru_debug.db_rs1_data; 
assign bru_db_rs2_data   = i_abt_bru_debug.db_rs2_data; 
assign bru_db_rd_data    = rd_data; 
assign bru_db_imm        = i_abt_bru_debug.db_imm; 
assign bru_db_pc         = i_abt_bru_debug.db_pc; 
assign bru_db_instr_asm  = i_abt_bru_debug.db_instr_asm; 
assign bru_db_wr_en      = i_abt_bru_debug.db_wr_en; 
assign bru_db_valid      = i_abt_bru_debug.db_valid; 
assign bru_db_prd_en     = i_abt_bru_debug.db_prd_en; 
assign bru_db_is_instr2  = i_abt_bru_debug.db_is_instr2; 

endmodule : bru




