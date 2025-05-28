module regfile_2(
	input  logic clk_i, rst_ni, rd_wren,
	input  logic [4:0] rs1_addr, rs2_addr, rd_addr,
    input  logic [31:0] rd_data,
	output logic [31:0] rs1_data, rs2_data
);

reg [31:0] register [31:0];

// Initialize regfile
initial $readmemb("regfile.bin", register);

// Data out: rs1_data, rs2_data
Mux_32X1_32bit	  RS1 (.Sel(rs1_addr), .OUT(rs1_data),
					   .I0(register[0]),   .I1(register[1]),   .I2(register[2]),   .I3(register[3]),   .I4(register[4]),   .I5(register[5]),   .I6(register[6]),   .I7(register[7]),
					   .I8(register[8]),   .I9(register[9]),   .I10(register[10]), .I11(register[11]), .I12(register[12]), .I13(register[13]), .I14(register[14]), .I15(register[15]),
					   .I16(register[16]), .I17(register[17]), .I18(register[18]), .I19(register[19]), .I20(register[20]), .I21(register[21]), .I22(register[22]), .I23(register[23]),
					   .I24(register[24]), .I25(register[25]), .I26(register[26]), .I27(register[27]), .I28(register[28]), .I29(register[29]), .I30(register[30]), .I31(register[31])  );

Mux_32X1_32bit	  RS2 (.Sel(rs2_addr), .OUT(rs2_data),
					   .I0(register[0]),   .I1(register[1]),   .I2(register[2]),   .I3(register[3]),   .I4(register[4]),   .I5(register[5]),   .I6(register[6]),   .I7(register[7]),
					   .I8(register[8]),   .I9(register[9]),   .I10(register[10]), .I11(register[11]), .I12(register[12]), .I13(register[13]), .I14(register[14]), .I15(register[15]),
					   .I16(register[16]), .I17(register[17]), .I18(register[18]), .I19(register[19]), .I20(register[20]), .I21(register[21]), .I22(register[22]), .I23(register[23]),
					   .I24(register[24]), .I25(register[25]), .I26(register[26]), .I27(register[27]), .I28(register[28]), .I29(register[29]), .I30(register[30]), .I31(register[31])  );

// Write
always_ff @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			for (integer i = 0; i < 32; i = i + 1) begin
				register[i] <= 32'b0;
			end
		end
		else if (rd_wren) begin
				register[rd_addr] <= rd_data;
		end
end

// Write the data to .data file
always_ff @(posedge clk_i) begin
		$writememb("regfile.bin", register);
end

endmodule


/*
reg [31:0] regfile [31:0];

// Initialize regfile
initial $readmemb("regfile.bin", regfile);

//Read
always_comb begin
	rs1_data = regfile[rs1_addr];
	rs2_data = regfile[rs2_addr];
end

// Write
always_ff @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			for (integer i = 0; i < 32; i = i + 1) begin
				regfile[i] <= 32'b0;
			end
		end
		else if (rd_wren) begin
				regfile[rd_addr] <= rd_data;
		end
end

// Write the data to .data file
always_ff @(posedge clk_i) begin
		$writememb("regfile.bin", regfile);
end

endmodule

*/