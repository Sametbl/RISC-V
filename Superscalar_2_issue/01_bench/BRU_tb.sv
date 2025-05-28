`timescale 1ns / 1ps
import aqua_pkg::*;

module BRU_tb;

wire bru_issue_s   i_abt_bru_pkg;
wire uv_buff_s     o_bru_buff_pkg;
wire branch_s      o_bru_prd_pkg; 
operator_e         instr_tb;
reg [31:0]         operand_a;
reg [31:0]         operand_b;
reg [31:0]         rs1_data;
reg [31:0]         rs2_data;
reg [4:0]          rd_addr;
reg                fwd_en_tb;
reg                valid_tb;

reg [31:0]         actual_ALU_output;
reg [31:0]         expected_ALU_output;
reg                actual_PRD_output;
reg                expected_PRD_output;

// Define the number of iterations for testing
int iteration = 100000;
string msg;
integer pass_count = 0;
integer fail_count = 0;

// Color codes for terminal output
string GREEN  = "\033[32m";
string RED    = "\033[31m";
string RESET  = "\033[0m";
string BOLD   = "\033[1m";
string UNBOLD = "\033[22m";

assign i_abt_bru_pkg.operand_a = operand_a;
assign i_abt_bru_pkg.operand_b = operand_b;
assign i_abt_bru_pkg.rs1_data  = rs1_data;
assign i_abt_bru_pkg.rs2_data  = rs2_data;
assign i_abt_bru_pkg.instr     = instr_tb;
assign i_abt_bru_pkg.fwd_en    = fwd_en_tb;
assign i_abt_bru_pkg.valid     = valid_tb;
assign i_abt_bru_pkg.rd_addr   = rd_addr;

assign actual_ALU_output           = o_bru_buff_pkg.data_buff; 
assign actual_PRD_output           = o_bru_prd_pkg.taken; 

BRU     dutty(.i_abt_bru_pkg(i_abt_bru_pkg),
              .o_bru_buff_pkg(o_bru_buff_pkg),
              .o_bru_prd_pkg(o_bru_prd_pkg)   // From BRU to "Branch Prediction Unit"
);

// Waveform dumping
initial begin : proc_dump
    $dumpfile("wave.vcd");
    $dumpvars(0, dutty);
end

initial begin
    instr_tb    = operator_e'(5'b0); 
    operand_a   = 32'b0;
    operand_b   = 32'b0;
    rs1_data    = 32'b0;
    rs2_data    = 32'b0;
    rd_addr     = 5'b0;
    fwd_en_tb   = 1'b0;
    valid_tb    = 1'b0;

    // Test Loop
    for (int i = 0; i < iteration; i++) begin
        // 70% chance of Branch instruction
        if ($urandom_range(0, 100) < 70) begin
            instr_tb = operator_e'($urandom_range(10, 15));
        end
        else begin
            do     instr_tb  = operator_e'($urandom_range(0, 25));
            while (instr_tb >= operator_e'(10) && instr_tb <= operator_e'(15));
        end

        operand_a = $random;
        operand_b = $random;
        rs1_data  = $random;
        rs2_data  = $random;

        // verilator lint_off WIDTHTRUNC
        fwd_en_tb    = $urandom_range(0, 1);
        valid_tb     = $urandom_range(0, 1);
        // verilator lint_on WIDTHTRUNC

        #5; // Wait to stabilize
        expected_ALU_output = compute_expected_ALU_output(operand_a, operand_b, instr_tb, valid_tb);
        expected_PRD_output = compute_expected_PRD_output(rs1_data,  rs2_data,  instr_tb, valid_tb);

        msg = $sformatf("Operation: %s%s%s, Operand A:  0x%h, Operand B: 0x%h", BOLD, operator_to_string(instr_tb), UNBOLD, operand_a, operand_b);
        verify_output(i, msg,
                      expected_ALU_output, actual_ALU_output,
                      expected_PRD_output, actual_PRD_output
        );
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
    input int test_index;
    input string test_case;
    input [31:0] expected_ALU_data;
    input [31:0] actual_ALU_data;
    input [0:0]  expected_PRD_data;
    input [0:0]  actual_PRD_data;
       
    begin
        if (expected_ALU_data === actual_ALU_data && expected_PRD_data === actual_PRD_data) begin
            $display("%sTest %0d Passed: %s%s", GREEN, test_index, test_case, RESET);
            pass_count++;
        end else begin
            $display("%sTest %0d Failed: %s%s", RED, test_index, test_case, RESET);
            $display("Expected ALU: 0x%h, Actual ALU: 0x%h", expected_ALU_data, actual_ALU_data);
            $display("Expected PRD: 0x%b, Actual PRD: 0x%b", expected_PRD_data, actual_PRD_data);
            fail_count++;
        end
    end
endtask

// Expected ALU output computation
function [31:0] compute_expected_ALU_output(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [4:0]  instr_in,
    input logic valid_in
);
    if (valid_in) begin
        case (instr_in)
            ADD:       compute_expected_ALU_output =  $signed(a)   + $signed(b);
            SUB:       compute_expected_ALU_output =  $signed(a)   - $signed(b);
            SLT:       compute_expected_ALU_output = ($signed(a)   < $signed(b))   ? 1 : 0;
            SLTU:      compute_expected_ALU_output = ($unsigned(a) < $unsigned(b)) ? 1 : 0;
            XOR:       compute_expected_ALU_output =  $unsigned(a) ^ $unsigned(b);
            AND:       compute_expected_ALU_output =  $unsigned(a) & $unsigned(b);
            OR:        compute_expected_ALU_output =  $unsigned(a) | $unsigned(b);
            SLL:       compute_expected_ALU_output =  $unsigned(a) <<  (b[4:0]);
            SRL:       compute_expected_ALU_output =  $unsigned(a) >>  (b[4:0]);
            SRA:       compute_expected_ALU_output =  $signed(a)   >>> (b[4:0]);
            default:   compute_expected_ALU_output =  $signed(a)   +    $signed(b); // Default for unsupported instructions
        endcase
    end
    else               compute_expected_ALU_output = 32'b0;   
endfunction

// Expected Branch output computation
function [0:0] compute_expected_PRD_output(
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    input logic [4:0]  instr_in,
    input logic valid_in
);
    if (valid_in) begin
        case (instr_in)
            BEQ:       compute_expected_PRD_output = ($unsigned(rs1) == $unsigned(rs2));
            BNE:       compute_expected_PRD_output = ($unsigned(rs1) != $unsigned(rs2));
            BLT:       compute_expected_PRD_output = ($signed(rs1)   <  $signed(rs2));
            BGE:       compute_expected_PRD_output = ($signed(rs1)   >= $signed(rs2));
            BLTU:      compute_expected_PRD_output = ($unsigned(rs1) <  $unsigned(rs2));
            BGEU:      compute_expected_PRD_output = ($unsigned(rs1) >= $unsigned(rs2));
            default:   compute_expected_PRD_output =  1'b0;
        endcase
    end else begin
        compute_expected_PRD_output = 1'b0;
    end
endfunction

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


endmodule
