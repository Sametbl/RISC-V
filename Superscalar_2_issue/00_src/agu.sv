import aqua_pkg::*;
module agu(
    input  agu_issue_t       i_abt_agu_pkg,
    output mem_req_t         o_agu_lsu_pkg,

    input  debug_t           i_abt_agu_debug


);

alu_issue_t    abt_alu_pkg;
uv_buff_t      alu_buff_pkg;

logic [31:0] operand_pc;
logic [31:0] operand_imm;
logic [31:0] pc_target;

assign operand_pc    = i_abt_agu_pkg.operand_a;  // op_a = PC
assign operand_imm   = i_abt_agu_pkg.operand_b;  // op_b = imm

full_adder_32bit address_calculate (
        .A       (operand_pc ),
        .B       (operand_imm),
        .Invert_B(1'b0       ),
        .C_in    (1'b0       ),
        .Sum     (pc_target  ),
        .C_out   (           )
);

assign o_agu_lsu_pkg.target_addr = pc_target;
assign o_agu_lsu_pkg.instr       = i_abt_agu_pkg.instr_op;
assign o_agu_lsu_pkg.data        = i_abt_agu_pkg.data;
assign o_agu_lsu_pkg.rd_addr     = i_abt_agu_pkg.rd_addr;
assign o_agu_lsu_pkg.wr_en       = i_abt_agu_pkg.wr_en;
assign o_agu_lsu_pkg.valid       = i_abt_agu_pkg.valid;
assign o_agu_lsu_pkg.is_instr2   = i_abt_agu_pkg.is_instr2;







// DEBUG
debug_instr     agu_db_instr;
register_idx    agu_db_rs1_addr;
register_idx    agu_db_rs2_addr;
register_idx    agu_db_rd_addr;
logic [31:0]    agu_db_rs1_data;
logic [31:0]    agu_db_rs2_data;
logic [31:0]    agu_db_rd_data;
logic [31:0]    agu_db_imm;
logic [31:0]    agu_db_pc;
logic [31:0]    agu_db_instr_asm;
logic           agu_db_wr_en;
logic           agu_db_valid;
logic           agu_db_prd_en;
logic           agu_db_is_instr2;


assign agu_db_instr      = i_abt_agu_debug.db_instr; 
assign agu_db_rs1_addr   = i_abt_agu_debug.db_rs1_addr; 
assign agu_db_rs2_addr   = i_abt_agu_debug.db_rs2_addr; 
assign agu_db_rd_addr    = i_abt_agu_debug.db_rd_addr; 
assign agu_db_rs1_data   = i_abt_agu_debug.db_rs1_data; 
assign agu_db_rs2_data   = i_abt_agu_debug.db_rs2_data; 
assign agu_db_rd_data    = 32'bx; 
assign agu_db_imm        = i_abt_agu_debug.db_imm; 
assign agu_db_pc         = i_abt_agu_debug.db_pc; 
assign agu_db_instr_asm  = i_abt_agu_debug.db_instr_asm; 
assign agu_db_wr_en      = i_abt_agu_debug.db_wr_en; 
assign agu_db_valid      = i_abt_agu_debug.db_valid; 
assign agu_db_prd_en     = i_abt_agu_debug.db_prd_en; 
assign agu_db_is_instr2  = i_abt_agu_debug.db_is_instr2; 

endmodule




