module validation(
  input  wire clk, cache_vld,rst_n,
  input  wire [63:0] o_icache_fbuf_dat,
  input  wire [31:0] o_pc_gen,
  output reg [31:0] pc,
  output reg [63:0] instr,
  output reg [1:0] instr_vld  
);


register register_delay_pc (
	    .rst(!rst_n),
      .clk(clk),
	    .en(1'b1),
		  .D(o_pc_gen),
    	.Q(pc)
);

always_comb begin
      instr = o_icache_fbuf_dat;  
      instr_vld[0] = cache_vld & ~pc[2];
      instr_vld[1] = cache_vld;
end
endmodule 
