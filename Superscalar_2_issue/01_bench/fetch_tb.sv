module testbench();
    // Inputs
  reg clk;
  reg rst_n;
  reg pc_sel;
  reg [31:0] i_bru;

  // Outputs
  wire [31:0] pc;
  wire [63:0] instr;
  wire [1:0] instr_vld;

  wire [31:0] instr1,instr2;
  assign instr1= instr[31:0];
  assign instr2= instr[63:32];
  // Instantiate the aqua_fetch module
  aqua_fetch dut (
    .clk(clk),
    .rst_n(rst_n),
    .pc_sel(pc_sel),
    .i_bru(i_bru),
    .pc(pc),
    .instr(instr),
    .instr_vld(instr_vld)
  );

  // Clock Generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns clock period
  end

  /* VCS
    initial begin
        $fsdbDumpfile("testbench.fsdb");
        $fsdbDumpvars(0, testbench, "+all","+mda");
    end */
// Wave dumping Verilator
  initial begin : proc_dump_wave
    $dumpfile("wave.vcd");
    $dumpvars(0, dut);
  end


  // Testbench stimuli
  initial begin
    // Initialize inputs
    rst_n = 0;
    pc_sel = 0;
    i_bru = 32'd0;

    // Reset system
    #10 rst_n = 1;

    // Test case 1: Default case
    #20;
    pc_sel = 0;

    // Test case 2: Branch taken
    #30;
    pc_sel = 1;
    i_bru = 32'h0000004; // Example branch address

    // Test case 3: Back to default case
    #30;
    pc_sel = 1;
    i_bru = 32'h00000034;

    // Wait some cycles
    #100;

    // Finish simulation
    $finish;
  end

  // Monitor outputs
  initial begin
    $monitor($time, " clk=%b | rst_n=%b | pc_sel=%b | i_bru=%h | pc=%h | instr=%h | instr1=%h | instr2=%h | instr_vld=%b",
             clk, rst_n, pc_sel, i_bru, pc, instr, instr1, instr2, instr_vld);
  end

endmodule
