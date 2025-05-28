module register #(parameter int WIDTH = 32)
(
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 en,
    input  logic [WIDTH - 1 : 0] D,
    output logic [WIDTH - 1 : 0] Q
);

always_ff@(posedge clk, negedge rst_n) begin
        if(!rst_n)              Q  <=  0;
        else if(en)             Q  <=  D;
        else                    Q  <=  Q;
end
endmodule
