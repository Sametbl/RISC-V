`timescale 1ns/1ps
import aqua_pkg::*;

module forwarding_unit_tb;

rs_addr_s       i_sch_fwd_pkg;        // Input Source Register address
fwd_sel_s       o_fwd_abt_pkg;        // Output Select Register index
uv_buff_s       i_ALU_buff_1_pkg;     // Location 1
uv_buff_s       i_ALU_buff_2_pkg;     // Location 2 
uv_buff_s       i_ALU_buff_3_pkg;     // Location 3 
uv_buff_s       i_BRU_buff_1_pkg;     // Location 4 
uv_buff_s       i_BRU_buff_2_pkg;     // Location 5 
uv_buff_s       i_BRU_buff_3_pkg;     // Location 6 
uv_buff_s       i_MEM_buff_pkg;       // Location 7 

reg [4:0] rs1_addr_instr1;
reg [4:0] rs2_addr_instr1;
reg [4:0] rs1_addr_instr2;
reg [4:0] rs2_addr_instr2;
wire logic [6:0] fwd_rs1_instr1;
wire logic [6:0] fwd_rs2_instr1;
wire logic [6:0] fwd_rs1_instr2;
wire logic [6:0] fwd_rs2_instr2;

// Random waveform generator parameter
int iteration  = 200;      // Number of changes in the signal
int pass_count = 0;
int fail_count = 0;

reg [6:0] expected_fwd_rs1_instr1;
reg [6:0] expected_fwd_rs2_instr1;
reg [6:0] expected_fwd_rs1_instr2;
reg [6:0] expected_fwd_rs2_instr2;



forwarding_unit   dutty  (.i_sch_fwd_pkg(i_sch_fwd_pkg),
                          .i_ALU_buff_1_pkg(i_ALU_buff_1_pkg),
                          .i_ALU_buff_2_pkg(i_ALU_buff_2_pkg),
                          .i_ALU_buff_3_pkg(i_ALU_buff_3_pkg),
                          .i_BRU_buff_1_pkg(i_BRU_buff_1_pkg),
                          .i_BRU_buff_2_pkg(i_BRU_buff_2_pkg),
                          .i_BRU_buff_3_pkg(i_BRU_buff_3_pkg),
                          .i_MEM_buff_pkg(i_MEM_buff_pkg),
                          .o_fwd_abt_pkg(o_fwd_abt_pkg)
);


// Input
assign  i_sch_fwd_pkg.rs1_addr_instr1 = rs1_addr_instr1;
assign  i_sch_fwd_pkg.rs2_addr_instr1 = rs2_addr_instr1;
assign  i_sch_fwd_pkg.rs1_addr_instr2 = rs1_addr_instr2;
assign  i_sch_fwd_pkg.rs2_addr_instr2 = rs2_addr_instr2;

// Output
assign  fwd_rs1_instr1 = o_fwd_abt_pkg.fwd_rs1_instr1;
assign  fwd_rs2_instr1 = o_fwd_abt_pkg.fwd_rs2_instr1;
assign  fwd_rs1_instr2 = o_fwd_abt_pkg.fwd_rs1_instr2;
assign  fwd_rs2_instr2 = o_fwd_abt_pkg.fwd_rs2_instr2;

initial begin : proc_dump
    $dumpfile("wave.vcd");
    $dumpvars(0, dutty);
end


initial begin
      for(int i = 0; i < iteration; i++) begin
        // Verilator lint_off WIDTH
            expected_fwd_rs1_instr1 = 7'b0000000; 
            expected_fwd_rs2_instr1 = 7'b0000000;
            expected_fwd_rs1_instr2 = 7'b0000000;
            expected_fwd_rs2_instr2 = 7'b0000000;
        
            rs1_addr_instr1 = $urandom_range(0,31);            // Source register address
            rs2_addr_instr1 = $urandom_range(0,31);            // Source register address
            rs1_addr_instr2 = $urandom_range(0,31);            // Source register address
            rs2_addr_instr2 = $urandom_range(0,31);            // Source register address

            i_ALU_buff_1_pkg.rd_buff = $urandom_range(0,31);    // Location 1 destination register address
            i_ALU_buff_2_pkg.rd_buff = $urandom_range(0,31);    // Location 2 destination register address
            i_ALU_buff_3_pkg.rd_buff = $urandom_range(0,31);    // Location 3 destination register address
            i_BRU_buff_1_pkg.rd_buff = $urandom_range(0,31);    // Location 4 destination register address
            i_BRU_buff_2_pkg.rd_buff = $urandom_range(0,31);    // Location 5 destination register address
            i_BRU_buff_3_pkg.rd_buff = $urandom_range(0,31);    // Location 6 destination register address
            i_MEM_buff_pkg.rd_buff   = $urandom_range(0,31);    // Location 7 destination register address

            i_ALU_buff_1_pkg.valid  = $urandom_range(0,1);
            i_ALU_buff_2_pkg.valid  = $urandom_range(0,1);
            i_ALU_buff_3_pkg.valid  = $urandom_range(0,1);
            i_BRU_buff_1_pkg.valid  = $urandom_range(0,1);
            i_BRU_buff_2_pkg.valid  = $urandom_range(0,1);
            i_BRU_buff_3_pkg.valid  = $urandom_range(0,1);
            i_MEM_buff_pkg  .valid  = $urandom_range(0,1);

            i_ALU_buff_1_pkg.fwd_en  = $urandom_range(0,1);
            i_ALU_buff_2_pkg.fwd_en  = $urandom_range(0,1);
            i_ALU_buff_3_pkg.fwd_en  = $urandom_range(0,1);
            i_BRU_buff_1_pkg.fwd_en  = $urandom_range(0,1);
            i_BRU_buff_2_pkg.fwd_en  = $urandom_range(0,1);
            i_BRU_buff_3_pkg.fwd_en  = $urandom_range(0,1);
            i_MEM_buff_pkg.fwd_en    = $urandom_range(0,1);
            #5;
        // Verilator lint_on WIDTH
            expected_output_gen(rs1_addr_instr1, rs2_addr_instr1, rs1_addr_instr2, rs2_addr_instr2,
                                i_ALU_buff_1_pkg.rd_buff, 0,
                                i_ALU_buff_1_pkg.valid,
                                i_ALU_buff_1_pkg.fwd_en,
                                expected_fwd_rs1_instr1,
                                expected_fwd_rs2_instr1,
                                expected_fwd_rs1_instr2,
                                expected_fwd_rs2_instr2);

            expected_output_gen(rs1_addr_instr1, rs2_addr_instr1, rs1_addr_instr2, rs2_addr_instr2,
                                i_ALU_buff_2_pkg.rd_buff, 1,
                                i_ALU_buff_2_pkg.valid,
                                i_ALU_buff_2_pkg.fwd_en,
                                expected_fwd_rs1_instr1,
                                expected_fwd_rs2_instr1,
                                expected_fwd_rs1_instr2,
                                expected_fwd_rs2_instr2);


            expected_output_gen(rs1_addr_instr1, rs2_addr_instr1, rs1_addr_instr2, rs2_addr_instr2,
                                i_ALU_buff_3_pkg.rd_buff, 2,
                                i_ALU_buff_3_pkg.valid,
                                i_ALU_buff_3_pkg.fwd_en,
                                expected_fwd_rs1_instr1,
                                expected_fwd_rs2_instr1,
                                expected_fwd_rs1_instr2,
                                expected_fwd_rs2_instr2);


            expected_output_gen(rs1_addr_instr1, rs2_addr_instr1, rs1_addr_instr2, rs2_addr_instr2,
                                i_BRU_buff_1_pkg.rd_buff, 3,
                                i_BRU_buff_1_pkg.valid,
                                i_BRU_buff_1_pkg.fwd_en,
                                expected_fwd_rs1_instr1,
                                expected_fwd_rs2_instr1,
                                expected_fwd_rs1_instr2,
                                expected_fwd_rs2_instr2);


            expected_output_gen(rs1_addr_instr1, rs2_addr_instr1, rs1_addr_instr2, rs2_addr_instr2,
                                i_BRU_buff_2_pkg.rd_buff, 4,
                                i_BRU_buff_2_pkg.valid,
                                i_BRU_buff_2_pkg.fwd_en,
                                expected_fwd_rs1_instr1,
                                expected_fwd_rs2_instr1,
                                expected_fwd_rs1_instr2,
                                expected_fwd_rs2_instr2);


            expected_output_gen(rs1_addr_instr1, rs2_addr_instr1, rs1_addr_instr2, rs2_addr_instr2,
                                i_BRU_buff_3_pkg.rd_buff, 5,
                                i_BRU_buff_3_pkg.valid,
                                i_BRU_buff_3_pkg.fwd_en,
                                expected_fwd_rs1_instr1,
                                expected_fwd_rs2_instr1,
                                expected_fwd_rs1_instr2,
                                expected_fwd_rs2_instr2);


            expected_output_gen(rs1_addr_instr1, rs2_addr_instr1, rs1_addr_instr2, rs2_addr_instr2,
                                i_MEM_buff_pkg.rd_buff, 6,
                                i_MEM_buff_pkg.valid,
                                i_MEM_buff_pkg.fwd_en,
                                expected_fwd_rs1_instr1,
                                expected_fwd_rs2_instr1,
                                expected_fwd_rs1_instr2,
                                expected_fwd_rs2_instr2);

            #5;
            check_results(i+1,
                          fwd_rs1_instr1, expected_fwd_rs1_instr1,
                          fwd_rs2_instr1, expected_fwd_rs2_instr1,
                          fwd_rs1_instr2, expected_fwd_rs1_instr2,
                          fwd_rs2_instr2, expected_fwd_rs2_instr2);
            #20;
      end



        #20;
        $display("Total Passed: %0d, Total Failed: %0d", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end
        $finish;
end



task expected_output_gen(input  [4:0] source_1, source_2,
                         input  [4:0] source_3, source_4,
                         input  [4:0] destination,
                         input  [2:0] location_index,
                         input  valid, fwd_en,
                         ref [6:0] fwd_rs1,
                         ref [6:0] fwd_rs2,
                         ref [6:0] fwd_rs3,
                         ref [6:0] fwd_rs4); 
    begin
        if(valid == 1 && fwd_en == 1) begin
            if(destination == source_1)   fwd_rs1 = fwd_rs1 | (1 << location_index);
            if(destination == source_2)   fwd_rs2 = fwd_rs2 | (1 << location_index);
            if(destination == source_3)   fwd_rs3 = fwd_rs3 | (1 << location_index);
            if(destination == source_4)   fwd_rs4 = fwd_rs4 | (1 << location_index);
        end
    end

endtask



task automatic check_results(input int test_index,
                             input [6:0] fwd_rs1, expected_fwd_rs1,
                             input [6:0] fwd_rs2, expected_fwd_rs2,
                             input [6:0] fwd_rs3, expected_fwd_rs3,
                             input [6:0] fwd_rs4, expected_fwd_rs4);
    // ANSI escape codes for colors
    string green = "\033[32m"; // Green text
    string red   = "\033[31m"; // Red text
    string reset = "\033[0m";  // Reset to default text color

    begin
        $display("Checking test number %0d at time %0t ns", test_index, $time);
        if (fwd_rs1 === expected_fwd_rs1 &&
            fwd_rs2 === expected_fwd_rs2 &&
            fwd_rs3 === expected_fwd_rs3 &&
            fwd_rs4 === expected_fwd_rs4) begin
                $display("%sTest %0d: PASSED%s\n", green, test_index, reset); // Green text for PASSED
                pass_count = pass_count + 1;
        end else begin
            $display("%sTest %0d: FAILED%s", red, test_index, reset);         // Red text for FAILED
            $display("  Actual fwd_rs1_instr1: %h, Expected fwd_rs1_instr1: %h",   fwd_rs1, expected_fwd_rs1);
            $display("  Actual fwd_rs2_instr1: %h, Expected fwd_rs2_instr1: %h",   fwd_rs2, expected_fwd_rs2);
            $display("  Actual fwd_rs1_instr2: %h, Expected fwd_rs1_instr2: %h",   fwd_rs3, expected_fwd_rs3);
            $display("  Actual fwd_rs2_instr2: %h, Expected fwd_rs2_instr2: %h\n", fwd_rs4, expected_fwd_rs4);
            fail_count = fail_count + 1;
        end
    end
endtask



endmodule

