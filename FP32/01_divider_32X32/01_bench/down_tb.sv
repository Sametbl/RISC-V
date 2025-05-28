//`timescale 1ns/10ps
module down_tb;

reg       clk;
reg       rst_n;
reg       en;
reg       ld;
reg [7:0] ld_data;
reg [7:0] Q;

down_counter_8bit test (
        .clk(clk), 
        .rst_n(rst_n),
        .en(en),
        .ld(ld),
        .ld_data(ld_data),
        .Q(Q)
);

initial begin
  $dumpfile("wave.vcd"); 
  $dumpvars(0, test);
end

initial begin
    #0 clk = 1;
    forever #5 clk = ~clk;
end

initial begin
#0;
rstn  = 1'b1;
en    = 1'b0;
#20;
ld_data = 8'd42;
ld      = 1'b1;
#20;
ld      = 1'b0;
#500;
$finish;
end

endmodule

