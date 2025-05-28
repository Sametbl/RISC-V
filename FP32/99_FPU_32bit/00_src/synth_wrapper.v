module synth_wrapper(
	input wire [31:0] A, B, 
	input wire clk, rst_n, start, 
	input wire [1:0] Mode,
	output reg [31:0] S,
	output reg Zero, NaN, Inf, Ready, Done, Error
);

reg [31:0] A_reg, B_reg, S_reg;
reg [1:0] mode_reg;
reg Zero_reg, NaN_reg, Inf_reg, Ready_reg, Done_reg, Error_reg, start_reg;

always@(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		A_reg     <= 32'b0;
		B_reg     <= 32'b0;
		start_reg <= 1'b0;
		mode_reg  <= 2'b0;

		S         <= 32'b0;
		NaN       <= 1'b0;
		Zero      <= 1'b0;
		Inf       <= 1'b0;
		Ready     <= 1'b0;
		Done      <= 1'b0;
		Error     <= 1'b0;
	end
	else begin 
		A_reg     <= A;
		B_reg     <= B;
		start_reg <= start;
		mode_reg  <= Mode;

		S         <= S_reg;
		NaN       <= NaN_reg;
		Zero      <= Zero_reg;
		Inf       <= Inf_reg;
		Ready     <= Ready_reg;
		Done      <= Done_reg;
		Error     <= Error_reg;
	end
end


FPU_32bit       test (.clk_i(clk), .rst_ni(rst_n), .start(start_reg), .Mode(mode_reg),
		      .A(A_reg), .B(B_reg), .S(S_reg), .NaN(NaN_reg), .Inf(Inf_reg), .Zero(Zero_reg),
	      	      .Done(Done_reg), .Ready(Ready_reg), .Error(Error_reg)    );
endmodule
