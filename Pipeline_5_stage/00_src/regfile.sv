module regfile(
        input  logic clk_i, rst_ni, rd_wren,
        input  logic [4:0] rs1_addr, rs2_addr, rd_addr,
        input  logic [31:0] rd_data,
        output logic [31:0] rs1_data, rs2_data
);
wire logic [31:0] reg_en;
reg [31:0] register [0:31];
reg [31:0] regfile [0:31];
// Name each register individually to view them on waveform
wire logic [31:0] R0, R1, R2, R3, R4, R5, R6, R7;
wire logic [31:0] R8, R9, R10, R11, R12, R13, R14, R15;
wire logic [31:0] R16, R17, R18, R19, R20, R21, R22, R23;
wire logic [31:0] R24, R25, R26, R27, R28, R29, R30, R31;

// Initialize regfile
//initial $readmemb("00_src/data/regfile.bin", register);

// Data out: rs1_data, rs2_data
mux_32X1_32bit	  RS1 (.sel(rs1_addr), .Y(rs1_data),
		       .D0(R0),   .D1(R1),   .D2(R2),   .D3(R3),   .D4(R4),   .D5(R5),   .D6(R6),   .D7(R7),
		       .D8(R8),   .D9(R9),   .D10(R10), .D11(R11), .D12(R12), .D13(R13), .D14(R14), .D15(R15),
		       .D16(R16), .D17(R17), .D18(R18), .D19(R19), .D20(R20), .D21(R21), .D22(R22), .D23(R23),
		       .D24(R24), .D25(R25), .D26(R26), .D27(R27), .D28(R28), .D29(R29), .D30(R30), .D31(R31)  );

mux_32X1_32bit	  RS2 (.sel(rs2_addr), .Y(rs2_data),
		       .D0(R0),   .D1(R1),   .D2(R2),   .D3(R3),   .D4(R4),   .D5(R5),   .D6(R6),   .D7(R7),
		       .D8(R8),   .D9(R9),   .D10(R10), .D11(R11), .D12(R12), .D13(R13), .D14(R14), .D15(R15),
		       .D16(R16), .D17(R17), .D18(R18), .D19(R19), .D20(R20), .D21(R21), .D22(R22), .D23(R23),
		       .D24(R24), .D25(R25), .D26(R26), .D27(R27), .D28(R28), .D29(R29), .D30(R30), .D31(R31)  );


// Write data to regfile
decoder_5to32	      wr_sel  (.sel(rd_addr), .en(rd_wren), .Y(reg_en) );
register_32bit		Reg0  (.en(reg_en[0]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R0) ); 
register_32bit		Reg1  (.en(reg_en[1]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R1) ); 
register_32bit		Reg2  (.en(reg_en[2]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R2) ); 
register_32bit		Reg3  (.en(reg_en[3]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R3) ); 
register_32bit		Reg4  (.en(reg_en[4]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R4) ); 
register_32bit		Reg5  (.en(reg_en[5]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R5) ); 
register_32bit		Reg6  (.en(reg_en[6]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R6) ); 
register_32bit		Reg7  (.en(reg_en[7]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R7) ); 
register_32bit		Reg8  (.en(reg_en[8]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R8) ); 
register_32bit		Reg9  (.en(reg_en[9]),  .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R9) ); 
register_32bit		Reg10 (.en(reg_en[10]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R10) ); 
register_32bit		Reg11 (.en(reg_en[11]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R11) ); 
register_32bit		Reg12 (.en(reg_en[12]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R12) ); 
register_32bit		Reg13 (.en(reg_en[13]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R13) ); 
register_32bit		Reg14 (.en(reg_en[14]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R14) ); 
register_32bit		Reg15 (.en(reg_en[15]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R15) ); 
register_32bit		Reg16 (.en(reg_en[16]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R16) ); 
register_32bit		Reg17 (.en(reg_en[17]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R17) ); 
register_32bit		Reg18 (.en(reg_en[18]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R18) ); 
register_32bit		Reg19 (.en(reg_en[19]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R19) ); 
register_32bit		Reg20 (.en(reg_en[20]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R20) ); 
register_32bit		Reg21 (.en(reg_en[21]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R21) ); 
register_32bit		Reg22 (.en(reg_en[22]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R22) ); 
register_32bit		Reg23 (.en(reg_en[23]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R23) ); 
register_32bit		Reg24 (.en(reg_en[24]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R24) ); 
register_32bit		Reg25 (.en(reg_en[25]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R25) ); 
register_32bit		Reg26 (.en(reg_en[26]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R26) ); 
register_32bit		Reg27 (.en(reg_en[27]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R27) ); 
register_32bit		Reg28 (.en(reg_en[28]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R28) ); 
register_32bit		Reg29 (.en(reg_en[29]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R29) ); 
register_32bit		Reg30 (.en(reg_en[30]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R30) ); 
register_32bit		Reg31 (.en(reg_en[31]), .clk(clk_i), .rst_n(rst_ni), .D(rd_data), .Q(R31) ); 


assign register[0] = R0;
assign register[1] = R1;
assign register[2] = R2;
assign register[3] = R3;
assign register[4] = R4;
assign register[5] = R5;
assign register[6] = R6;
assign register[7] = R7;
assign register[8] = R8;
assign register[9] = R9;
assign register[10] = R10;
assign register[11] = R11;
assign register[12] = R12;
assign register[13] = R13;
assign register[14] = R14;
assign register[15] = R15;
assign register[16] = R16;
assign register[17] = R17;
assign register[18] = R18;
assign register[19] = R19;
assign register[20] = R20;
assign register[21] = R21;
assign register[22] = R22;
assign register[23] = R23;
assign register[24] = R24;
assign register[25] = R25;
assign register[26] = R26;
assign register[27] = R27;
assign register[28] = R28;
assign register[29] = R29;
assign register[30] = R30;
assign register[31] = R31;



// Write the data to .data file
//always_ff @(posedge clk_i) begin
//		$writememb("00_src/data/regfile.bin", register);
//end
endmodule
