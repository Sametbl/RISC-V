import aqua_pkg::*;

module schedule_unit (
    // Inputs
    input  logic     [0:0]  i_clk               ,
    input  logic     [0:0]  i_rstn              ,
    input  logic     [0:0]  i_dque_sch_ready    ,
    input  logic     [0:0]  i_dque_sch_ack      ,
    input  decode_t         i_dque_sch_decode_0 ,
    input  decode_t         i_dque_sch_decode_1 ,
    // Outputs
    output logic     [0:0]  o_sch_dque_request  ,
    output decode_t         o_sch_decode_0      ,
    output decode_t         o_sch_decode_1
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


    decode_t [1:0] mux0_in;
    decode_t [1:0] mux1_in;
    assign mux0_in[0] = buf0_data_out;
    assign mux0_in[1] = i_dque_sch_decode_0;
    assign mux1_in[0] = i_dque_sch_decode_0;
    assign mux1_in[1] = i_dque_sch_decode_1;


    mux #(.WIDTH(PkgWidth), .NUM_INPUT(2)) mux0 (
        .i_mux (mux0_in  ),
        .sel   (mux0_sel ),
        .o_mux (mux0_data)
    );

    mux #(.WIDTH(PkgWidth), .NUM_INPUT(2)) mux1 (
        .i_mux (mux1_in  ),
        .sel   (mux1_sel ),
        .o_mux (mux1_data)
    );

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

//debug
logic [31:0] i_pc_1;
logic [31:0] i_pc_2;
logic [31:0] o_pc_1;
logic [31:0] o_pc_2;

// pc
assign i_pc_1 = i_dque_sch_decode_0.pc;
assign i_pc_2 = i_dque_sch_decode_1.pc;
assign o_pc_1 = o_sch_decode_0.pc;
assign o_pc_2 = o_sch_decode_1.pc;
//operator
operator_e i_op_1;
operator_e i_op_2;

operator_e o_op_1;
operator_e o_op_2;
assign i_op_1 = i_dque_sch_decode_0.instr_op; 
assign i_op_2 = i_dque_sch_decode_1.instr_op; 
assign o_op_1 = o_sch_decode_0.instr_op; 
assign o_op_2 = o_sch_decode_1.instr_op; 
//prd
logic prd_en_1;
logic prd_en_2;
assign prd_en_1 = i_dque_sch_decode_0.prd_en;
assign prd_en_2 = i_dque_sch_decode_1.prd_en;

logic o_prd_en_1;
logic o_prd_en_2;
assign o_prd_en_1 = o_sch_decode_0.prd_en;
assign o_prd_en_2 = o_sch_decode_1.prd_en;
//valid
logic i_valid_1;
logic i_valid_2;
assign i_valid_1 = i_dque_sch_decode_0.valid;
assign i_valid_2 = i_dque_sch_decode_1.valid;

logic o_valid_1;
logic o_valid_2;
assign o_valid_1 = o_sch_decode_0.valid;
assign o_valid_2 = o_sch_decode_1.valid;

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
        buf1_data_in.debug_data    = mux0_data.debug_data;

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
        buf2_data_in.debug_data    = mux1_data.debug_data              ;
    end



    schedule_control control_unit (
        .clk         (i_clk                ),
        .rstn        (i_rstn               ),
        .dque_empty  (~i_dque_sch_ready    ),
        //
        .valid0      (mux0_data.valid      ),
        .funct0      (mux0_data.funct      ),
        .opcode0     (mux0_data.instr_op   ),
        .use_imm0    (mux0_data.use_imm    ),
        .rd_addr0    (mux0_data.rd_addr    ),
        .rs1_addr0   (mux0_data.rs1_addr   ),
        .rs2_addr0   (mux0_data.rs2_addr   ),
        //
        .funct1      (mux1_data.funct      ),
        .opcode1     (mux1_data.instr_op   ),
        .use_imm1    (mux1_data.use_imm    ),
        .rd_addr1    (mux1_data.rd_addr    ),
        .rs1_addr1   (mux1_data.rs1_addr   ),
        .rs2_addr1   (mux1_data.rs2_addr   ),
        .valid1      (mux0_data.valid      ),
        //
        .pre_funct0  (buf1_data_out.funct  ),
        .pre_funct1  (buf2_data_out.funct  ),
        .pre_rd_addr0(buf1_data_out.rd_addr),
        .pre_rd_addr1(buf2_data_out.rd_addr),
        .pre_valid0  (buf1_data_out.valid  ),
        .pre_valid1  (buf2_data_out.valid  ),
        .tmp_buf_en  (buf0_en              ),
        .mux0_sel    (mux0_sel             ),
        .mux1_sel    (mux1_sel             ),
        .valid0_ctrl (valid0_ctrl          ),
        .valid1_ctrl (valid1_ctrl          ),
        .request     (o_sch_dque_request   )
    );

    assign o_sch_decode_0 = buf1_data_out;
    assign o_sch_decode_1 = buf2_data_out;










