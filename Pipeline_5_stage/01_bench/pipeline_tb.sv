`timescale 1ns / 1ps
module pipeline_tb;

reg clk_i, rst_ni; 
reg [31:0] io_sw_i;
reg [31:0] pc_debug_o, next_PC, alu;
reg [31:0] io_lcd_o,  io_ledg_o, io_ledr_o;
reg [31:0] io_hex0_o, io_hex1_o, io_hex2_o, io_hex3_o;
reg [31:0] io_hex4_o, io_hex5_o, io_hex6_o, io_hex7_o;
int test_index = 4;

pipeline      dutty (.clk_i(clk_i), .rst_ni(rst_ni), .io_sw_i(io_sw_i), .pc_debug_o(pc_debug_o), .next_PC(next_PC), 
		     .io_lcd_o(io_lcd_o),   .io_ledg_o(io_ledg_o), .io_ledr_o(io_ledr_o), 
		     .io_hex0_o(io_hex0_o), .io_hex1_o(io_hex1_o), .io_hex2_o(io_hex2_o), .io_hex3_o(io_hex3_o),
		     .io_hex4_o(io_hex4_o), .io_hex5_o(io_hex5_o), .io_hex6_o(io_hex6_o), .io_hex7_o(io_hex7_o)   );


initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, dutty);
end

  initial begin
     #0 clk_i=1;
     forever #20 clk_i=~clk_i;
  end

  initial begin
        #0;    rst_ni  = 1'b1;
	#0;    io_sw_i = 32'b0;
        #10;   rst_ni  = 1'b0;
	#10;   rst_ni  = 1'b1;
	#0;    io_sw_i = 32'h10101010;
	#10000;
       $finish;
end

endmodule

