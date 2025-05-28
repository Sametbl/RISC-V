module mux #(parameter int WIDTH     = 32,
             parameter int NUM_INPUT = 2   )
(
    input  logic [$clog2(NUM_INPUT)-1:0] sel,
    input  logic [NUM_INPUT-1:0][WIDTH-1:0] i_mux, // Packed array
    output logic [WIDTH-1:0] o_mux
);

assign o_mux = i_mux[sel];  // Now legal indexing

endmodule
