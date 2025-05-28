module ALU(
		input  logic [31:0] operand_a, operand_b,
		input  logic [3:0] alu_op,			
		output logic [31:0] alu_data
);
wire logic [31:0] ADD_SUB, SLT_U, XOR, OR, AND, Shift, Reserved;
wire logic [1:0] Shift_mode;
wire logic Sub_mode, SLTU_mode;

assign Reserved      = 32'b0;
assign SLT_U[31:1]   = 31'b0;
assign Sub_mode      = ~alu_op[3] & ~alu_op[2] & ~alu_op[1] &  alu_op[0];  // When alu_op == 4'b0001
assign SLTU_mode     = ~alu_op[3] & ~alu_op[2] &  alu_op[1] &  alu_op[0];  // When alu_op == 4'b0011

// mode = 2'b00 : shift Right logic (default) , when alu_op == 4'b1000
// mode = 2;b01 : shift Left  logic           , when alu_op == 4'b0111
// mode = 2'b10 : shift Right Arithmetic      , when alu_op == 4'b1001
// mode = 2'b11 : Reserved
assign Shift_mode[0] = ~alu_op[3] &  alu_op[2] &  alu_op[1] &  alu_op[0]; //(4'b0111)
assign Shift_mode[1] =  alu_op[3] & ~alu_op[2] & ~alu_op[1] &  alu_op[0]; //(4'b1001)

// Datapath
Full_Adder_32bit  Ins_ADD_SUB (.A(operand_a), .B(operand_b), .Invert_B(Sub_mode),  .C_in(Sub_mode), .Sum(ADD_SUB), .C_out() );
Comparator_32bit  Ins_SLT_U   (.A(operand_a), .B(operand_b), .Is_unsigned(SLTU_mode), .smaller(SLT_U[0]), .equal(), .larger() );
XOR_gate_32bit    Ins_XOR     (.A(operand_a), .B(operand_b), .S(XOR) );
AND_gate_32bit    Ins_AND     (.A(operand_a), .B(operand_b), .S(AND) );
OR_gate_32bit     Ins_OR      (.A(operand_a), .B(operand_b), .S(OR) );
Shifter_32bit     Ins_S_3mode (.data_in(operand_a), .shift_amount(operand_b[4:0]), .mode(Shift_mode), .data_out(Shift) );



Mux_16X1_32bit	  ALU_out     (.Sel(alu_op), .OUT(alu_data),
                               .I0(ADD_SUB),   .I1(ADD_SUB),   .I2(SLT_U),     .I3(SLT_U),
                               .I4(XOR),       .I5(OR),        .I6(AND),       .I7(Shift),
                               .I8(Shift),     .I9(Shift),     .I10(Reserved), .I11(Reserved),
			       .I12(Reserved), .I13(Reserved), .I14(Reserved), .I15(Reserved)	);


endmodule


