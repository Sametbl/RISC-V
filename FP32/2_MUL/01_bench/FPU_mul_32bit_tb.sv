`timescale 1ns/10ps

module FPU_mul_32bit_tb;

  reg  [31:0] A, B;
  reg  [31:0] expected;
  wire [31:0] M;
  wire        zero, overflow, underflow, NaN;

  int test_number;
  string GREEN = "\033[32m";
  string RED   = "\033[31m";
  string RESET = "\033[0m";

  FPU_mul_32bit dut (
    .A(A),
    .B(B),
    .S(M),
    .overflow(overflow),
    .underflow(underflow),
    .zero(zero),
    .NaN(NaN)
  );

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, dut);
  end

  initial begin
    // Basic Tests

    test_number = 1;
    A = 32'h3F800000; // 1.0
    B = 32'h40000000; // 2.0
    expected = 32'h40000000; // 2.0
    #10;
    check_result(test_number, expected, M, "1.0 * 2.0 => 2.0");

    test_number = 2;
    A = 32'h40400000; // 3.0
    B = 32'h40800000; // 4.0
    expected = 32'h40E00000; // 12.0
    #10;
    check_result(test_number, expected, M, "3.0 * 4.0 => 12.0");

    test_number = 3;
    A = 32'hC0200000; // -2.5
    B = 32'h3F800000; // 1.0
    expected = 32'hC0200000; // -2.5
    #10;
    check_result(test_number, expected, M, "-2.5 * 1.0 => -2.5");

    test_number = 4;
    A = 32'h3F800000; // 1.0
    B = 32'hBF800000; // -1.0
    expected = 32'hBF800000; // -1.0
    #10;
    check_result(test_number, expected, M, "1.0 * -1.0 => -1.0");

    // "Ugly" or Larger Normal Tests

    // 5) ~3.14 * ~2.71
    test_number = 5;
    A = 32'h4048F5C3; // ~3.14
    B = 32'h402AD70A; // ~2.71
    expected = 32'h41084DDC; // ~8.5094
    #10;
    check_result(test_number, expected, M, "3.14 * 2.71 => ~8.51");

    // 6) ~7.89 * ~-3.45
    test_number = 6;
    A = 32'h40FC7AE1; // ~7.89
    B = 32'hC0580000; // ~-3.45
    expected = 32'hC1D9C28F; // ~-27.2205
    #10;
    check_result(test_number, expected, M, "7.89 * -3.45 => ~-27.22");

    // 7) ~123.456 * ~0.789
    test_number = 7;
    A = 32'h42F6E979; // ~123.456
    B = 32'h3F4A3D71; // ~0.789
    expected = 32'h42FE4639; // ~97.403
    #10;
    check_result(test_number, expected, M, "123.456 * 0.789 => ~97.403");

    // 8) ~999.99 * ~-0.01
    test_number = 8;
    A = 32'h447A52C3; // ~999.99
    B = 32'hBC23D70A; // ~-0.01
    expected = 32'hC3780A3D; // ~-9.9999
    #10;
    check_result(test_number, expected, M, "999.99 * -0.01 => ~-9.9999");

    // 9) ~0.123 * ~321.321
    test_number = 9;
    A = 32'h3DFBE77A; // ~0.123
    B = 32'h43A0A51F; // ~321.321
    expected = 32'h42088C41; // ~39.527
    #10;
    check_result(test_number, expected, M, "0.123 * 321.321 => ~39.527");

    // 10) ~-12.34 * ~56.78
    test_number = 10;
    A = 32'hC2466666; // ~-12.34
    B = 32'h425C28F6; // ~56.78
    expected = 32'hC4546F5C; // ~-700.572
    #10;
    check_result(test_number, expected, M, "-12.34 * 56.78 => ~-700.572");

    // Remaining Corner Cases

    test_number = 11;
    A = 32'h7F7FFFFF; // large
    B = 32'h7F7FFFFF; // large
    expected = 32'h7F800000; // +Inf
    #10;
    check_result(test_number, expected, M, "Large * Large => +Inf");

    test_number = 12;
    A = 32'h7F800000; // +Inf
    B = 32'h00000000; // 0.0
    expected = 32'h7FC00000; // NaN
    #10;
    check_result(test_number, expected, M, "+Inf * 0.0 => NaN");

    test_number = 13;
    A = 32'h3F800000; // 1.0
    B = 32'h7FC00000; // NaN
    expected = 32'h7FC00000; // NaN
    #10;
    check_result(test_number, expected, M, "1.0 * NaN => NaN");

    test_number = 14;
    A = 32'hBF800000; // -1.0
    B = 32'hBF800000; // -1.0
    expected = 32'h3F800000; // 1.0
    #10;
    check_result(test_number, expected, M, "-1.0 * -1.0 => 1.0");

    test_number = 15;
    A = 32'h00000001; // smallest subnormal
    B = 32'h00000001; // smallest subnormal
    expected = 32'h00000000; // underflow
    #10;
    check_result(test_number, expected, M, "subnormal * subnormal => 0");

    test_number = 16;
    A = 32'hFF800000; // -Inf
    B = 32'hFF800000; // -Inf
    expected = 32'h7F800000; // +Inf
    #10;
    check_result(test_number, expected, M, "-Inf * -Inf => +Inf");

    $display("Finished multiplication tests.");
    $finish;
  end

  task check_result(
    input int tnum,
    input [31:0] expected_val,
    input [31:0] got,
    input string msg
  );
  begin
    if (got === expected_val)
      $display("%s[PASSED] Test %0d - %s:%s Got=0x%08h, Exp=0x%08h", GREEN, tnum, msg, RESET, got, expected_val);
    else
      $display("%s[FAILED] Test %0d - %s:%s Got=0x%08h, Exp=0x%08h", RED, tnum, msg, RESET, got, expected_val);
  end
  endtask

endmodule
