//`timescale 1ns/10ps

module testbench;
  reg  [31:0] A, B;
  reg  [1:0]  Mode;
  reg  clk, rstn;
  reg  [31:0] S, Expected_result;
  reg  NaN, Zero, Inf, start, Done, Ready, Error;

  FPU_32bit     test (.clk_i(clk), .rst_ni(rstn), .A(A), .B(B), .S(S), .start(start), .Mode(Mode),
	              .Zero(Zero), .NaN(NaN), .Inf(Inf), .Done(Done), .Ready(Ready), .Error(Error) );

  initial begin
    $shm_open("waves.shm"); 
    $shm_probe("AS");
  end

  initial begin
     #0 clk=1;
     forever #1 clk=~clk;
  end

  initial begin
        #0;    rstn  = 1'b1;
	#0;    start = 1'b0;
        #10;   rstn  = 1'b0;
	#10;   rstn  = 1'b1;

	// ADD
	#90;   start = 1'b1;
	#10;   start = 1'b0;
	#90;   start = 1'b1;
	#10;   start = 1'b0;
	#90;   start = 1'b1;
	#10;   start = 1'b0;

	// SUB
	#90;   start = 1'b1;
	#10;   start = 1'b0;
	#90;   start = 1'b1;
	#10;   start = 1'b0;
	#90;   start = 1'b1;
	#10;   start = 1'b0;

	// MUL
	#90;   start = 1'b1;
	#10;   start = 1'b0;
	#90;   start = 1'b1;
	#10;   start = 1'b0;
	#40;   start = 1'b1;
	#20;   start = 1'b0;
	#90;   start = 1'b1;
	#10;   start = 1'b0;

	// DIV
	#90;   start = 1'b1;
	#10;   start = 1'b0;
	#90;   start = 1'b1;
	#10;   start = 1'b0;
	#90;   start = 1'b1;
	#10;   start = 1'b0;

	// MUL 0
	#90;   start = 1'b1;
	#10;   start = 1'b0;
	#90;   start = 1'b1;
	#10;   start = 1'b0;

	// Divident 0
	#90;   start = 1'b1;
	#10;   start = 1'b0;

	// DIV 0
	#90;   start = 1'b1;
	#10;   start = 1'b0;

  end

  initial begin
     // Addition
     #0 Mode = 2'b00;
     #100;
     A = 32'h42F76000;   // 123.6875
     B = 32'h42961000;   // 75.03125
     Expected_result = 32'h4346B800; // 198.71876
     #100;
     A = 32'h42F76000;   //  123.6875
     B = 32'hC2F76000;   // -123.6875
     Expected_result = 32'h00000000;   //  0
     #100;
     A = 32'h419E2E14;  //  19.7725
     B = 32'h3EC00000;  //  0.375
     Expected_result = 32'h41A12E14;  //20.1475
     #100;

     // Subtraction
     Mode = 2'b01;
     A = 32'h42F76000;   // 123.6875
     B = 32'h42961000;   // 75.03125
     Expected_result = 32'h4242A000; // 48.65625
     #100;
     A = 32'h42F76000;   //  123.6875
     B = 32'hC2F76000;   // -123.6875
     Expected_result = 32'h43776000;   //  247.375
     #100;
     A = 32'h419E2E14;  //  19.7725
     B = 32'h3EC00000;  //  0.375
     Expected_result = 32'h419B2E14;  //  19.3975
     #100;

     // Multiplication
     Mode = 2'b10;
     A = 32'h42F76000;   // 123.6875
     B = 32'h42961000;   // 75.03125
     Expected_result = 32'h461101B6; // 9280.427734
     #100;
     A = 32'h42F76000;   //  123.6875
     B = 32'hC2F76000;   // -123.6875
     Expected_result = 32'hC66F0A64;   //  -15298.59766
     #100;
     A = 32'h419E2E14;  //  19.7725
     B = 32'h3EC00000;  //  0.375
     Expected_result = 32'h40ED451F;  //  7.4146875
     #100;

     // Division
     Mode = 2'b11;
     A = 32'h42F76000;   // 123.6875
     B = 32'h42961000;   // 75.03125
     Expected_result = 32'h3FD30163; // 1.6484798
     #100;
     A = 32'h42F76000;   //  123.6875
     B = 32'hC2F76000;   // -123.6875
     Expected_result = 32'hBF800000;   //  -1
     #100;
     A = 32'h419E2E14;  //  19.7725
     B = 32'h3EC00000;  //  0.375
     Expected_result = 32'h4252E81B;  //  52.72(6)
     #100;
     
     // Multiply by 0
     Mode = 2'b10;
     A = 32'h42F76000;   // 123.6875
     B = 32'h00000000;   // 0
     Expected_result = 32'h00000000; // 0
     #100;
     A = 32'h00000000;   //  123.6875
     B = 32'hC2F76000;   // -123.6875
     Expected_result = 32'h00000000;   //  0
     #100;

     // Divident is 0
     Mode = 2'b11;
     A = 32'h00000000;   // 0
     B = 32'h42961000;   // 75.03125
     Expected_result = 32'h00000000; // 0
     #100;

     // Divide by 0 (Error)
     Mode = 2'b11;
     A = 32'h42961000;   // 75.03125
     B = 32'h00000000;   // 0
     // No Expected_result 



    $finish;
     end

endmodule

