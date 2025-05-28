module pc_gen(
  input  wire          clk     ,
  input  wire          rst_n   ,
  input  wire          pc_sel  ,
  input  wire          pc_ready,
  input  wire [31:0]   i_bru   ,      // Target PC from Branch prediction unit
  output reg  [31:0]   o_pc_gen
);

// PC reegister
reg [31:0] pc_d;    // Input  D - PC
reg [31:0] pc_q;    // Output Q - PC

// INPUT TO PC REGISTER: Select next_PC or target_PC
always @(*) begin
    if (pc_ready & rst_n)       pc_d =    pc_sel ? i_bru : pc_q + 32'd8;
    else                        pc_d =    pc_q;
end

// Update PC Register
always @(posedge clk or negedge rst_n) begin : proc_update_pc
    if (!rst_n)           pc_q <= '0;
    else                  pc_q <= pc_d;
end

always_comb begin
    if (pc_sel)          o_pc_gen = pc_d;
    else                 o_pc_gen = pc_q;
end	
endmodule : pc_gen
