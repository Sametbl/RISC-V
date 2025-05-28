`timescale 1ns / 1ps
import aqua_pkg::*;

module LSU_tb;

agu_issue_s             i_lsu_pkg;
logic                   i_clk;
logic [31:0]            i_p_rdata;
o_lsu_s                 o_lsu_pkg;
o_lsu_s                 o_expected_lsu_pkg;

operator_e         instr_tb;
reg [31:0]         rs1_addr_tb;
reg [31:0]         imm_tb;
reg [4:0]          rd_addr_tb;
reg [31:0]         i_data_tb;
reg                fwd_en_tb;
reg                valid_tb;
reg [31:0]         i_p_rdata_tb;


reg [31:0]         actual_addr_output;
reg [31:0]         actual_wdata_output;
reg [31:0]         actual_rdata_output;
reg [3:0]          actual_bytemask_output;
reg                actual_p_wren;
reg                actual_valid;

reg [4:0]          expected_addr_output;
reg [31:0]         expected_wdata_output;
reg [31:0]         expected_rdata_output;
reg [3:0]          expected_byemask_output;
reg                expected_p_wren;
reg                expected_valid;

// Define the number of iterations for testing
int iteration = 10000;
string msg;
integer pass_count = 0;
integer fail_count = 0;
// Color codes for terminal output
string GREEN  = "\033[32m";
string RED    = "\033[31m";
string RESET  = "\033[0m";
string BOLD   = "\033[1m";
string UNBOLD = "\033[22m";

 
assign i_lsu_pkg.operand_a = rs1_addr_tb;
assign i_lsu_pkg.operand_b = imm_tb;
assign i_lsu_pkg.instr     = instr_tb;
assign i_lsu_pkg.rd_addr   = rd_addr_tb;
assign i_lsu_pkg.fwd_en    = fwd_en_tb;
assign i_lsu_pkg.valid     = valid_tb;
assign i_p_rdata           = i_p_rdata_tb; 


assign actual_addr_output           = o_lsu_pkg.p_addr; 
assign actual_wdata_output          = o_lsu_pkg.p_wdata; 
assign actual_rdata_output          = o_lsu_pkg.p_rdata; 
assign actual_bytemask_output       = o_lsu_pkg.p_bytemask; 
assign actual_p_wren                = o_lsu_pkg.p_wren; 


  lsu       #(.LSU_ADDR_W(32)) dutty (.i_clk(i_clk),
                  .i_funct_data(i_lsu_pkg),
                  .i_p_rdata     (i_p_rdata),
                  .o_store_data(o_lsu_pkg)
  );

expected_LSU_output  #(.LSU_ADDR_W(32)) exptected_ouput(.i_clk(i_clk),
                  .i_funct_data   (i_lsu_pkg),
                  .i_p_rdata        (i_p_rdata),
                  .o_expected_data(o_expected_lsu_pkg)
);
// Waveform dumping
initial begin : proc_dump
    $dumpfile("wave.vcd");
    $dumpvars(0, dutty);
end

initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk; // Toggle every 5 time units
end

initial begin
    // Test Loop
    for(int i = 0; i < iteration; i++) begin
      instr_tb    = operator_e'($urandom_range(19, 26)); 
      rs1_addr_tb    = $random;
      imm_tb         = $random;
      rd_addr_tb     = $urandom_range(0, 31)[4:0];
      i_data_tb      = $random;
      i_p_rdata_tb   = $random;
// verilator lint_off WIDTHTRUNC */
      fwd_en_tb    = $urandom_range(0, 1);
      valid_tb     = $urandom_range(0, 1);
// verilator lint_off WIDTHTRUNC */

      #5; // Wait to stabilize

      //expected_output = compute_expected_output(rs1_addr_tb, imm_tb, instr_tb, valid_tb);
      msg = $sformatf("Operation: %s%s%s, Operand A: 0x%h, Operand B: 0x%h", BOLD, operator_to_string(instr_tb), UNBOLD, rs1_addr_tb, imm_tb);
      verify_output(i, msg, o_expected_lsu_pkg, o_lsu_pkg);
    end

    #10;
    $display("Total Passed: %0d, Total Failed: %0d", pass_count, fail_count);
    if (fail_count == 0) begin
        $display("ALL TESTS PASSED");
    end
    else begin
        $display("SOME TESTS FAILED");
    end
    $finish;
end






  task verify_output;
    input int            test_index;
    input string         test_case;
    input o_lsu_s        expected;
    input o_lsu_s        actual;
    begin
      if ((expected.p_bytemask === actual.p_bytemask) && (expected.p_rdata === actual.p_rdata)) begin
        $display("%sTest %0d Passed: %s%s", GREEN, test_index, test_case, RESET);
        pass_count = pass_count +1;
      end
      
      else begin
        $display("%sTest %0d Failed: %s%s", RED, test_index,  test_case, RESET);
        $display("Expected: 0x%h, Actual: 0x%h", expected, actual);
        fail_count = fail_count +1;
      end
    end
  endtask




function string operator_to_string(operator_e op);
    case (op)
        ADD:     operator_to_string = "ADD  ";
        SUB:     operator_to_string = "SUB  ";
        XOR:     operator_to_string = "XOR  ";
        OR:      operator_to_string = "OR   ";
        AND:     operator_to_string = "AND  ";
        SLL:     operator_to_string = "SLL  ";
        SRL:     operator_to_string = "SRL  ";
        SRA:     operator_to_string = "SRA  ";
        BEQ:     operator_to_string = "BEQ  ";
        BNE:     operator_to_string = "BNE  ";
        BLT:     operator_to_string = "BLT  ";
        BGE:     operator_to_string = "BGE  ";
        BLTU:    operator_to_string = "BLTU ";
        BGEU:    operator_to_string = "BGEU ";
        JAL:     operator_to_string = "JAL  ";
        JALR:    operator_to_string = "JALR ";
        SLT:     operator_to_string = "SLT  ";
        SLTU:    operator_to_string = "SLTU ";
        LB:      operator_to_string = "LB   ";
        LH:      operator_to_string = "LH   ";
        LW:      operator_to_string = "LW   ";
        LBU:     operator_to_string = "LBU  ";
        LHU:     operator_to_string = "LHU  ";
        SB:      operator_to_string = "SB   ";
        SH:      operator_to_string = "SH   ";
        SW:      operator_to_string = "SW   ";
        default: operator_to_string = "NOP  ";
    endcase
endfunction


endmodule: LSU_tb

module expected_LSU_output #(parameter LSU_ADDR_W = 32)(
    input  logic            i_clk,
    input  agu_issue_s      i_funct_data,

    input  logic [31:0]     i_p_rdata,

    output o_lsu_s          o_expected_data 
);
    logic [31:0] address;
    logic        a_is_store;
    logic        a_is_load;
    logic        a_is_word;
    logic        a_is_half;
    logic        a_is_byte;

    logic        a_is_program;
    logic        a_is_dmem;
    logic        a_is_peripherals;
    logic        a_is_reserved;

    operator_e   a_operator; // Holding the old values since LSU is placed in 2 stages
// LB = 10010 (18); LH = 10011(19); LW = 10100 (20)
// LBU = 10101 (21); LHU = 10110(22); 
// SB = 10111 (23); SH = 11000(24); SW = 11001 (25)
always_comb begin : proc_lsu_initial
        address = i_funct_data.operand_a + i_funct_data.operand_b;
end
    assign a_is_store = (i_funct_data.instr == SW) 
                     || (i_funct_data.instr == SH) 
                     || (i_funct_data.instr == SB);

    assign a_is_load  = (i_funct_data.instr == LW) 
                     || (i_funct_data.instr == LH) 
                     || (i_funct_data.instr == LB) 
                     || (i_funct_data.instr == LHU) 
                     || (i_funct_data.instr == LBU);

    assign a_is_word  = (i_funct_data.instr == LW) 
                     || (i_funct_data.instr == SW);

    assign a_is_half  = (i_funct_data.instr == LHU) 
                     || (i_funct_data.instr == LH) 
                     || (i_funct_data.instr == SH);

    assign a_is_byte  = (i_funct_data.instr == LBU) 
                     || (i_funct_data.instr == LB) 
                     || (i_funct_data.instr == SB);

    assign a_is_program     = (address[LSU_ADDR_W - 1]    == 'b0);
    assign a_is_dmem        = (address[LSU_ADDR_W - 1 : LSU_ADDR_W - 2] == 'b10);
    assign a_is_peripherals = (i_funct_data.operand_a[LSU_ADDR_W - 1 : LSU_ADDR_W - 3] == 'b110);
    assign a_is_reserved    = ~(a_is_program | a_is_dmem | a_is_peripherals);

    always_ff @(posedge i_clk) begin 
        a_operator <= (i_funct_data.valid == 1'b1) ? i_funct_data.instr : ADD;
    end

    always_comb begin
        case (a_operator)
            LB : begin
                o_expected_data.p_rdata  = {{24{i_p_rdata[7]}}, i_p_rdata[7:0]};
            end

            LBU: begin
                o_expected_data.p_rdata  = {24'h0, i_p_rdata[7:0]};
            end

            LH : begin
                o_expected_data.p_rdata  = {{16{i_p_rdata[15]}}, i_p_rdata[15:0]};
            end

            LHU : begin
                o_expected_data.p_rdata  = {16'h0, i_p_rdata[15:0]};
            end

            LW : begin
                o_expected_data.p_rdata  = {i_p_rdata[31:0]};        
            end

            default: o_expected_data.p_rdata  = 32'h0;
        endcase
    end

always_comb begin
    if(a_is_word) begin
     o_expected_data.p_bytemask = 4'b1111;
    end
    else if(a_is_half) begin
     o_expected_data.p_bytemask = 4'b0011;
    end
    else if(a_is_byte) begin
     o_expected_data.p_bytemask = 4'b0001;
    end
    else begin
     o_expected_data.p_bytemask = 4'b0000;
    end
end

endmodule
