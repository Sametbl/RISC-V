//`timescale 1ns/10ps
module FPU_div_32bit;

reg [31:0] A;
reg [31:0] B;
reg [31:0] S;
reg        clk,
reg        rst_n;
reg        start;
reg        Done;
reg        Error;
reg        Inf;
reg        NaN;
reg        Zero;
reg        Ready;

  synth_wrapper    test (.clk_i(clk), .rst_n(rst_n), .start(start), .A(A), .B(B), .S(S),
	                 .Done(Done), .Error(Error), .Inf(Inf), .NaN(NaN), .Zero(Zero), .Ready(Ready)	);

  initial begin
    $dumpfile("wave.vcd"); 
    $dumpvars(0, test);
  end

  initial begin
     #0 clk=1;
     forever #1 clk=~clk;
  end

  initial begin
        #0;    rst_n  = 1'b1;
	#0;    start = 1'b0;
        #10;   rst_n  = 1'b0;
	#10;   rst_n  = 1'b1;

	#50;   start = 1'b1;
	#10;   start = 1'b0;

	#200;  start = 1'b1;
	#10;   start = 1'b0;
	
	#200;  start = 1'b1;
	#10;   start = 1'b0;

	#200;  start = 1'b1;
	#10;   start = 1'b0;

	#200;  start = 1'b1;
	#10;   start = 1'b0;

	#200;  start = 1'b1;
	#10;   start = 1'b0;

	#200;  start = 1'b1;
	#10;   start = 1'b0;

	#200;  start = 1'b1;
	#10;   start = 1'b0;
  end

  initial begin
       #0;
       A = 32'b01000000110000000000000000000000;
       B = 32'b01000000010000000000000000000000;
       #200;
       A = 32'b01000000101000000000000000000000;
       B = 32'b01000000000000000000000000000000;
       #200;
       A = 32'b01000001001010000000000000000000;
       B = 32'b00111111010000000000000000000000;
       #200;
       A = 32'b00111111100000000000000000000000;
       B = 32'b01000001100000000000000000000000;
       #200;
       A = 32'b00000000000000000000000000000000;
       B = 32'b01000000011100000000000000000000;
       #200;
       A = 32'b01000000000110000000000000000000;
       B = 32'b00000000000000000000000000000000;
       #200;
       A = 32'b00111111100000000000000000000000;
       B = 32'b00111110100000000000000000000000;
       #200;
       A = 32'b00111111000000000000000000000000;
       B = 32'b01000000000000000000000000000000;
     $finish;
  end


endmodule

