module regfile(
        input  logic clk_i, rst_ni, rd_wren,
        input  logic [4:0] rs1_addr, rs2_addr, rd_addr,
        input  logic [31:0] rd_data,
        output logic [31:0] rs1_data, rs2_data
);
wire logic [31:0] reg_en;
reg [31:0] register [0:31];

// Initialize regfile
initial $readmemb("00_src/data/regfile.bin", register);

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


// Write data to regfile
decoder_5to32	 wr_sel (.In(rd_addr), .En(rd_wren), .Q(reg_en) );
Register_32bit		R0  (.En(reg_en[0]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[0]) ); 
Register_32bit		R1  (.En(reg_en[1]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[1]) ); 
Register_32bit		R2  (.En(reg_en[2]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[2]) ); 
Register_32bit		R3  (.En(reg_en[3]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[3]) ); 
Register_32bit		R4  (.En(reg_en[4]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[4]) ); 
Register_32bit		R5  (.En(reg_en[5]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[5]) ); 
Register_32bit		R6  (.En(reg_en[6]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[6]) ); 
Register_32bit		R7  (.En(reg_en[7]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[7]) ); 
Register_32bit		R8  (.En(reg_en[8]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[8]) ); 
Register_32bit		R9  (.En(reg_en[9]),  .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[9]) ); 
Register_32bit		R10 (.En(reg_en[10]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[10]) ); 
Register_32bit		R11 (.En(reg_en[11]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[11]) ); 
Register_32bit		R12 (.En(reg_en[12]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[12]) ); 
Register_32bit		R13 (.En(reg_en[13]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[13]) ); 
Register_32bit		R14 (.En(reg_en[14]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[14]) ); 
Register_32bit		R15 (.En(reg_en[15]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[15]) ); 
Register_32bit		R16 (.En(reg_en[16]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[16]) ); 
Register_32bit		R17 (.En(reg_en[17]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[17]) ); 
Register_32bit		R18 (.En(reg_en[18]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[18]) ); 
Register_32bit		R19 (.En(reg_en[19]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[19]) ); 
Register_32bit		R20 (.En(reg_en[20]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[20]) ); 
Register_32bit		R21 (.En(reg_en[21]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[21]) ); 
Register_32bit		R22 (.En(reg_en[22]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[22]) ); 
Register_32bit		R23 (.En(reg_en[23]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[23]) ); 
Register_32bit		R24 (.En(reg_en[24]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[24]) ); 
Register_32bit		R25 (.En(reg_en[25]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[25]) ); 
Register_32bit		R26 (.En(reg_en[26]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[26]) ); 
Register_32bit		R27 (.En(reg_en[27]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[27]) ); 
Register_32bit		R28 (.En(reg_en[28]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[28]) ); 
Register_32bit		R29 (.En(reg_en[29]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[29]) ); 
Register_32bit		R30 (.En(reg_en[30]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[30]) ); 
Register_32bit		R31 (.En(reg_en[31]), .clk(clk_i), .reset(rst_ni), .D(rd_data), .Q(register[31]) ); 

// Write the data to .data file
always_ff @(posedge clk_i) begin
		$writememb("00_src/data/regfile.bin", register);
end
endmodule
