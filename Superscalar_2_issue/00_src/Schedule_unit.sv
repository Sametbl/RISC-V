import aqua_pkg::*;

module schedule_unit(
// Inputs
input  logic        i_clk               ,
input  logic        i_rstn              ,
input  logic        i_dque_sch_ready    ,
input  logic        i_dque_sch_ack      ,
input  decode_t     i_dque_sch_decode_0 ,
input  decode_t     i_dque_sch_decode_1 ,
output logic        o_sch_dque_request  ,
output decode_t     o_sch_decode_0      ,
output decode_t     o_sch_decode_1
);

localparam int PkgWidth = $bits(i_dque_sch_decode_0);

wire buf0_en;

wire mux0_sel;
wire mux1_sel;

wire valid0_ctrl;
wire valid1_ctrl;

decode_t buf1_data_in;
decode_t buf2_data_in;

decode_t buf0_data_out;
decode_t buf1_data_out;
decode_t buf2_data_out;

decode_t mux0_data;
decode_t mux1_data;

register #(.WIDTH(PkgWidth)) buf0 (
    .clk  (i_clk              ),
    .rst_n(i_rstn             ),
    .en   (buf0_en            ),
    .D    (i_dque_sch_decode_1),
    .Q    (buf0_data_out      )
);

register #(.WIDTH(PkgWidth)) buf1 (
    .clk  (i_clk        ),
    .rst_n(i_rstn       ),
    .en   ('1           ),
    .D    (buf1_data_in ),
    .Q    (buf1_data_out)
);

register #(.WIDTH(PkgWidth)) buf2 (
    .clk  (i_clk        ),
    .rst_n(i_rstn       ),
    .en   ('1           ),
    .D    (buf2_data_in ),
    .Q    (buf2_data_out)
);

// IGNORE THIS Debug signal
funct_e     db_buf0_funct    = buf0_data_out.funct;
logic [4:0] db_buf0_rd_addr  = buf0_data_out.rd_addr;
logic [4:0] db_buf0_rs1_addr = buf0_data_out.rs1_addr;
logic [4:0] db_buf0_rs2_addr = buf0_data_out.rs2_addr;
logic       db_buf0_valid    = buf0_data_out.valid;

funct_e     db_mux0_funct    = mux0_data.funct;
logic [4:0] db_mux0_rd_addr  = mux0_data.rd_addr;
logic [4:0] db_mux0_rs1_addr = mux0_data.rs1_addr;
logic [4:0] db_mux0_rs2_addr = mux0_data.rs2_addr;
logic       db_mux0_valid    = mux0_data.valid;

funct_e     db_mux1_funct    = mux1_data.funct;
logic [4:0] db_mux1_rd_addr  = mux1_data.rd_addr;
logic [4:0] db_mux1_rs1_addr = mux1_data.rs1_addr;
logic [4:0] db_mux1_rs2_addr = mux1_data.rs2_addr;
logic       db_mux1_valid    = mux1_data.valid;

// Debug signal end

always_comb begin : proc_signal_forwarding
    buf1_data_in.funct    = mux0_data.funct              ;
    buf1_data_in.instr_op = mux0_data.instr_op           ;
    buf1_data_in.rs1_addr = mux0_data.rs1_addr           ;
    buf1_data_in.rs2_addr = mux0_data.rs2_addr           ;
    buf1_data_in.rd_addr  = mux0_data.rd_addr            ;
    buf1_data_in.imm      = mux0_data.imm                ;
    buf1_data_in.pc       = mux0_data.pc                 ;
    buf1_data_in.use_imm  = mux0_data.use_imm            ;
    buf1_data_in.use_pc   = mux0_data.use_pc             ;
    buf1_data_in.ecall    = mux0_data.ecall              ;
    buf1_data_in.ebreak   = mux0_data.ebreak             ;
    buf1_data_in.prd_en   = mux0_data.prd_en             ;
    buf1_data_in.wr_en    = mux0_data.wr_en              ;
    buf1_data_in.valid    = mux0_data.valid & valid0_ctrl;

    buf2_data_in.funct    = mux1_data.funct              ;
    buf2_data_in.instr_op = mux1_data.instr_op           ;
    buf2_data_in.rs1_addr = mux1_data.rs1_addr           ;
    buf2_data_in.rs2_addr = mux1_data.rs2_addr           ;
    buf2_data_in.rd_addr  = mux1_data.rd_addr            ;
    buf2_data_in.imm      = mux1_data.imm                ;
    buf2_data_in.pc       = mux1_data.pc                 ;
    buf2_data_in.use_imm  = mux1_data.use_imm            ;
    buf2_data_in.use_pc   = mux1_data.use_pc             ;
    buf2_data_in.ecall    = mux1_data.ecall              ;
    buf2_data_in.ebreak   = mux1_data.ebreak             ;
    buf2_data_in.prd_en   = mux1_data.prd_en             ;
    buf2_data_in.wr_en    = mux1_data.wr_en              ;
    buf2_data_in.valid    = mux1_data.valid & valid1_ctrl;
