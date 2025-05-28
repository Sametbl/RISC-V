module instruction_cache(
  input  logic         i_clk,
  input  logic         i_rst_n,
  input  logic [31:0]  i_instr_cache_addr,
  output logic         o_cache_vld,
  output logic [63:0]  o_instr_cache_dat // 64-bit output for two instructions
);

reg [7:0] imem [0: 2**11-1]; // 4 KB memory

initial $readmemh("./../../02_test/test_program/basic_instructions/unconditional_branch.mem", imem);

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)          o_instr_cache_dat <= 64'b0;
    else begin
      // Fetch two instructions
      // Little Endian
      o_instr_cache_dat[7:0]    <= imem[i_instr_cache_addr];
      o_instr_cache_dat[15:8]   <= imem[i_instr_cache_addr + 1];
      o_instr_cache_dat[23:16]  <= imem[i_instr_cache_addr + 2];
      o_instr_cache_dat[31:24]  <= imem[i_instr_cache_addr + 3];

      o_instr_cache_dat[39:32]  <= imem[i_instr_cache_addr + 4];
      o_instr_cache_dat[47:40]  <= imem[i_instr_cache_addr + 5];
      o_instr_cache_dat[55:48]  <= imem[i_instr_cache_addr + 6];
      o_instr_cache_dat[63:56]  <= imem[i_instr_cache_addr + 7];
    end
end

// Invalidate if instruction == 32'b0   (End of program)
assign  o_cache_vld = |o_instr_cache_dat;    // Check if the fetched data is non-zero


endmodule : instruction_cache

