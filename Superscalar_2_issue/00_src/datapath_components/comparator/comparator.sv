module comparator #(parameter int WIDTH = 8)(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    output logic equal,
    output logic larger,
    output logic smaller
);

always_comb begin
    equal   = (A == B);
    larger  = (A >  B);
    smaller = (A <  B);
end

endmodule