end

logic [1:0][PkgWidth-1:0] mux0_in;
logic [1:0][PkgWidth-1:0] mux1_in;

assign mux0_in[0] = buf0_data_out;
assign mux0_in[1] = i_dque_sch_decode_0;
assign mux1_in[0] = i_dque_sch_decode_0;
assign mux1_in[1] = i_dque_sch_decode_1;

mux #(.WIDTH(PkgWidth), .NUM_INPUT(2)) mux0 (
    .sel   (mux0_sel ),
    .i_mux (mux0_in  ),
    .o_mux (mux0_data)
);

mux #(.WIDTH(PkgWidth), .NUM_INPUT(2)) mux1 (
    .sel   (mux1_sel ),
    .i_mux (mux1_in  ),
    .o_mux (mux1_data)
);

schedule_control control_unit (
    .i_clk         (i_clk                 ),
    .i_rstn        (i_rstn                ),
    .i_dque_empty  (~i_dque_sch_ready     ),
    //
    .i_valid_0      (mux0_data.valid      ),
    .i_funct_0      (mux0_data.funct      ),
    .i_opcode_0     (mux0_data.instr_op   ),
    .i_use_imm_0    (mux0_data.use_imm    ),
    .i_rd_addr_0    (mux0_data.rd_addr    ),
    .i_rs1_addr_0   (mux0_data.rs1_addr   ),
    .i_rs2_addr_0   (mux0_data.rs2_addr   ),
    //
    .i_valid_1      (mux0_data.valid      ),
    .i_funct_1      (mux1_data.funct      ),
    .i_opcode_1     (mux1_data.instr_op   ),
    .i_use_imm_1    (mux1_data.use_imm    ),
    .i_use_pc_1     (mux1_data.use_pc     ),
    .i_rd_addr_1    (mux1_data.rd_addr    ),
    .i_rs1_addr_1   (mux1_data.rs1_addr   ),
    .i_rs2_addr_1   (mux1_data.rs2_addr   ),
    //
    .i_pre_funct_0  (buf1_data_out.funct  ),
    .i_pre_funct_1  (buf2_data_out.funct  ),
    .i_pre_rd_addr_0(buf1_data_out.rd_addr),
    .i_pre_rd_addr_1(buf2_data_out.rd_addr),
    .i_pre_valid_0  (buf1_data_out.valid  ),
    .i_pre_valid_1  (buf2_data_out.valid  ),
    .o_tmp_buf_en   (buf0_en              ),
    .o_mux0_sel     (mux0_sel             ),
    .o_mux1_sel     (mux1_sel             ),
    .o_valid0_ctrl  (valid0_ctrl          ),
    .o_valid1_ctrl  (valid1_ctrl          ),
    .o_request      (o_sch_dque_request   )
);

assign o_sch_decode_0 = buf1_data_out;
assign o_sch_decode_1 = buf2_data_out;



// ========================= Debug ===========================================
debug_instr     sche_db_instr_instr1;
register_idx    sche_db_rs1_addr_instr1;
register_idx    sche_db_rs2_addr_instr1;
register_idx    sche_db_rd_addr_instr1;
logic [31:0]    sche_db_rs1_data_instr1;
logic [31:0]    sche_db_rs2_data_instr1;
logic [31:0]    sche_db_rd_data_instr1;
logic [31:0]    sche_db_imm_instr1;
logic [31:0]    sche_db_pc_instr1;
logic [31:0]    sche_db_instr_asm_instr1;
logic           sche_db_wr_en_instr1;
logic           sche_db_valid_instr1;
logic           sche_db_prd_en_instr1;
logic           sche_db_is_instr2_instr1;