/*
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

assign sche_db_instr_instr1      = buf1_data_in.debug_data.db_instr;
assign sche_db_rs1_addr_instr1   = buf1_data_in.debug_data.db_rs1_addr;
assign sche_db_rs2_addr_instr1   = buf1_data_in.debug_data.db_rs2_addr;
assign sche_db_rd_addr_instr1    = buf1_data_in.debug_data.db_rd_addr;
assign sche_db_rs1_data_instr1   = buf1_data_in.debug_data.db_rs1_data;
assign sche_db_rs2_data_instr1   = buf1_data_in.debug_data.db_rs2_data;
assign sche_db_rd_data_instr1    = buf1_data_in.debug_data.db_rd_data;
assign sche_db_imm_instr1        = buf1_data_in.debug_data.db_imm;
assign sche_db_pc_instr1         = buf1_data_in.debug_data.db_pc;
assign sche_db_instr_asm_instr1  = buf1_data_in.debug_data.db_instr_asm;
assign sche_db_wr_en_instr1      = buf1_data_in.debug_data.db_wr_en;
assign sche_db_valid_instr1      = buf1_data_in.debug_data.db_valid;
assign sche_db_prd_en_instr1     = buf1_data_in.debug_data.db_prd_en;
assign sche_db_is_instr2_instr1  = buf1_data_in.debug_data.db_is_instr2;


assign sche_db_instr_instr2      = buf2_data_in.debug_data.db_instr;
assign sche_db_rs1_addr_instr2   = buf2_data_in.debug_data.db_rs1_addr;
assign sche_db_rs2_addr_instr2   = buf2_data_in.debug_data.db_rs2_addr;
assign sche_db_rd_addr_instr2    = buf2_data_in.debug_data.db_rd_addr;
assign sche_db_rs1_data_instr2   = buf2_data_in.debug_data.db_rs1_data;
assign sche_db_rs2_data_instr2   = buf2_data_in.debug_data.db_rs2_data;
assign sche_db_rd_data_instr2    = buf2_data_in.debug_data.db_rd_data;
assign sche_db_imm_instr2        = buf2_data_in.debug_data.db_imm;
assign sche_db_pc_instr2         = buf2_data_in.debug_data.db_pc;
assign sche_db_instr_asm_instr2  = buf2_data_in.debug_data.db_instr_asm;
assign sche_db_wr_en_instr2      = buf2_data_in.debug_data.db_wr_en;
assign sche_db_valid_instr2      = buf2_data_in.debug_data.db_valid;
assign sche_db_prd_en_instr2     = buf2_data_in.debug_data.db_prd_en;
assign sche_db_is_instr2_instr2  = buf2_data_in.debug_data.db_is_instr2;


*/








endmodule: schedule_unit

