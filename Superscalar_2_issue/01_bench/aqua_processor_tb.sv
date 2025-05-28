module aqua_processor_tb;

reg  clk_i;
reg  rst_ni;
reg [31:0] sw_tb;
reg [31:0] hex_tb [8];
reg [31:0] ledg_tb;
reg [31:0] ledr_tb;
reg [31:0] lcd_tb;

aqua_processor   dutty (
        .clk_i (clk_i)  ,
        .rst_n (rst_ni) ,
        .i_sw  (sw_tb)  ,
        .o_hex (hex_tb) ,
        .o_ledg(ledg_tb),
        .o_ledr(ledr_tb),
        .o_lcd (lcd_tb)
);

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
    #10;   rst_ni  = 1'b0;
    #10;   rst_ni  = 1'b1;
           sw_tb   = 32'h12345678;
    #10000;
    $finish;
end

endmodule

