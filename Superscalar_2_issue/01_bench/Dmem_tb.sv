`timescale 1ns / 1ps
import aqua_pkg::*;

module Dmem_tb;

o_lsu_s            i_lsu_pkg;
wire [31:0]        o_dmem;

logic [31:0]       addr_tb;
logic [31:0]       wdata_tb;
logic [3:0]        bytemask_tb;
logic              wren_tb;
logic              valid_tb;
logic              i_clk;
logic              rst_n;

logic [31:0]       actual_output;
logic [31:0]       expected_output;

// Test parameters
int iteration = 10000;
string msg;
integer pass_count = 0;
integer fail_count = 0;

// Terminal color codes
string GREEN  = "\033[32m";
string RED    = "\033[31m";
string RESET  = "\033[0m";

assign i_lsu_pkg.p_addr     = addr_tb;
assign i_lsu_pkg.p_wdata    = wdata_tb;
assign i_lsu_pkg.p_bytemask = 4'b1111;
assign i_lsu_pkg.p_wren     = wren_tb;
assign i_lsu_pkg.valid      = valid_tb;
assign actual_output        = o_dmem;

// DUT Instance
dmem #(.DMEM_W(16)) dutty (
    .clk(i_clk),
    .rst_n(rst_n),
    .i_o_lsu(i_lsu_pkg),
    .o_p_rdata(o_dmem)
);
expected_output_module find_output_expected (
            .clk(i_clk),
            .rst_n_compare(rst_n),
            .i_lsu_pkg_test(i_lsu_pkg),
            .get_output_expected(expected_output)
);
// Waveform Dumping
initial begin : proc_dump
    $dumpfile("wave.vcd");
    $dumpvars(0, dutty);
end

// Clock Generation
initial begin
    i_clk = 0;
    rst_n = 1'b1;
    forever #5 i_clk = ~i_clk; // Toggle every 5 time units
end

// Testbench Logic
initial begin
 
    for (int i = 0; i < iteration; i++) begin
        addr_tb = 100;
        wdata_tb = $random;
        //wren_tb = $urandom_range(0, 1)[0];
        wren_tb = 1'b1;
        valid_tb = $urandom_range(0, 1)[0];

        #5; // Wait for stabilization

      

        msg = $sformatf("p_address: 0x%h, p_data: 0x%h, p_bytemask: 0x%h", addr_tb, i_lsu_pkg.p_wdata, i_lsu_pkg.p_bytemask);
        verify_output(i, msg, expected_output, actual_output);
    end

    #10;
    $display("Total Passed: %0d, Total Failed: %0d", pass_count, fail_count);
    if (fail_count == 0)
        $display("ALL TESTS PASSED");
    else
        $display("SOME TESTS FAILED");
    $finish;
end

// Verification Task
task verify_output;
    input int test_index;
    input string test_case;
    input [31:0] expected;
    input [31:0] actual;
    begin
        if (expected === actual) begin
            $display("%sTest %0d Passed: %s%s", GREEN, test_index, test_case, RESET);
            pass_count++;
        end else begin
            $display("%sTest %0d Failed: %s%s", RED, test_index, test_case, RESET);
            $display("Expected: 0x%h, Actual: 0x%h", expected, actual);
            fail_count++;
        end
    end
endtask

endmodule

// Expected Output Module
module expected_output_module(
    input  logic       clk,
    input  logic       rst_n_compare,
    input  o_lsu_s     i_lsu_pkg_test,
    output logic [31:0] get_output_expected
);
    logic [3:0]  bytemask;
    logic [31:0] data;
    logic [31:0] compute_expected_output;
    logic [31:0] put_data_in_ff;

    assign bytemask = i_lsu_pkg_test.p_bytemask;
    assign data = i_lsu_pkg_test.p_wdata;
    assign get_output_expected = put_data_in_ff;

    always @(posedge clk or negedge rst_n_compare) begin
        if (!rst_n_compare) begin
            compute_expected_output <= 32'h0; // Reset case
        end 
        else if (i_lsu_pkg_test.p_wren) begin
            case (bytemask)
                4'b0000: compute_expected_output <= 32'h0;
                4'b0001: compute_expected_output <= {24'h0, data[7:0]};
                4'b0011: compute_expected_output <= {16'h0, data[15:0]};
                4'b1111: compute_expected_output <= data;
                default: compute_expected_output <= 32'h0;
            endcase
        end 
    end

    always_ff @(posedge clk or negedge rst_n_compare) begin
        if (!rst_n_compare) begin
            put_data_in_ff <= 32'h0; // Reset case
        end 
        else begin
         if(i_lsu_pkg_test.p_wren) begin
          put_data_in_ff <= compute_expected_output;
         end
         else begin
          put_data_in_ff <= put_data_in_ff;
         end
        end
    end
endmodule