module schedule_control (
    input  logic          clk          ,
    input  logic          rstn         ,
    input  logic          dque_empty   ,
    // Function 0
    input  logic          valid0       ,
    input  funct_e        funct0       ,
    input  operator_e     opcode0      ,
    input  logic          use_imm0     ,
    input  logic    [4:0] rd_addr0     ,
    input  logic    [4:0] rs1_addr0    ,
    input  logic    [4:0] rs2_addr0    ,
    // Function 1
    input  logic          valid1       ,
    input  funct_e        funct1       ,
    input  operator_e     opcode1      ,
    input  logic          use_imm1     ,
    input  logic    [4:0] rd_addr1     ,
    input  logic    [4:0] rs1_addr1    ,
    input  logic    [4:0] rs2_addr1    ,
    //
    input  funct_e        pre_funct0   ,
    input  funct_e        pre_funct1   ,
    input  logic    [4:0] pre_rd_addr0 ,
    input  logic    [4:0] pre_rd_addr1 ,
    input  logic          pre_valid0   ,
    input  logic          pre_valid1   ,
    //
    //
    output logic          tmp_buf_en   ,
    output logic          mux0_sel     ,
    output logic          mux1_sel     ,
    output logic          valid0_ctrl  ,
    output logic          valid1_ctrl  ,
    output logic          request
    );

    logic hold;
    logic stall;

    typedef enum logic [1:0] {
        INIT  ,
        WT_TMP,
        W_TMP
    } sche_e;

    sche_e current_state;
    sche_e next_state;

    always @(posedge clk, negedge rstn) begin: proc_state_updating
        if (!rstn) begin
            current_state <= INIT;
        end
        else begin
            current_state <= next_state;
        end
    end

    always_comb begin : proc_fsm
        unique case (current_state)
            INIT: begin
                unique case ({hold, dque_empty})
                    2'b00: begin
                        next_state  = WT_TMP;
                        request     = '1;
                        valid0_ctrl = '1;
                        valid1_ctrl = '1;
                        tmp_buf_en  = '0;
                    end
                    2'b01: begin
                        next_state  = INIT;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    2'b10: begin
                        next_state  = W_TMP;
                        request     = '1;
                        valid0_ctrl = '1;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '1;
                    end
                    2'b11: begin
                        next_state  = INIT;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                endcase
                mux0_sel = '1;
                mux1_sel = '1;
            end
            WT_TMP: begin // case without temporary buffer
                unique case ({stall, hold, dque_empty})
                    3'b000: begin
                        next_state  = WT_TMP;
                        request     = '1;
                        valid0_ctrl = '1;
                        valid1_ctrl = '1;
                        tmp_buf_en  = '0;
                    end
                    3'b001: begin
                        next_state  = WT_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b010: begin
                        next_state  = W_TMP;
                        request     = '1;
                        valid0_ctrl = '1;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '1;
                    end
                    3'b011: begin
                        next_state  = WT_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b100: begin
                        next_state  = WT_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b101: begin
                        next_state  = WT_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b110: begin
                        next_state  = WT_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b111: begin
                        next_state  = WT_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                endcase
                mux0_sel = '1;
                mux1_sel = '1;
            end
            W_TMP: begin
                unique case ({stall, hold, dque_empty})
                    3'b000: begin
                        next_state  = W_TMP;
                        request     = '1;
                        valid0_ctrl = '1;
                        valid1_ctrl = '1;
                        tmp_buf_en  = '1;
                    end
                    3'b001: begin
                        next_state  = WT_TMP;
                        request     = '0;
                        valid0_ctrl = '1;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b010: begin
                        next_state  = WT_TMP;
                        request     = '0;
                        valid0_ctrl = '1;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b011: begin
                        next_state  = WT_TMP;
                        request     = '0;
                        valid0_ctrl = '1;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b100: begin
                        next_state  = W_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b101: begin
                        next_state  = W_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b110: begin
                        next_state  = W_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                    3'b111: begin
                        next_state  = W_TMP;
                        request     = '0;
                        valid0_ctrl = '0;
                        valid1_ctrl = '0;
                        tmp_buf_en  = '0;
                    end
                endcase
                mux0_sel = '0;
                mux1_sel = '0;
            end
        endcase
    end

    logic       _r_type_0, _r_type_1;
    logic       _i_type_0, _i_type_1;
    logic       _s_type_0, _s_type_1;
    logic       _b_type_0, _b_type_1;
    logic       _j_type_0, _j_type_1;
    logic       _u_type_0, _u_type_1;

    logic       rd_rs1_comp;
    logic       rd_rs2_comp;
    logic       rd_rd_comp ;

    logic [4:0] idk_wat_it_is;

    always_comb begin : proc_ctrl_logic
        // _r_type_0  =  ~funct0[2] &  funct0[1] &  funct0[0] & ~opcode0[4] & (~opcode0[3] |   opcode0[3] &  ~opcode0[2] & ~opcode0[1]) & ~use_imm0;
        // _i_type_0  = (~funct0[2] &  funct0[1] &  funct0[0] & ~opcode0[4] & (~opcode0[3] |   opcode0[3] &  ~opcode0[2] & ~opcode0[1]) &  use_imm0) |
        //              (~funct0[2] & ~funct0[1] &  funct0[0] &  opcode0[4] &  ~opcode0[3] & (~opcode0[2] |   opcode0[2] & ~opcode0[1]  & ~opcode0[0])) |
        //              ( funct0[2] & ~funct0[1] & ~funct0[0] &  opcode0[4] &   opcode0[3] &  ~opcode0[2] &  ~opcode0[1] &  opcode0[0]);
        // _s_type    =  ~funct0[2] &  funct0[1] & ~funct0[0] &  opcode0[4] &  ~opcode0[3] &   opcode0[2] & ((opcode0[1] ^  opcode0[0]) | (opcode0[1] & opcode0[0]));
        // _b_type_0  =   funct0[2] & ~funct0[1] & ~funct0[0] & ~opcode0[4] &   opcode0[3] & (~opcode0[2] &   opcode0[1] |  opcode0[2]);
        // _j_type_0  =   funct0[2] & ~funct0[1] & ~funct0[0] &  opcode0[4] &   opcode0[3] &  ~opcode0[2] &  ~opcode0[1] & ~opcode0[0] ;
        // _u_tupe_0  =  ~funct0[2] &  funct0[1] &  funct0[0] &  opcode0[4] &   opcode0[3] &  ~opcode0[2] &   opcode0[1] &  opcode0[0] ;
        //
        // _r_type_1  =  ~funct1[2] &  funct1[1] &  funct1[0] & ~opcode1[4] & (~opcode1[3] |   opcode1[3] &  ~opcode1[2] & ~opcode1[1]) & ~use_imm1;
        // _i_type_1  = (~funct1[2] &  funct1[1] &  funct1[0] & ~opcode1[4] & (~opcode1[3] |   opcode1[3] &  ~opcode1[2] & ~opcode1[1]) &  use_imm1) |
        //              (~funct1[2] & ~funct1[1] &  funct1[0] &  opcode1[4] &  ~opcode1[3] & (~opcode1[2] |   opcode1[2] & ~opcode1[1]  & ~opcode1[0])) |
        //              ( funct1[2] & ~funct1[1] & ~funct1[0] &  opcode1[4] &   opcode1[3] &  ~opcode1[2] &  ~opcode1[1] &  opcode1[0]);
        // _s_type    =  ~funct1[2] &  funct1[1] & ~funct1[0] &  opcode1[4] &  ~opcode1[3] &   opcode1[2] & ((opcode1[1] ^  opcode1[0]) | (opcode1[1] & opcode1[0]));
        // _b_type_1  =   funct1[2] & ~funct1[1] & ~funct1[0] & ~opcode1[4] &   opcode1[3] & (~opcode1[2] &   opcode1[1] |  opcode1[2]);
        // _j_type_1  =   funct1[2] & ~funct1[1] & ~funct1[0] &  opcode1[4] &   opcode1[3] &  ~opcode1[2] &  ~opcode1[1] & ~opcode1[0] ;
        // _u_tupe_1  =  ~funct1[2] &  funct1[1] &  funct1[0] &  opcode1[4] &   opcode1[3] &  ~opcode1[2] &   opcode1[1] &  opcode1[0] ;
        // `define ALU_OP {aqua_pkg::ADD, aqua_pkg::SUB, aqua_pkg::XOR, aqua_pkg::OR,  aqua_pkg::AND,
        //                 aqua_pkg::SLL, aqua_pkg::SRL, aqua_pkg::SRA, aqua_pkg::SLT, aqua_pkg::SLTU}
        `define R_TYPE_OP {ADD, SUB, XOR, OR, AND, SLL, SRL, SRA, SLT, SLTU}
        `define I_TYPE_OP {ADD, SUB, XOR, OR, AND, SLL, SRL, SRA, SLT, SLTU,\
                           LB, LH, LW, LBU, LHU,                            \
                           JALR                                             }
        `define S_TYPE_OP {SB, SH, SW}
        `define B_TYPE_OP {BEQ, BNE, BLT, BGE, BLTU, BGEU}
        `define J_TYPE_OP {JAL}
        `define U_TYPE_OP {LUI, AUIPC}

        _r_type_0 = ((funct0 == ALU       ) & (opcode0 inside `R_TYPE_OP) & ~use_imm0) ? '1 : '0;
        _i_type_0 = ((funct0 == ALU       ) & (opcode0 inside `I_TYPE_OP) &  use_imm0) ? '1 : '0;
        _b_type_0 = ((funct0 == CTRL_TRNSF) & (opcode0 inside `B_TYPE_OP))             ? '1 : '0;
        _s_type_0 = ((funct0 == STORE     ) & (opcode0 inside `S_TYPE_OP))             ? '1 : '0;
        _j_type_0 = ((funct0 == CTRL_TRNSF) & (opcode0 inside `J_TYPE_OP))             ? '1 : '0;
        _u_type_0 = ((funct0 == ALU       ) & (opcode0 inside `U_TYPE_OP))             ? '1 : '0;

        _r_type_1 = ((funct1 == ALU       ) & (opcode1 inside `R_TYPE_OP) & ~use_imm1) ? '1 : '0;
        _i_type_1 = ((funct1 == ALU       ) & (opcode1 inside `I_TYPE_OP) &  use_imm1) ? '1 : '0;
        _b_type_1 = ((funct1 == CTRL_TRNSF) & (opcode1 inside `B_TYPE_OP))             ? '1 : '0;
        _s_type_1 = ((funct1 == STORE     ) & (opcode1 inside `S_TYPE_OP))             ? '1 : '0;
        _j_type_1 = ((funct1 == CTRL_TRNSF) & (opcode1 inside `J_TYPE_OP))             ? '1 : '0;
        _u_type_1 = ((funct1 == ALU       ) & (opcode1 inside `U_TYPE_OP))             ? '1 : '0;

        rd_rs1_comp = ~|(rd_addr0 ^ rs1_addr1);
        rd_rs2_comp = ~|(rd_addr0 ^ rs2_addr1);
        rd_rd_comp  = ~|(rd_addr0 ^ rd_addr1 );

        // hold       =    valid0     &  valid1
        //              &(~funct0[2]  & ~funct1[2]
        //              & (funct0[1]  ^  funct0[0])
        //              & (funct1[1]  ^  funct1[0])
        //              |  funct0[2]  & ~funct0[1]
        //              & ~funct0[0]  &  funct1[2]
        //              & ~funct1[1]  & ~funct1[0]
        //              | ~funct0[2]  &  funct0[0]
        //              & ~funct1[2]  &  funct1[0]
        //              & (funct0[1]  |  funct1[1])
        //              & (rd_rs_comp |  rd_rd_comp));

        case ({funct0, funct1})
            {LOAD      , LOAD      } : hold = '1;
            {LOAD      , STORE     } : hold = '1;
            {LOAD      , ALU       } :
                                       begin case ({_r_type_1, _i_type_1})
                                           2'b01   : hold = rd_rs1_comp;
                                           2'b10   : hold = rd_rs1_comp | rd_rs2_comp;
                                           default : hold = '0;
                                       endcase end
            {LOAD      , CTRL_TRNSF} :
                                       begin case ({_b_type_1, _j_type_1, _i_type_1})
                                           3'b100  : hold = rd_rs1_comp | rd_rs2_comp;
                                           3'b010  : hold = '0;
                                           3'b001  : hold = rd_rs1_comp;
                                           default : hold = '0;
                                       endcase end
            {STORE     , LOAD      } : hold = '1;
            {STORE     , STORE     } : hold = '1;
            {STORE     , ALU       } : hold = '0;
            {STORE     , CTRL_TRNSF} : hold = '0;
            {ALU       , LOAD      } : hold = rd_rs1_comp;
            {ALU       , STORE     } : hold = rd_rs1_comp | rd_rs2_comp;
            {ALU       , ALU       } :
                                       begin case ({_r_type_1, _i_type_1})
                                           2'b10   : hold = rd_rs1_comp | rd_rs2_comp;
                                           2'b01   : hold = rd_rs1_comp              ;
                                           default : hold = '0                       ;
                                       endcase end
            {ALU       , CTRL_TRNSF} :
                                       begin case ({_r_type_0, _i_type_0})
                                           2'b10:
                                               begin case ({_b_type_1, _j_type_1, _i_type_1})
                                                   3'b100  : hold = rd_rs1_comp | rd_rs2_comp;
                                                   3'b001  : hold = rd_rs1_comp              ;
                                                   default : hold = '0                       ;
                                               endcase end
                                           2'b01:
                                               begin case ({_b_type_1, _j_type_1, _i_type_1})
                                                   3'b100  : hold = rd_rs1_comp | rd_rs2_comp;
                                                   3'b001  : hold = rd_rs1_comp              ;
                                                   default : hold = '0                       ;
                                               endcase end
                                           default : hold = '0;
                                       endcase end
            {CTRL_TRNSF, LOAD      } :
                                       begin case ({_b_type_0, _j_type_0, _i_type_0})
                                           3'b010  : hold = rd_rs1_comp;
                                           3'b001  : hold = rd_rs1_comp;
                                           default : hold = '0         ;
                                       endcase end
            {CTRL_TRNSF, STORE     } :
                                       begin case ({_b_type_0, _j_type_0, _i_type_0})
                                           3'b010  : hold = rd_rs1_comp | rd_rs2_comp;
                                           3'b001  : hold = rd_rs1_comp | rd_rs2_comp;
                                           default : hold = '0                       ;
                                       endcase end
            {CTRL_TRNSF, ALU       } :
                                       begin case ({_r_type_1, _i_type_1})
                                           2'b10   :
                                               begin case ({_b_type_0, _j_type_0, _i_type_0})
                                                   3'b010  : hold = rd_rs1_comp | rd_rs2_comp;
                                                   3'b001  : hold = rd_rs1_comp | rd_rs2_comp;
                                                   default : hold = '0                       ;
                                               endcase end
                                           2'b01   :
                                               begin case ({_b_type_0, _j_type_0, _i_type_0})
                                                   3'b010  : hold = rd_rs1_comp;
                                                   3'b001  : hold = rd_rs1_comp;
                                                   default : hold = '0         ;
                                               endcase end
                                           default : hold = '0;
                                       endcase end
            {CTRL_TRNSF, CTRL_TRNSF} : hold = '1;
            default : hold = '0;
        endcase

        idk_wat_it_is = ({5{(~|pre_funct0[2:1] & pre_funct0[0] & pre_valid0)}} & pre_rd_addr0 |
                         {5{(~|pre_funct1[2:1] & pre_funct1[0] & pre_valid1)}} & pre_rd_addr1 );
        stall      = ((~|(idk_wat_it_is ^ rs1_addr0) & |rs1_addr0 & valid0)  |
                      (~|(idk_wat_it_is ^ rs2_addr0) & |rs2_addr0 & valid0)) |
                     ((~|(idk_wat_it_is ^ rs1_addr1) & |rs1_addr1 & valid1)  |
                      (~|(idk_wat_it_is ^ rs2_addr1) & |rs2_addr1 & valid1)) & ~hold;
    end

endmodule: schedule_control