debug_instr     sche_db_instr_instr2;
register_idx    sche_db_rs1_addr_instr2;
register_idx    sche_db_rs2_addr_instr2;
register_idx    sche_db_rd_addr_instr2;
logic [31:0]    sche_db_rs1_data_instr2;
logic [31:0]    sche_db_rs2_data_instr2;
logic [31:0]    sche_db_rd_data_instr2;
logic [31:0]    sche_db_imm_instr2;
logic [31:0]    sche_db_pc_instr2;
logic [31:0]    sche_db_instr_asm_instr2;
logic           sche_db_wr_en_instr2;
logic           sche_db_valid_instr2;
logic           sche_db_prd_en_instr2;
logic           sche_db_is_instr2_instr2;

assign sche_db_instr_instr1      = o_sch_decode_0.debug_data.db_instr;
assign sche_db_rs1_addr_instr1   = o_sch_decode_0.debug_data.db_rs1_addr;
assign sche_db_rs2_addr_instr1   = o_sch_decode_0.debug_data.db_rs2_addr;
assign sche_db_rd_addr_instr1    = o_sch_decode_0.debug_data.db_rd_addr;
assign sche_db_rs1_data_instr1   = o_sch_decode_0.debug_data.db_rs1_data;
assign sche_db_rs2_data_instr1   = o_sch_decode_0.debug_data.db_rs2_data;
assign sche_db_rd_data_instr1    = o_sch_decode_0.debug_data.db_rd_data;
assign sche_db_imm_instr1        = o_sch_decode_0.debug_data.db_imm;
assign sche_db_pc_instr1         = o_sch_decode_0.debug_data.db_pc;
assign sche_db_instr_asm_instr1  = o_sch_decode_0.debug_data.db_instr_asm;
assign sche_db_wr_en_instr1      = o_sch_decode_0.debug_data.db_wr_en;
assign sche_db_valid_instr1      = o_sch_decode_0.debug_data.db_valid;
assign sche_db_prd_en_instr1     = o_sch_decode_0.debug_data.db_prd_en;
assign sche_db_is_instr2_instr1  = o_sch_decode_0.debug_data.db_is_instr2;


assign sche_db_instr_instr2      = o_sch_decode_1.debug_data.db_instr;
assign sche_db_rs1_addr_instr2   = o_sch_decode_1.debug_data.db_rs1_addr;
assign sche_db_rs2_addr_instr2   = o_sch_decode_1.debug_data.db_rs2_addr;
assign sche_db_rd_addr_instr2    = o_sch_decode_1.debug_data.db_rd_addr;
assign sche_db_rs1_data_instr2   = o_sch_decode_1.debug_data.db_rs1_data;
assign sche_db_rs2_data_instr2   = o_sch_decode_1.debug_data.db_rs2_data;
assign sche_db_rd_data_instr2    = o_sch_decode_1.debug_data.db_rd_data;
assign sche_db_imm_instr2        = o_sch_decode_1.debug_data.db_imm;
assign sche_db_pc_instr2         = o_sch_decode_1.debug_data.db_pc;
assign sche_db_instr_asm_instr2  = o_sch_decode_1.debug_data.db_instr_asm;
assign sche_db_wr_en_instr2      = o_sch_decode_1.debug_data.db_wr_en;
assign sche_db_valid_instr2      = o_sch_decode_1.debug_data.db_valid;
assign sche_db_prd_en_instr2     = o_sch_decode_1.debug_data.db_prd_en;
assign sche_db_is_instr2_instr2  = o_sch_decode_1.debug_data.db_is_instr2;

endmodule: schedule_unit















