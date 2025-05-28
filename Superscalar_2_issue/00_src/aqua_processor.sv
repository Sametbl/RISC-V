import aqua_pkg::*;

module  aqua_processor(
    input   logic          clk_i,
    input   logic          rst_n,
    input   logic  [31:0]  i_sw,
    output  logic  [31:0]  o_hex [8],
    output  logic  [31:0]  o_ledg,
    output  logic  [31:0]  o_ledr,
    output  logic  [31:0]  o_lcd
);


debug_t abt_alu_debug;
debug_t abt_bru_debug;
debug_t abt_agu_debug;




//------------------------- FETCH STATE ---------------------------
branch_t    br_update_pkg;

logic [31:0] pc_IF_ID;
logic [31:0] current_pc;
logic [63:0] instr;

logic [1:0]  instr_vld;
logic        branch_miss;
branch_t     bru_prd_pkg_buff;
// Branch Prediction
// (PC+8) or Branch_target selection
next_pc_unit     next_pc_generator (
        .i_clk          (clk_i           ),
        .i_rst_n        (rst_n           ),
        .i_pc_buff_en   (1'b1            ),     // dque_fbuff_busyEnable PC register
        .i_bru_prd_pkg  (bru_prd_pkg_buff),     // Pacge from BRU to prediction
        .o_pc           (current_pc      ),
        .o_br_miss      (branch_miss     )      // ACTIVE LOW
);


// Fetch 2 instructions using "next_pc"
// Validate the instructions
instr_fetch   fetch (
        .i_clk       (clk_i              ),
        .i_rst_n     (rst_n & branch_miss),
        .i_current_pc(current_pc         ),
        .o_pc        (pc_IF_ID           ),
        .o_instr     (instr              ),
        .o_instr_vld (instr_vld          )
);




//------------------------- DECODE STATE ---------------------------
decode_t [1:0] dcd_dque_pkg;
decode_t [1:0] dque_sch_pkg;
logic          sch_dque_request;
logic          dque_fbuff_busy;
logic          dque_sch_ready;
logic          dque_sch_ack;

decoder  decoder_instr1  (
        .i_instr2_indicator(1'b0           ),
        .i_pc              (pc_IF_ID       ),
        .i_instr           (instr[31:0]    ),
        .i_instr_vld       (instr_vld[0]   ),
        .o_decode          (dcd_dque_pkg[0])
);


decoder  decoder_instr2  (
        .i_instr2_indicator(1'b1           ),
        .i_pc              (pc_IF_ID       ),
        .i_instr           (instr[63:32]   ),
        .i_instr_vld       (instr_vld[1]   ),
        .o_decode          (dcd_dque_pkg[1])
);



decode_queue   FIFO_queue (
    .i_clk             (clk_i              ),
    .i_rstn            (rst_n & branch_miss),
    .i_sch_dque_request(sch_dque_request   ),
    .i_dec_dque_data   (dcd_dque_pkg       ),
    .o_decode          (dque_sch_pkg       ),
    .o_dque_sch_ack    (dque_sch_ack       ),
    .o_dque_sch_ready  (dque_sch_ready     ),
    .o_dque_fbuff_busy (dque_fbuff_busy    )
);



//------------------------- ISSUE STATE ---------------------------
decode_t           instr1_pkg;
decode_t           instr2_pkg;
rs_addr_t          rs_addr;        // Source registers of both instructions
rs_data_t          rs_data;
forwarding_t       forwarding_select;
alu_issue_t        abt_alu_pkg;
bru_issue_t        abt_bru_pkg;
agu_issue_t        abt_agu_pkg;
writeback_t        writeback_pkg;

mem_req_t          agu_lsu_pkg;
uv_buff_t  [2:0]   alu_buff;
uv_buff_t  [2:0]   bru_buff;
uv_buff_t  [1:0]   mem_buff;


schedule_unit   instruction_agent (
        .i_clk              (clk_i              ),
        .i_rstn             (rst_n & branch_miss),
        .i_dque_sch_decode_0(dque_sch_pkg[0]    ),
        .i_dque_sch_decode_1(dque_sch_pkg[1]    ),
        .i_dque_sch_ack     (dque_sch_ack       ),
        .i_dque_sch_ready   (dque_sch_ready     ),
        .o_sch_dque_request (sch_dque_request   ),
        .o_sch_decode_0     (instr1_pkg         ),
        .o_sch_decode_1     (instr2_pkg         )
);


assign rs_addr.rs1_addr_instr1 = instr1_pkg.rs1_addr;
assign rs_addr.rs2_addr_instr1 = instr1_pkg.rs2_addr;
assign rs_addr.rs1_addr_instr2 = instr2_pkg.rs1_addr;
assign rs_addr.rs2_addr_instr2 = instr2_pkg.rs2_addr;

regfile   register_file  (
        .i_clk       (clk_i        ),
        .i_rst_n     (rst_n        ),
        .i_sch_rf_pkg(rs_addr      ),
        .i_wb_rf_pkg (writeback_pkg),
        .o_rf_abt_pkg(rs_data      )
);


forwarding_unit   forwarding (
        .i_sch_fwd_pkg   (rs_addr         ),
        .i_alu_buff_1_pkg(alu_buff[0]     ),
        .i_alu_buff_2_pkg(alu_buff[1]     ),
        .i_alu_buff_3_pkg(alu_buff[2]     ),
        .i_bru_buff_1_pkg(bru_buff[0]     ),
        .i_bru_buff_2_pkg(bru_buff[1]     ),
        .i_bru_buff_3_pkg(bru_buff[2]     ),
        .i_mem_buff_1_pkg(mem_buff[0]     ),
        .i_mem_buff_2_pkg(mem_buff[1]     ),
        .o_fwd_abt_pkg   (forwarding_select)
);


arbitrator     arbitrating (
        .i_clk                   (clk_i              ),
        .i_rst_n                 (rst_n & branch_miss),
        .i_buff_en               (1'b1               ),
        .i_invalidate            (1'b0               ),
        .i_sch_arb_instr1        (instr1_pkg         ),   // Instruction 1 package
        .i_sch_arb_instr2        (instr2_pkg         ),   // Instruction 2 package
        .i_rf_arb_rs_data        (rs_data            ),   // Regfile data
        .i_fw_arb_pkg            (forwarding_select  ),   // Forwarding select signal and data
        .o_arb_alu_pkg           (abt_alu_pkg        ),   // Package send to ALU
        .o_arb_bru_pkg           (abt_bru_pkg        ),   // Package send to BRU
        .o_arb_agu_pkg           (abt_agu_pkg        ),   // Package send to AGU

        .o_abt_alu_debug         (abt_alu_debug      ),         // Remove this when done debugging
        .o_abt_bru_debug         (abt_bru_debug      ),         // Remove this when done debugging
        .o_abt_agu_debug         (abt_agu_debug      )          // Remove this when done debugging

);


//------------------------- EXECUTE STATE ---------------------------
logic  bru_flush_instr2;
assign bru_flush_instr2 = ~bru_buff[1].is_instr2 & bru_prd_pkg_buff.taken & bru_prd_pkg_buff.valid;

alu    ex_alu     (.i_abt_alu_pkg (abt_alu_pkg),
                   .o_alu_buff_pkg(alu_buff[0]),
                   .i_abt_alu_debug(abt_alu_debug)                  // Remove this when done debugging
 );

bru    ex_alu_bru (.i_abt_bru_pkg (abt_bru_pkg  ),
                   .o_bru_buff_pkg(bru_buff[0]  ),
                   .o_bru_prd_pkg (br_update_pkg),
                   .i_abt_bru_debug(abt_bru_debug)                  // Remove this when done debugging

);


agu    ex_agu     (
        .i_abt_agu_pkg(abt_agu_pkg),
        .o_agu_lsu_pkg(agu_lsu_pkg),
        .i_abt_agu_debug(abt_agu_debug)                  // Remove this when done debugging

);


register #(.WIDTH($bits(br_update_pkg)))  br_prd_pkd_buff(
        .clk  (clk_i             ),
        .rst_n(rst_n             ),
        .en   (1'b1              ),
        .D    (br_update_pkg     ),
        .Q    (bru_prd_pkg_buff)
);
// debug prd_en
logic prd_en_bru_prd_pkg_buff;
assign prd_en_bru_prd_pkg_buff = bru_prd_pkg_buff.update_en;
ex_buffer  alu_buff2 (.i_clk  (clk_i        ),
                      .i_rst_n(rst_n        ),
                      .en     (1'b1         ),
                      .uv_buff_D(alu_buff[0]),
                      .uv_buff_Q(alu_buff[1])
);

ex_buffer  bru_buff2 (.i_clk    (clk_i      ),
                      .i_rst_n  (rst_n      ),
                      .en       (1'b1       ),
                      .uv_buff_D(bru_buff[0]),
                      .uv_buff_Q(bru_buff[1])
);

//------------------------- MEMORY ACCESS STATE ---------------------------
lsu  mem_buff1(
        .i_clk        (clk_i            ),
        .i_rst_n      (rst_n            ),
      //  .i_enable     (~bru_flush_instr2),
        .i_agu_lsu_pkg(agu_lsu_pkg      ),
        .i_sw         (i_sw             ),
        .o_hex        (o_hex            ),
        .o_ledg       (o_ledg           ),
        .o_ledr       (o_ledr           ),
        .o_lcd        (o_lcd            ),
        .o_lsu_buff   (mem_buff[0]      )
);

ex_buffer  alu_buff3 (.i_clk    (clk_i            ),
                      .i_rst_n  (rst_n            ),
                      .en       (~bru_flush_instr2),
                      .uv_buff_D(alu_buff[1]      ),
                      .uv_buff_Q(alu_buff[2]      )
);


ex_buffer  bru_buff3 (.i_clk    (clk_i            ),
                      .i_rst_n  (rst_n            ),
                      .en       (1'b1),
                      .uv_buff_D(bru_buff[1]      ),
                      .uv_buff_Q(bru_buff[2]      )
);

ex_buffer  mem_buff2 (.i_clk    (clk_i            ),
                      .i_rst_n  (rst_n            ),
                      .en       (~bru_flush_instr2),
                      .uv_buff_D(mem_buff[0]      ),
                      .uv_buff_Q(mem_buff[1]      )
);

//------------------------- WRITEBACK STATE ---------------------------
uv_buff_t   wb_instr1_pkg;
uv_buff_t   wb_instr2_pkg;
logic [1:0] sel_instr1;
logic [1:0] sel_instr2;

assign sel_instr1[0] = bru_buff[2].valid & bru_buff[2].wr_en & ~bru_buff[2].is_instr2;
assign sel_instr1[1] = mem_buff[1].valid & mem_buff[1].wr_en & ~mem_buff[1].is_instr2;

assign sel_instr2[0] = bru_buff[2].valid & bru_buff[2].wr_en &  bru_buff[2].is_instr2;
assign sel_instr2[1] = mem_buff[1].valid & mem_buff[1].wr_en &  mem_buff[1].is_instr2;


mux #(.WIDTH($bits(wb_instr1_pkg)), .NUM_INPUT(4)) writeback_instr1 (
       .sel   (sel_instr1),
       .i_mux ({ {$bits(wb_instr2_pkg){1'b0}}, mem_buff[1], bru_buff[2], alu_buff[2] }),
       .o_mux (wb_instr1_pkg)
);

mux #(.WIDTH($bits(wb_instr2_pkg)), .NUM_INPUT(4)) writeback_instr2 (
       .sel   (sel_instr2),
       .i_mux ({ {$bits(wb_instr1_pkg){1'b0}}, mem_buff[1], bru_buff[2], alu_buff[2] }),
       .o_mux (wb_instr2_pkg)
);


assign writeback_pkg.rd_addr_instr1 = wb_instr1_pkg.rd_buff;
assign writeback_pkg.rd_addr_instr2 = wb_instr2_pkg.rd_buff;
assign writeback_pkg.rd_data_instr1 = wb_instr1_pkg.data_buff;
assign writeback_pkg.rd_data_instr2 = wb_instr2_pkg.data_buff;
assign writeback_pkg.wren_instr1    = wb_instr1_pkg.wr_en & wb_instr1_pkg.valid;
assign writeback_pkg.wren_instr2    = wb_instr2_pkg.wr_en & wb_instr2_pkg.valid;
//debug
logic [4:0] rd_addr_db_instr1;
logic [4:0] rd_addr_db_instr2;

logic [31:0] rd_data_db_instr1;
logic [31:0] rd_data_db_instr2;

assign rd_addr_db_instr1 = wb_instr1_pkg.rd_buff;
assign rd_addr_db_instr2 = wb_instr2_pkg.rd_buff;
assign rd_data_db_instr1 = wb_instr1_pkg.data_buff;
assign rd_data_db_instr2 = wb_instr2_pkg.data_buff;

endmodule : aqua_processor





module ex_buffer(
        input   logic      i_clk,
        input   logic      i_rst_n,
        input   logic      en,
        input   uv_buff_t  uv_buff_D,
        output  uv_buff_t  uv_buff_Q
);


logic [31:0] rd_data_D  , rd_data_Q;
logic [4:0]  rd_addr_D  , rd_addr_Q;
logic        wr_en_D    , wr_en_Q;
logic        valid_D    , valid_Q;
logic        is_instr2_D, is_instr2_Q;

assign rd_data_D   = uv_buff_D.data_buff;
assign rd_addr_D   = uv_buff_D.rd_buff;
assign wr_en_D     = uv_buff_D.wr_en;
assign valid_D     = uv_buff_D.valid;
assign is_instr2_D = uv_buff_D.is_instr2;

register        buff_data(.clk(i_clk), .rst_n(i_rst_n), .en(en), .D(rd_data_D),   .Q(rd_data_Q));
D_flip_flop     buff_fwd (.clk(i_clk), .rst_n(i_rst_n), .en(en), .D(wr_en_D),     .Q(wr_en_Q)  );
D_flip_flop     buff_vld (.clk(i_clk), .rst_n(i_rst_n), .en(en), .D(valid_D),     .Q(valid_Q)  );
D_flip_flop     buff_ins (.clk(i_clk), .rst_n(i_rst_n), .en(en), .D(is_instr2_D), .Q(is_instr2_Q));
register #(.WIDTH(5)) buff_addr(
        .clk(i_clk), .rst_n(i_rst_n), .en(en), .D(rd_addr_D), .Q(rd_addr_Q));


assign uv_buff_Q.data_buff =  rd_data_Q;
assign uv_buff_Q.rd_buff   =  rd_addr_Q;
assign uv_buff_Q.wr_en     =  wr_en_Q;
assign uv_buff_Q.valid     =  valid_Q;
assign uv_buff_Q.is_instr2 =  is_instr2_Q;


endmodule : ex_buffer


