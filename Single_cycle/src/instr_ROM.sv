module instr_ROM(
        input  logic clk_i, rst_n,
        input  logic [31:0] PC,
        output logic [31:0] instr
);

reg [7:0] instr_mem [0:8191]; // 8KB (2^13)
// Initialize instruction memory
initial $readmemb("00_src/data/load_hex.bin", instr_mem);

reg [12:0] index;
assign index = PC[12:0];

//Read instr
always_ff@(posedge clk_i, negedge rst_n) begin
	if(!rst_n) begin
		instr        <= 32'b0;
	end
	else begin
		instr[7:0]   <= instr_mem[index+3];
		instr[15:8]  <= instr_mem[index+2];
		instr[23:16] <= instr_mem[index+1];
		instr[31:24] <= instr_mem[index];
	end
end

endmodule