module schedule_control (
input  logic          i_clk          ,
input  logic          i_rstn         ,
input  logic          i_dque_empty   ,
// Function 0
input  logic          i_valid_0       ,
input  funct_e        i_funct_0       ,
input  operator_e     i_opcode_0      ,
input  logic          i_use_imm_0     ,
input  logic    [4:0] i_rd_addr_0     ,
input  logic    [4:0] i_rs1_addr_0    ,
input  logic    [4:0] i_rs2_addr_0    ,
// Function 1
input  logic          i_valid_1       ,
input  funct_e        i_funct_1       ,
input  operator_e     i_opcode_1      ,
input  logic          i_use_imm_1     ,
input  logic          i_use_pc_1     ,
input  logic    [4:0] i_rd_addr_1     ,
input  logic    [4:0] i_rs1_addr_1    ,
input  logic    [4:0] i_rs2_addr_1    ,
//
input  funct_e        i_pre_funct_0   ,
input  funct_e        i_pre_funct_1   ,
input  logic    [4:0] i_pre_rd_addr_0 ,
input  logic    [4:0] i_pre_rd_addr_1 ,
input  logic          i_pre_valid_0   ,
input  logic          i_pre_valid_1   ,
//
//
output logic          o_tmp_buf_en   ,
output logic          o_mux0_sel     ,
output logic          o_mux1_sel     ,
output logic          o_valid0_ctrl  ,
output logic          o_valid1_ctrl  ,
output logic          o_request
);


