`timescale 1ns/1ps

module divider_32X32_tb;

  reg         clk;
  reg         rstn;
  reg  [31:0] A;
  reg  [31:0] B;
  wire [31:0] quotient;
  wire [31:0] remainder;
  reg         start;
  wire        ready;
  wire        error;

  string GREEN = "\033[32m";
  string RED   = "\033[31m";
  string RESET = "\033[0m";
  reg expected_err;
  
  // Use a constant for the number of iterations
  localparam ITERATION = 100000;
  int expected_quo;
  int expected_rem;
  int pass_count = 0;
  int fail_count = 0;
  int i;

  // Structure to hold failed test case data
  typedef struct {
    int test_index;
    int A_val;
    int B_val;
    int expected_quo;
    int expected_rem;
    int actual_quo;
    int actual_rem;
    int expected_err; // 32-bit for compatibility
    int actual_err;   // 32-bit for compatibility
  } failed_case_t;

  // Array to store failed cases
  failed_case_t failed_cases [ITERATION];
  int fail_case_index = 0;

  // Instantiate the DUT (Device Under Test)
  divider_32X32 test (
    .clk_i(clk),        
    .rst_n(rstn),         
    .start(start),       
    .A(A),              
    .B(B),   
    .quotient(quotient),       
    .remainder(remainder),    
    .ready(ready),       
    .error(error)     
  );

  // Dump waveforms for debugging
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, divider_32X32_tb);
  end

  initial begin
    #0; clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    #0;
    A = 32'b0;
    B = 32'b0;
    rstn  = 1'b0;
    start = 1'b0;
    #10;
    rstn = 1'b1;
    #5;

    for(i = 0; i < ITERATION; i++) begin
          A = $urandom_range(0, 10000);
          B = $urandom_range(0, 10000);
          while (ready == 0) begin #5; end          
          #2;
          start = 1'b1;
          #12;
          start = 1'b0;
          while (ready == 0) begin #5; end
          if (!error) begin
              expected_quo =  A / B;
              expected_rem =  A % B;
          end
          expected_err = (B == 0);

          check_result(i+1, A, B, expected_quo, expected_rem, quotient, remainder, error, expected_err);
          #15;
    end

    $display("\n\nALL TEST CASES COMPLETED.\n");
    $display("%sNumber of tests PASSED: %0d%s.\n",   GREEN, pass_count, RESET);
    $display("%sNumber of tests FAILED: %0d%s.\n\n", RED,   fail_count, RESET);

    // Display failed cases
    if (fail_count > 0) begin
      $display("%sFAILED TEST CASES DETAILS:%s", RED, RESET);
      for (int j = 0; j < fail_case_index; j++) begin
        $display("Test %0d: A = %0d, B = %0d", failed_cases[j].test_index, failed_cases[j].A_val, failed_cases[j].B_val);
        $display("  Expected: Q = %0d, R = %0d, Error = %0d", failed_cases[j].expected_quo, failed_cases[j].expected_rem, failed_cases[j].expected_err);
        $display("  Actual  : Q = %0d, R = %0d, Error = %0d\n", failed_cases[j].actual_quo, failed_cases[j].actual_rem, failed_cases[j].actual_err);
      end
    end

    $finish;
  end

  // Task for printing results in green (pass) or red (fail) and storing failed cases
  task check_result;
    input int test_index;
    input [31:0] A_check;
    input [31:0] B_check;
    input [31:0] expected_quotient;
    input [31:0] expected_remainder;
    input [31:0] actual_quotient;
    input [31:0] actual_remainder;
    input error_flag;
    input expected_error;
    begin
      if ((actual_quotient  == expected_quotient)  && 
          (actual_remainder == expected_remainder) && 
          (error_flag == expected_error)) begin
        $display("[%sTest %0d PASSED%s]: A = %0d, B = %0d, Q = %0d, R = %0d, Error = %0d\n", GREEN, test_index, RESET, A_check, B_check, actual_quotient, actual_remainder, error_flag);
        pass_count = pass_count + 1;
      end else begin
        $display("[%sTest %0d FAILED%s]: A = %0d,\tB = %0d\n", RED, test_index, RESET, A_check, B_check);
        $display("             Actual  : Q = %0d,\tR = %0d,\tError = %0d\n", actual_quotient,   actual_remainder,   error_flag);
        $display("             Expected: Q = %0d,\tR = %0d,\tError = %0d\n", expected_quotient, expected_remainder, expected_error);    
        fail_count = fail_count + 1;

        // Store failed case details
        failed_cases[fail_case_index].test_index    = test_index;
        failed_cases[fail_case_index].A_val         = A_check;
        failed_cases[fail_case_index].B_val         = B_check;
        failed_cases[fail_case_index].expected_quo  = expected_quotient;
        failed_cases[fail_case_index].expected_rem  = expected_remainder;
        failed_cases[fail_case_index].actual_quo    = actual_quotient;
        failed_cases[fail_case_index].actual_rem    = actual_remainder;
        failed_cases[fail_case_index].expected_err  = {31'b0, expected_error}; // Cast to 32-bit
        failed_cases[fail_case_index].actual_err    = {31'b0, error_flag};    // Cast to 32-bit
        fail_case_index = fail_case_index + 1;
      end
    end
  endtask

endmodule
