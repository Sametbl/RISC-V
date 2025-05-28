`timescale 1ns/1ps
import aqua_pkg::*;

module regfile_tb;
    rs_addr_s    addr_pkg;
    rs_data_s    read_pkg;
    writeback_s  write_pkg;

    reg i_clk, i_rst_n;
    reg [4:0]  rs1_addr_instr1, rs2_addr_instr1, rs1_addr_instr2, rs2_addr_instr2;   // Input: source addr
    reg [31:0] rs1_data_instr1, rs2_data_instr1, rs1_data_instr2, rs2_data_instr2;   // Output: data
    reg [4:0]  rd_addr_instr1,  rd_addr_instr2;     // Input: destination addr
    reg [31:0] rd_data_instr1,  rd_data_instr2;     // Input: destination data
    reg        wren_instr1,     wren_instr2;        // Input: write enable

    // Variables for checking results
    reg [31:0] expected_rs1_data_instr1, expected_rs2_data_instr1;
    reg [31:0] expected_rs1_data_instr2, expected_rs2_data_instr2;
    integer pass_count = 0;
    integer fail_count = 0;

    // DUT instantiation
    regfile dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_sch_rf_pkg(addr_pkg),
        .i_wb_rf_pkg(write_pkg),
        .o_rf_abt_pkg(read_pkg)
    );

    assign addr_pkg.rs1_addr_instr1 = rs1_addr_instr1;
    assign addr_pkg.rs2_addr_instr1 = rs2_addr_instr1;
    assign addr_pkg.rs1_addr_instr2 = rs1_addr_instr2;
    assign addr_pkg.rs2_addr_instr2 = rs2_addr_instr2;
    assign write_pkg.rd_addr_instr1 = rd_addr_instr1;
    assign write_pkg.rd_addr_instr2 = rd_addr_instr2;
    assign write_pkg.rd_data_instr1 = rd_data_instr1;
    assign write_pkg.rd_data_instr2 = rd_data_instr2;
    assign write_pkg.wren_instr1    = wren_instr1;
    assign write_pkg.wren_instr2    = wren_instr2;

    assign rs1_data_instr1 = read_pkg.rs1_data_instr1;    // Output data for Source Reigsters (4)
    assign rs2_data_instr1 = read_pkg.rs2_data_instr1;
    assign rs1_data_instr2 = read_pkg.rs1_data_instr2;
    assign rs2_data_instr2 = read_pkg.rs2_data_instr2;   

    // Waveform dumping
    initial begin : proc_dump
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);
    end

    // Clock generation
    initial begin
        i_rst_n = 1'b0;
        i_clk = 1'b0;
        forever #5 i_clk = ~i_clk;
    end

    // Testbench logic
    initial begin
        #10;
        i_rst_n = 1'b1;

        // Test Case 1
        rd_addr_instr1  = 5'b00001;
        rd_addr_instr2  = 5'b00010;
        rd_data_instr1  = 32'h12345678;
        rd_data_instr2  = 32'hABCD6789;
        wren_instr1     = 1'b1;
        wren_instr2     = 1'b1;

        rs1_addr_instr1 = 5'b00000;     // Source Registers
        rs2_addr_instr1 = 5'b00000;
        rs1_addr_instr2 = 5'b00000;
        rs2_addr_instr2 = 5'b00000;
        expected_rs1_data_instr1 = 32'h00000000;
        expected_rs2_data_instr1 = 32'h00000000;
        expected_rs1_data_instr2 = 32'h00000000;
        expected_rs2_data_instr2 = 32'h00000000;
        #1;
        check_results("Test Case 1",
                      rs1_data_instr1, expected_rs1_data_instr1,
                      rs2_data_instr1, expected_rs2_data_instr1,
                      rs1_data_instr2, expected_rs1_data_instr2,
                      rs2_data_instr2, expected_rs2_data_instr2);

        #20;
        // Test Case 2
        rd_addr_instr1  = 5'b00000;      // RD_addr_instr1 = X
        rd_addr_instr2  = 5'b00000;      // RD_addr_instr2 = X
        rd_data_instr1  = 32'h00000000;  // RD_data_instr1
        rd_data_instr2  = 32'h00000000;  // RD_data_instr2
        wren_instr1     = 1'b0;
        wren_instr2     = 1'b0;

        rs1_addr_instr1 = 5'b00010;     // RS1_instr1  = R2
        rs2_addr_instr1 = 5'b00001;     // RS2_instr1  = R1
        rs1_addr_instr2 = 5'b00000;     // RS1_instr2  = X
        rs2_addr_instr2 = 5'b00000;     // RS2_instr2  = X
        expected_rs1_data_instr1 = 32'hABCD6789;
        expected_rs2_data_instr1 = 32'h12345678;
        expected_rs1_data_instr2 = 32'h00000000;
        expected_rs2_data_instr2 = 32'h00000000;
        #1;
        check_results("Test Case 2",
                      rs1_data_instr1, expected_rs1_data_instr1,
                      rs2_data_instr1, expected_rs2_data_instr1,
                      rs1_data_instr2, expected_rs1_data_instr2,
                      rs2_data_instr2, expected_rs2_data_instr2);

        #20;
        // Test Case 3
        rd_addr_instr1  = 5'b01010;     // RD_addr_instr1 = R10
        rd_addr_instr2  = 5'b01011;     // RD_addr_instr2 = R11
        rd_data_instr1  = 32'h0000ABCD;  // RD_data_instr1
        rd_data_instr2  = 32'h00001234;  // RD_data_instr2
        wren_instr1  = 1'b1;           
        wren_instr2  = 1'b1;

        rs1_addr_instr1 = 5'b00000;     // RS1_instr1  = X
        rs2_addr_instr1 = 5'b00000;     // RS2_instr1  = X
        rs1_addr_instr2 = 5'b00000;     // RS1_instr2  = X
        rs2_addr_instr2 = 5'b00010;     // RS2_instr2  = R2
        expected_rs1_data_instr1 = 32'h00000000;
        expected_rs2_data_instr1 = 32'h00000000;
        expected_rs1_data_instr2 = 32'h00000000;
        expected_rs2_data_instr2 = 32'hABCD6789;
        #1;
        check_results("Test Case 3",
                      rs1_data_instr1, expected_rs1_data_instr1,
                      rs2_data_instr1, expected_rs2_data_instr1,
                      rs1_data_instr2, expected_rs1_data_instr2,
                      rs2_data_instr2, expected_rs2_data_instr2);

        #20;
        // Test Case 4
        rd_addr_instr1  = 5'b10100;     // RD_addr_instr1 = R20
        rd_addr_instr2  = 5'b10101;     // RD_addr_instr2 = R21
        rd_data_instr1  = 32'hA0A0A0A0;  // RD_data_instr1
        rd_data_instr2  = 32'hB0B0B0B0;  // RD_data_instr2
        wren_instr1  = 1'b1;       
        wren_instr2  = 1'b1;

        rs1_addr_instr1 = 5'b00000;     // RS1_instr1  = X
        rs2_addr_instr1 = 5'b01011;     // RS2_instr1  = R1
        rs1_addr_instr2 = 5'b00000;     // RS1_instr2  = X
        rs2_addr_instr2 = 5'b00000;     // RS2_instr2  = X
        expected_rs1_data_instr1 = 32'h00000000;
        expected_rs2_data_instr1 = 32'h00001234;
        expected_rs1_data_instr2 = 32'h00000000;
        expected_rs2_data_instr2 = 32'h00000000;
        #1;
        check_results("Test Case 4",
                      rs1_data_instr1, expected_rs1_data_instr1,
                      rs2_data_instr1, expected_rs2_data_instr1,
                      rs1_data_instr2, expected_rs1_data_instr2,
                      rs2_data_instr2, expected_rs2_data_instr2);

        #20;
        // Test Case 5
        rd_addr_instr1  = 5'b00001;    // RD_addr_instr1 = R1 
        rd_addr_instr2  = 5'b01010;    // RD_addr_instr2 = R10
        rd_data_instr1  = 32'hA0A0A0A0; // RD_data_instr1
        rd_data_instr2  = 32'hB0B0B0B0; // RD_data_instr2
        wren_instr1  = 1'b0;         
        wren_instr2  = 1'b0;

        rs1_addr_instr1 = 5'b10101;    // RS1_instr1  = R21 
        rs2_addr_instr1 = 5'b01011;    // RS2_instr1  = R11
        rs1_addr_instr2 = 5'b01010;    // RS1_instr2  = R10
        rs2_addr_instr2 = 5'b10100;    // RS2_instr2  = R20
        expected_rs1_data_instr1 = 32'hB0B0B0B0;
        expected_rs2_data_instr1 = 32'h00001234;
        expected_rs1_data_instr2 = 32'h0000ABCD;
        expected_rs2_data_instr2 = 32'hA0A0A0A0;
        #1;
        check_results("Test Case 5",
                      rs1_data_instr1, expected_rs1_data_instr1,
                      rs2_data_instr1, expected_rs2_data_instr1,
                      rs1_data_instr2, expected_rs1_data_instr2,
                      rs2_data_instr2, expected_rs2_data_instr2);

        #20;
        // Test Case 6
        rd_addr_instr1  = 5'b00001;    // RD_addr_instr1 = R1 
        rd_addr_instr2  = 5'b01010;    // RD_addr_instr2 = R10
        rd_data_instr1  = 32'h11223344; // RD_data_instr1
        rd_data_instr2  = 32'hAABBCCDD; // RD_data_instr2
        wren_instr1  = 1'b1;         
        wren_instr2  = 1'b1;

        rs1_addr_instr1 = 5'b00001;    // RS1_instr1  = R1 
        rs2_addr_instr1 = 5'b01010;    // RS2_instr1  = R10
        rs1_addr_instr2 = 5'b10100;    // RS1_instr2  = R20
        rs2_addr_instr2 = 5'b10101;    // RS2_instr2  = R21
        expected_rs1_data_instr1 = 32'h11223344;
        expected_rs2_data_instr1 = 32'hAABBCCDD;
        expected_rs1_data_instr2 = 32'hA0A0A0A0;
        expected_rs2_data_instr2 = 32'hB0B0B0B0;
        #1;
        check_results("Test Case 6",
                      rs1_data_instr1, expected_rs1_data_instr1,
                      rs2_data_instr1, expected_rs2_data_instr1,
                      rs1_data_instr2, expected_rs1_data_instr2,
                      rs2_data_instr2, expected_rs2_data_instr2);

        #20;
        // Test Case 7
        rd_addr_instr1  = 5'b00000;    // RD_addr_instr1 = X
        rd_addr_instr2  = 5'b11110;    // RD_addr_instr2 = R30
        rd_data_instr1  = 32'h00000000; // RD_data_instr1
        rd_data_instr2  = 32'hFFFFFFFF; // RD_data_instr2
        wren_instr1  = 1'b1;         
        wren_instr2  = 1'b1;

        rs1_addr_instr1 = 5'b00001;    // RS1_instr1  = R1 
        rs2_addr_instr1 = 5'b01010;    // RS2_instr1  = R10
        rs1_addr_instr2 = 5'b10100;    // RS1_instr2  = R20
        rs2_addr_instr2 = 5'b10101;    // RS2_instr2  = R21
        expected_rs1_data_instr1 = 32'h11223344;
        expected_rs2_data_instr1 = 32'hAABBCCDD;
        expected_rs1_data_instr2 = 32'hA0A0A0A0;
        expected_rs2_data_instr2 = 32'hB0B0B0B0;
        #1;
        check_results("Test Case 7",
                      rs1_data_instr1, expected_rs1_data_instr1,
                      rs2_data_instr1, expected_rs2_data_instr1,
                      rs1_data_instr2, expected_rs1_data_instr2,
                      rs2_data_instr2, expected_rs2_data_instr2);

        #20;
        // Test Case 8
        rd_addr_instr1  = 5'b01011;    // RD_addr_instr1 = R11 
        rd_addr_instr2  = 5'b10100;    // RD_addr_instr2 = R20
        rd_data_instr1  = 32'h11111111; // RD_data_instr1
        rd_data_instr2  = 32'h66666666; // RD_data_instr2
        wren_instr1  = 1'b0;         
        wren_instr2  = 1'b0;

        rs1_addr_instr1 = 5'b00010;    // RS1_instr1  = R2
        rs2_addr_instr1 = 5'b11110;    // RS2_instr1  = R30
        rs1_addr_instr2 = 5'b10101;    // RS1_instr2  = R11
        rs2_addr_instr2 = 5'b10100;    // RS2_instr2  = R20
        expected_rs1_data_instr1 = 32'hABCD6789;
        expected_rs2_data_instr1 = 32'hFFFFFFFF;
        expected_rs1_data_instr2 = 32'hB0B0B0B0;
        expected_rs2_data_instr2 = 32'hA0A0A0A0;
        #1;
        check_results("Test Case 8",
                      rs1_data_instr1, expected_rs1_data_instr1,
                      rs2_data_instr1, expected_rs2_data_instr1,
                      rs1_data_instr2, expected_rs1_data_instr2,
                      rs2_data_instr2, expected_rs2_data_instr2);



        #20;
        // Test Case 9
        rd_addr_instr1  = 5'b10110;    // RD_addr_instr1 = R11 
        rd_addr_instr2  = 5'b10000;    // RD_addr_instr2 = R20
        rd_data_instr1  = 32'h22222222; // RD_data_instr1
        rd_data_instr2  = 32'hABCDDBCA; // RD_data_instr2
        wren_instr1  = 1'b0;         
        wren_instr2  = 1'b0;

        rs1_addr_instr1 = 5'b00010;    // RS1_instr1  = R2
        rs2_addr_instr1 = 5'b11110;    // RS2_instr1  = R30
        rs1_addr_instr2 = 5'b01011;    // RS1_instr2  = R11
        rs2_addr_instr2 = 5'b10100;    // RS2_instr2  = R20
        expected_rs1_data_instr1 = 32'hABCD6789;
        expected_rs2_data_instr1 = 32'hFFFFFFFF;
        expected_rs1_data_instr2 = 32'h00001234;
        expected_rs2_data_instr2 = 32'hA0A0A0A0;
        #1;
        check_results("Test Case 9",
                      rs1_data_instr1, expected_rs1_data_instr1,
                      rs2_data_instr1, expected_rs2_data_instr1,
                      rs1_data_instr2, expected_rs1_data_instr2,
                      rs2_data_instr2, expected_rs2_data_instr2);



        #20;
        $display("Total Passed: %0d, Total Failed: %0d", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end
        $finish;
    end




task automatic check_results(input string test_name,
                             input [31:0] actual_rs1_data, expected_rs1_data,
                             input [31:0] actual_rs2_data, expected_rs2_data,
                             input [31:0] actual_rs3_data, expected_rs3_data,
                             input [31:0] actual_rs4_data, expected_rs4_data);
    // ANSI escape codes for colors
    string green = "\033[32m"; // Green text
    string red   = "\033[31m"; // Red text
    string reset = "\033[0m";  // Reset to default text color

    begin
        $display("Checking %s at time %0t ns", test_name, $time);
        if (actual_rs1_data === expected_rs1_data &&
            actual_rs2_data === expected_rs2_data &&
            actual_rs3_data === expected_rs3_data &&
            actual_rs4_data === expected_rs4_data) begin
                $display("%s%s: PASSED%s\n", green, test_name, reset); // Green text for PASSED
                pass_count = pass_count + 1;
        end else begin
            $display("%s%s: FAILED%s", red, test_name, reset); // Red text for FAILED
            $display("  Actual RS1_instr1: %h, Expected RS1_instr1: %h",   actual_rs1_data, expected_rs1_data);
            $display("  Actual RS2_instr1: %h, Expected RS2_instr1: %h",   actual_rs2_data, expected_rs2_data);
            $display("  Actual RS1_instr2: %h, Expected RS1_instr2: %h",   actual_rs3_data, expected_rs3_data);
            $display("  Actual RS2_instr2: %h, Expected RS2_instr2: %h\n", actual_rs4_data, expected_rs4_data);
            fail_count = fail_count + 1;
        end
    end
endtask



endmodule
