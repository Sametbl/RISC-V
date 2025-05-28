//`timescale 1ns/10ps
module testbench;

  reg [31:0] A, B;
  reg start;
  reg  clk, rstn;
  reg  [31:0] Div_f;
  reg  Done, Error, Inf, NaN, Zero, Ready;

  synth_wrapper    test (.clk_i(clk), .rst_ni(rstn), .start(start), .A(A), .B(B), .Div_f(Div_f),
	                 .Done(Done), .Error(Error), .Inf(Inf), .NaN(NaN), .Zero(Zero), .Ready(Ready)	);

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

