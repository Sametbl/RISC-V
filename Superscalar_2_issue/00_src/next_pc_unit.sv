module next_pc_unit(
  input  logic        i_clk          ,
  input  logic        i_rst_n        ,
  input  logic        i_pc_buff_en   ,
  input  branch_t     i_bru_prd_pkg  ,   // Pacge from BRU to prediction
  output logic [31:0] o_pc           ,
  output logic        o_br_miss         // Branch Misprediciton

);

logic        br_miss_t;
logic        br_miss_nt;
logic        prd_br_taken;
logic        br_update_en;
logic        br_update_valid;
logic        br_update_taken;
logic [31:0] br_update_pc;
logic [31:0] br_update_target;

assign br_update_en     = i_bru_prd_pkg.update_en;
assign br_update_valid  = i_bru_prd_pkg.valid;
assign br_update_pc     = i_bru_prd_pkg.pc_lookup;
assign br_update_taken  = i_bru_prd_pkg.taken;
assign br_update_target = i_bru_prd_pkg.target;
/* verilator lint_off UNOPTFLAT */

logic [31:0] next_pc;
logic [31:0] prd_br_target;

branch_unit  branch_prediction  (
          .i_clk             (i_clk           ),
          .i_rst_n           (i_rst_n         ),
          .i_br_update_en    (br_update_en    ),
          .i_br_update_valid (br_update_valid ),
          .i_br_update_taken (br_update_taken ),
          .i_br_update_pc    (br_update_pc    ),
          .i_br_update_target(br_update_target),
          .i_current_pc      (o_pc            ),
          .o_prd_target      (prd_br_target   ),
          .o_prd_taken       (prd_br_taken    ),
          .o_prd_miss_t      (br_miss_t       ),
          .o_prd_miss_nt     (br_miss_nt      )
);


logic [3:0][31:0] pc_mux_data;
logic [31:0]      pc_plus_8;
logic [31:0]      pc_before_branch;
logic [1:0]       select_PC;


assign pc_plus_8       = o_pc + 32'd8;

assign pc_mux_data[0]  = pc_plus_8;         // PC + 8
assign pc_mux_data[1]  = br_update_target;  // Target directly from ALU/BRU
assign pc_mux_data[2]  = pc_before_branch;  // PC restore when branch missed
assign pc_mux_data[3]  = prd_br_target;     // BTB_target_PC

// select_PC = 2'b00:     next_PC = PC + 4           (default)
// select_PC = 2'b01:     next_PC = alu_PC           (When "Not taken" mis-prediction)
// select_PC = 2'b10:     next_PC = PC_before_branch (When "Taken" misprediction)
// select_PC = 2'b11:     next_PC = BTB_PC           (When BTB hit and taken)
assign select_PC[0] = (prd_br_taken) |(br_miss_nt);
assign select_PC[1] = (prd_br_taken) |(br_miss_t);


mux #(.WIDTH(32), .NUM_INPUT(4)) mux_PC_select(
  .sel  (select_PC  ),
  .i_mux(pc_mux_data),
  .o_mux(next_pc    )          // Assign the "next_pc"
);
/* verilator lint_on UNOPTFLAT */


register #(.WIDTH(32))   PC_reg  (
        .clk  (i_clk       ),
        .rst_n(i_rst_n     ),
        .en   (i_pc_buff_en),
        .D    (next_pc     ),
        .Q    (o_pc        )
);


register #(.WIDTH(32))   PC_restore  (
        .clk  (i_clk           ),
        .rst_n(i_rst_n         ),
        .en   (prd_br_taken    ),
        .D    (pc_plus_8       ),
        .Q    (pc_before_branch)
);


assign o_br_miss = ~br_miss_t & ~br_miss_nt;    // ACTIVE LOW

endmodule
