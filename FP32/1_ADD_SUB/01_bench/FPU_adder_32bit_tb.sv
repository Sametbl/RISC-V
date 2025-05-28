`timescale 1ns/1ps

module FPU_adder_32bit_tb;
  reg  [31:0] A, B;    // 32-bit float inputs
  reg  [31:0] expected;
  wire [31:0] S;       // 32-bit float result
  reg         sub;     // 1 => subtraction, 0 => addition
  wire        zero;    
  wire        NaN;
  wire        overflow;
  wire        underflow;

  int test_number;
  string GREEN = "\033[32m";
  string RED   = "\033[31m";
  string RESET = "\033[0m";
  

  FPU_adder_32bit dut (
    .A(A),
    .B(B),
    .S(S),
    .mode(sub),
    .zero(zero),
    .NaN(NaN),
    .overflow(overflow),
    .underflow(underflow)
  );

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, dut);
  end

  initial begin
    #10;
    //  ADDITION TESTS
    sub = 0;           
    // 1) 1.0 + 1.0 = 2.0
    test_number = 1;
    A        = 32'h3F800000; // 1.0
    B        = 32'h3F800000; // 1.0
    expected = 32'h40000000; // 2.0
    #10;
    check_result(test_number, expected, S, "1.0 + 1.0 => 2.0");

    // 2) 2.5 + 3.75 = 6.25
    test_number = 2;
    A        = 32'h40200000; // 2.5
    B        = 32'h40700000; // 3.75
    expected = 32'h40C80000; // 6.25
    #10;
    check_result(test_number, expected, S, "2.5 + 3.75 => 6.25");

    // 3) 2.0 + (-1.0) = 1.0
    test_number = 3;
    A        = 32'h40000000; // 2.0
    B        = 32'hBF800000; // -1.0
    expected = 32'h3F800000; // 1.0
    #10;
    check_result(test_number, expected, S, "2.0 + (-1.0) => 1.0");

    // 4) 0.0 + 5.0 = 5.0
    test_number = 4;
    A        = 32'h00000000; // 0.0
    B        = 32'h40A00000; // 5.0
    expected = 32'h40A00000; // 5.0
    #10;
    check_result(test_number, expected, S, "0.0 + 5.0 => 5.0");


    //  SUBTRACTION TESTS
    sub = 1;  // subtract

    // 5) 1.0 - 2.0 = -1.0
    test_number = 5;
    A        = 32'h3F800000; // 1.0
    B        = 32'h40000000; // 2.0
    expected = 32'hBF800000; // -1.0
    #10;
    check_result(test_number, expected, S, "1.0 - 2.0 => -1.0");

    // 6) 3.75 - 2.5 = 1.25
    test_number = 6;
    A        = 32'h40700000; // 3.75
    B        = 32'h40200000; // 2.5
    expected = 32'h3FA00000; // 1.25
    #10;
    check_result(test_number, expected, S, "3.75 - 2.5 => 1.25");

    // 7) 2.0 - (-1.0) = 3.0
    test_number = 7;
    A        = 32'h40000000; // 2.0
    B        = 32'hBF800000; // -1.0
    expected = 32'h40400000; // 3.0
    #10;
    check_result(test_number, expected, S, "2.0 - (-1.0) => 3.0");

    // 8) 0.0 - 2.5 = -2.5
    test_number = 8;
    A        = 32'h00000000; // 0.0
    B        = 32'h40200000; // 2.5
    expected = 32'hC0200000; // -2.5
    #10;
    check_result(test_number, expected, S, "0.0 - 2.5 => -2.5");


    //------------------------------------------------------------------
    //    ADDITIONAL TESTS (Ugly, Larger Numbers, Special Cases)
    
    // 9) Large + Large => Expect Overflow => +Infinity
    test_number = 9;
    sub      = 0; // addition
    A        = 32'h7F7FFFFF; // ~3.4028234e+38
    B        = 32'h7F7FFFFF; // ~3.4028234e+38
    expected = 32'h7F800000; // +Infinity
    #10;
    check_result(test_number, expected, S, "Large + Large => +Infinity (Overflow)");

    // 10) Very small normal + very small normal
    test_number = 10;
    sub      = 0;  // addition
    A        = 32'h00800000; // smallest normal number
    B        = 32'h00800000; // same
    expected = 32'h01000000; // approximate
    #10;
    check_result(test_number, expected, S, "Smallest normals added => ~0x01000000");

    // 11) Subnormal + Subnormal 
    test_number = 11;
    sub      = 0;  // addition
    A        = 32'h00000001; // subnormal, ~1.4e-45
    B        = 32'h00000001; // same
    expected = 32'h00000002; // a possible subnormal result
    #10;
    check_result(test_number, expected, S, "Subnormal + Subnormal => ~0x00000002");

    // 12) Infinity + Infinity => Infinity
    test_number = 12;
    sub      = 0; // addition
    A        = 32'h7F800000; // +Infinity
    B        = 32'h7F800000; // +Infinity
    expected = 32'h7F800000; // +Infinity
    #10;
    check_result(test_number, expected, S, "(+Infinity) + (+Infinity) => +Infinity");

    // 13) (-Infinity) + (+Infinity) => NaN
    test_number = 13;
    sub      = 0; // addition
    A        = 32'hFF800000;  // -Infinity
    B        = 32'h7F800000;  // +Infinity
    expected = 32'h7FC00000; // canonical NaN
    #10;
    check_result(test_number, expected, S, "(-Infinity) + (+Infinity) => NaN");

    // 14) NaN + 1.0 => NaN
    test_number = 14;
    sub      = 0; // addition
    A        = 32'h7FC00000; // NaN
    B        = 32'h3F800000; // 1.0
    expected = 32'h7FC00000; // NaN
    #10;
    check_result(test_number, expected, S, "NaN + 1.0 => NaN");

    // 15) +0.0 + -0.0 => +0.0 or -0.0
    //     By IEEE standard, +0.0 + -0.0 = +0.0
    test_number = 15;
    sub      = 0; // addition
    A        = 32'h00000000; // +0.0
    B        = 32'h80000000; // -0.0 (sign bit set)
    expected = 32'h00000000; 
    #10;
    check_result(test_number, expected, S, "(+0.0) + (-0.0) => +0.0");


    // 16) Infinity - Infinity => NaN
    test_number = 16;
    sub      = 1; // subtraction
    A        = 32'h7F800000; // +Infinity
    B        = 32'h7F800000; // +Infinity
    expected = 32'h7FC00000; // NaN
    #10;
    check_result(test_number, expected, S, "(+Infinity) - (+Infinity) => NaN");

    // 17) Very large - Very large => 0 or a small number
    test_number = 17;
    sub      = 1; // subtraction
    A        = 32'h7F7FFFFE; // just below largest normal
    B        = 32'h7F7FFFFD; // likewise
    expected = 32'h73800000; 
    #10;
    check_result(test_number, expected, S, "Big - Big => small difference or 0");

    // 18) Subnormal - Subnormal => Possibly 0 => underflow
    test_number = 18;
    sub      = 1; // subtraction
    A        = 32'h00000001; // ~1.4e-45
    B        = 32'h00000001; // same
    expected = 32'h00000000; // +0.0
    #10;
    check_result(test_number, expected, S, "Subnormal - Subnormal => 0");


    // 19) 1.0e-38 - 1.0e-38 => 0 (normal -> subnormal boundary)
    test_number = 19;
    sub      = 1; 
    A        = 32'h00800000; // ~1.1754943508e-38 (smallest normal)
    B        = 32'h00800000; // same
    expected = 32'h00000000; // 0.0
    #10;
    check_result(test_number, expected, S, "1.0e-38 - 1.0e-38 => 0");

    // 20) Negative Overflow: e.g. (-large) - (large) => -Infinity
    test_number = 20;
    sub      = 1; // subtraction
    A        = 32'hFF7FFFFF; // ~ -3.4028234e+38
    B        = 32'h7F7FFFFF;  // ~ +3.4028234e+38
    expected = 32'hFF800000; // -Infinity
    #10;
    check_result(test_number, expected, S, "(-Large) - (+Large) => -Infinity (Overflow)");


   // 21) subnormal + normal
    test_number = 21;
    sub = 0;
    A = 32'h00000001; 
    B = 32'h00800000; 
    expected = 32'h00800001;
    #10;
    check_result(test_number, expected, S, "subnormal + normal");

    // 22) subnormal - normal
    test_number = 22;
    sub = 1;
    A = 32'h00000002;
    B = 32'h00800000;
    expected = 32'h807FFFFE;
    #10;
    check_result(test_number, expected, S, "subnormal - normal");

    // 23) subnormal + Infinity
    test_number = 23;
    sub = 0;
    A = 32'h00000001;
    B = 32'h7F800000;
    expected = 32'h7F800000;
    #10;
    check_result(test_number, expected, S, "subnormal + Infinity");

    // 24) subnormal - Infinity
    test_number = 24;
    sub = 1;
    A = 32'h00000002;
    B = 32'h7F800000;
    expected = 32'hFF800000;
    #10;
    check_result(test_number, expected, S, "subnormal - Infinity");

    // 25) -0.0 + small negative subnormal
    test_number = 25;
    sub = 0;
    A = 32'h80000000;
    B = 32'h80000001;
    expected = 32'h80000001;
    #10;
    check_result(test_number, expected, S, "(-0.0) + small negative subnormal");

    // 26) -0.0 - small negative subnormal
    test_number = 26;
    sub = 1;
    A = 32'h80000000;
    B = 32'h80000001;
    expected = 32'h00000001;
    #10;
    check_result(test_number, expected, S, "(-0.0) - small negative subnormal");

    // 27) normal + negative normal => subnormal
    test_number = 27;
    sub = 0;
    A = 32'h00800001;
    B = 32'h80800002;
    expected = 32'h00000000;
    #10;
    check_result(test_number, expected, S, "normal + negative normal => subnormal");

    // 28) bridging near 2.0
    test_number = 28;
    sub = 0;
    A = 32'h3FFFFFFF; // just below 2.0
    B = 32'h3FFFFFFE; // slightly smaller
    expected = 32'h40000000;
    #10;
    check_result(test_number, expected, S, "bridging near 2.0");

     
    // 29) Infinity + sNaN => NaN
    test_number = 29;
    sub = 0;
    A = 32'h7F800000;
    B = 32'h7F800001; 
    expected = 32'h7FC00000;
    #10;
    check_result(test_number, expected, S, "Infinity + sNaN => NaN");

    // 30) Infinity - sNaN => NaN
    test_number = 30;
    sub = 1;
    A = 32'h7F800000;
    B = 32'h7F800001;
    expected = 32'h7FC00000;
    #10;
    check_result(test_number, expected, S, "Infinity - sNaN => NaN");

    // 31) sNaN + Infinity => NaN
    test_number = 31;
    sub = 0;
    A = 32'h7F800001;
    B = 32'h7F800000;
    expected = 32'h7FC00000;
    #10;
    check_result(test_number, expected, S, "sNaN + Infinity => NaN");

    // 32) sNaN + normal => NaN
    test_number = 32;
    sub = 0;
    A = 32'h7F800001;
    B = 32'h3F800000;
    expected = 32'h7FC00000;
    #10;
    check_result(test_number, expected, S, "sNaN + 1.0 => NaN");

    $display("Finished specific test vectors (including corner cases).");
    $finish;
  end


  task check_result;
    input int    test_index;
    input [31:0] S_expected;
    input [31:0] S_got;
    input string testname; // string for display
  begin
    if (S_got === S_expected)
      $display("%s[PASSED] Test %0d - %s:%s Got = 0x%08h, Expected = 0x%08h", GREEN, test_index, testname, RESET, S_got, S_expected);
    else
      $display("%s[FAILED] Test %0d - %s:%s Got = 0x%08h, Expected = 0x%08h", RED,   test_index, testname, RESET, S_got, S_expected);
  end
  endtask

endmodule