// --------------------- FINITE STATE MACHINE & CONTROL SIGNAL ---------------------
typedef enum logic [1:0] {INIT = 2'b00 , WT_TMP = 2'b01, W_TMP = 2'b10 } sche_e;

sche_e  current_state;
sche_e  next_state;
logic   stall;
logic   hold;


always @(posedge i_clk, negedge i_rstn) begin: proc_state_updating
    if (!i_rstn)        current_state <= INIT;
    else                current_state <= next_state;
end

always_comb begin
        case(current_state)
            INIT:    if(!(hold | i_dque_empty))             next_state  = WT_TMP;
                     else if(hold & i_dque_empty)           next_state  = W_TMP;
                     else                                   next_state  = INIT;

            WT_TMP:  if(~stall & hold & ~i_dque_empty)      next_state  = W_TMP;
                     else                                   next_state  = WT_TMP;

            W_TMP:   if((~stall & (hold | i_dque_empty)))   next_state  = WT_TMP;
                     else                                   next_state  = W_TMP;

            default: next_state  = INIT;
        endcase
end

logic INIT_stage;
logic WT_TMP_stage;
logic W_TMP_stage;


assign INIT_stage   = (current_state == INIT  );
assign WT_TMP_stage = (current_state == WT_TMP);
assign W_TMP_stage  = (current_state == W_TMP );


assign o_request     = (INIT_stage   & ~i_dque_empty) |
                       (WT_TMP_stage & ~stall & ~i_dque_empty) |
                       (W_TMP_stage  & ~stall & ~hold & ~i_dque_empty);

assign o_valid0_ctrl = (INIT_stage   & ~i_dque_empty) |
                       (WT_TMP_stage & ~stall & ~i_dque_empty) |
                       (W_TMP_stage  & ~stall);

assign o_valid1_ctrl = (INIT_stage & ~i_dque_empty & ~hold) |
                       (WT_TMP_stage & ~stall & ~hold & ~i_dque_empty) |
                       (W_TMP_stage & ~stall & ~hold & ~i_dque_empty);

assign o_tmp_buf_en  = (INIT_stage   & ~i_dque_empty &  hold) |
                       (WT_TMP_stage & ~stall &  hold & ~i_dque_empty) |
                       (W_TMP_stage  & ~stall & ~hold & ~i_dque_empty);


assign o_mux0_sel = INIT_stage | WT_TMP_stage;
assign o_mux1_sel = INIT_stage | WT_TMP_stage;



// ------------------------------- OPCODE INDICATIONn ------------------------
logic       _ALU_0  , _ALU_1;     // Indicate funct == ALU
logic       _LOAD_0 , _LOAD_1;    // Indicate funct == LOAD
logic       _STORE_0, _STORE_1;   // Indicate funct == STORE
logic       _CTRL_0 , _CTRL_1;   // Indicate funct == CTRL

logic       rd_rs1_eq;      // when rs1_instr2 == rd_instr1
logic       rd_rs2_eq;      // when rs2_instr2 == rd_instr1
logic       rd_rd_eq ;      // when rd_instr2  == rd_instr1


assign  rd_rs1_eq  =  ~|(i_rd_addr_0 ^ i_rs1_addr_1) & ~i_use_pc_1;   // rs1_instr2 == rd_instr1
assign  rd_rs2_eq  =  ~|(i_rd_addr_0 ^ i_rs2_addr_1) & ~i_use_imm_1;  // rs2_instr2 == rd_instr1

// Reserved
assign  rd_rd_eq   =  ~|(i_rd_addr_0 ^ i_rd_addr_1 );                 // rd_instr2  == rd_instr1


assign _ALU_0   = (i_funct_0 == ALU       );
assign _LOAD_0  = (i_funct_0 == LOAD      );
assign _STORE_0 = (i_funct_0 == STORE     );
assign _CTRL_0  = (i_funct_0 == CTRL_TRNSF);

assign _ALU_1   = (i_funct_1 == ALU       );
assign _LOAD_1  = (i_funct_1 == LOAD      );
assign _STORE_1 = (i_funct_1 == STORE     );
assign _CTRL_1  = (i_funct_1 == CTRL_TRNSF);


// =============================== HOLD cases ========================
logic j_type_1;
logic both_lsu;         // Both instructions are LOAD/STORE
logic both_branch;      // Both instructions are BRANCH
logic load_alu_depend;
logic alu_load_depend;
logic alu_alu_depend;
logic alu_branch_depend;
logic lsu_branch_depend;


// Case 1: Both Instruction are Loiad and Store
assign j_type_1  = (i_funct_1 == CTRL_TRNSF) &  (i_opcode_1 == JAL) ;

assign both_branch       = (_CTRL_0 & _CTRL_1 );
assign both_lsu          = (_LOAD_0 | _STORE_0) & (_LOAD_1 | _STORE_1) ;
assign load_alu_depend   = (_LOAD_0 & _ALU_1  ) & (rd_rs1_eq | rd_rs2_eq);

assign alu_load_depend   = (_ALU_0  & _LOAD_1 ) &  rd_rs1_eq |               // Load only use RS1 of instr1
                           (_ALU_0  & _STORE_1) & (rd_rs1_eq |  rd_rs2_eq );   // Store uses both

assign alu_alu_depend    = (_ALU_0  & _ALU_1  ) & (rd_rs1_eq |  rd_rs2_eq);
assign alu_branch_depend = (_ALU_0  & _CTRL_1 ) & (rd_rs1_eq | (rd_rs2_eq & ~j_type_1));
assign lsu_branch_depend = (_LOAD_0 & _CTRL_1 ) & (rd_rs1_eq | (rd_rs2_eq & ~j_type_1));


assign hold = both_lsu | both_branch | load_alu_depend | alu_load_depend |
              alu_alu_depend | alu_branch_depend | lsu_branch_depend;




logic [4:0] pre_rd_LOAD;
logic       pre_LOAD_0;
logic       pre_LOAD_1;

assign pre_LOAD_0  = (i_pre_funct_0 == LOAD);
assign pre_LOAD_1  = (i_pre_funct_1 == LOAD);

assign    pre_rd_LOAD = ({5{(pre_LOAD_0 & i_pre_valid_0)}} & i_pre_rd_addr_0 |
                         {5{(pre_LOAD_1 & i_pre_valid_1)}} & i_pre_rd_addr_1 );


assign    stall      = (((pre_rd_LOAD == i_rs1_addr_0)  & (i_rs1_addr_0 != 0) & i_valid_0)  |
                        ((pre_rd_LOAD == i_rs2_addr_0)  & (i_rs2_addr_0 != 0) & i_valid_0)) |

                        (((pre_rd_LOAD == i_rs1_addr_1) & (i_rs1_addr_1 != 0) & i_valid_1)  |
                        ( (pre_rd_LOAD == i_rs2_addr_1) & (i_rs2_addr_1 != 0) & i_valid_1)) & ~hold;


endmodule: schedule_control




