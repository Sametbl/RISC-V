module instr_fetch(
  input  logic           i_clk,
  input  logic           i_rst_n,
  input  logic    [31:0] i_current_pc,
  output logic    [31:0] o_pc,             // base PC passes through entire pipeline
  output logic    [63:0] o_instr,
  output logic    [1:0]  o_instr_vld
);

logic [63:0] instr_cache_dat;
logic        cache_vld;

instruction_cache    aqua_instruction_memory (
            .i_clk             (i_clk          ),
            .i_rst_n           (i_rst_n        ),
            .i_instr_cache_addr(i_current_pc   ),
            .o_cache_vld       (cache_vld      ),
            .o_instr_cache_dat (instr_cache_dat) // 64-bit output for two instructions
);


// Validation Unit
register #(.WIDTH(32)) register_delay (
            .clk  (i_clk       ),
            .rst_n(i_rst_n     ),
            .en   (1'b1        ),
            .D    (i_current_pc),
            .Q    (o_pc        )
);

assign o_instr        = instr_cache_dat;
//assign o_instr_vld[0] = cache_vld & ~o_pc[2]; // Base PC must be divisible by 8
assign o_instr_vld[0] = cache_vld;
assign o_instr_vld[1] = cache_vld;

endmodule : instr_fetch


