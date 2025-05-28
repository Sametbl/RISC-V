module singlecycle(
		input  logic clk_i, rst_ni, 
		input  logic [31:0] io_sw_i,
		output logic brsel, 
		output logic [31:0] pc_debug_o, instr_debug_o, next_PC, imm, alu, op_a_data, op_b_data,
		output logic [31:0] io_lcd_o, io_ledg_o, io_ledr_o,
		output logic [31:0] io_hex0_o, io_hex1_o, io_hex2_o, io_hex3_o,
		output logic [31:0] io_hex4_o, io_hex5_o, io_hex6_o, io_hex7_o 
);

// Controller
wire logic br_sel, br_unsigned, rd_wren, mem_wren, mem_byte, mem_halfword;
wire logic op_a_sel, op_b_sel, zero_op_a;
wire logic [31:0] nxt_PC, PC, instr, PC_four;
wire logic [31:0] operand_a, operand_a_temp, operand_b, alu_data, ld_data;
//wire logic [31:0] rs1_data, rs2_data, rd_data, imm;
wire logic [31:0] rs1_data, rs2_data, rd_data;
wire logic [4:0]  rs1, rs2, rd;
wire logic [3:0]  alu_op;
wire logic [1:0]  wb_sel;
wire logic br_less, br_equal, bit4_add;

/////////////// Instuction Fetch ///////////////
//Mux_2X1_32bit     PC_sel   (.A(PC_four), .B(alu_data), .Sel(br_sel), .OUT(nxt_PC) );
//Register_32bit    PC_reg   (.clk(clk_i), .reset(rst_ni), .En(1'b1), .D(nxt_PC), .Q(PC) );
//Mux_2X1_32bit     PC_sel   (.A(PC), .B(alu_data), .Sel(br_sel), .OUT(PC_fetch) );
//instr_ROM         Next_Ins (.clk_i(clk_i), .rst_n(rst_ni), .PC(PC_fetch), .instr(instr) );
//Full_Adder_32bit  PC_add4  (.A(PC_fetch), .B(32'h00000004), .Invert_B(1'b0), .C_in(1'b0), .Sum(nxt_PC), .C_out() );
//Mux_2X1_32bit     PC_sel   (.A(PC_four), .B(alu_data), .Sel(br_sel), .OUT(nxt_PC) );

Mux_2X1_32bit     PC_sel    (.A(PC_four), .B(alu_data), .Sel(br_sel), .OUT(nxt_PC) );
Register_32bit    PC_reg    (.clk(clk_i), .reset(rst_ni), .En(1'b1), .D(nxt_PC), .Q(PC) );
instr_ROM         Next_Ins  (.clk_i(clk_i), .rst_n(rst_ni), .PC(nxt_PC), .instr(instr) );
Full_Adder_32bit  PC_add4   (.A(PC), .B({29'b0, bit4_add, 2'b0}), .Invert_B(1'b0), .C_in(1'b0), .Sum(PC_four), .C_out() );
D_flip_flop       Init_add4 (.clk(clk_i), .clear(rst_ni), .preset(1'b1), .En(1'b1), .D(1'b1), .Q(bit4_add) );  

// Debug signal
assign pc_debug_o = PC>>2;
assign instr_debug_o = instr;
assign next_PC = nxt_PC>>2;
assign alu = alu_data;
assign brsel = br_sel;
assign op_a_data = operand_a;
assign op_b_data = operand_b;
/////////////// Instruction Decode ///////////////
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign rd  = instr[11:7];

regfile 	  reg_32X32 (.clk_i(clk_i), .rst_ni(rst_ni), .rd_wren(rd_wren),
                             .rs1_addr(rs1), .rs2_addr(rs2), .rd_addr(rd),
                             .rd_data(rd_data), .rs1_data(rs1_data), .rs2_data(rs2_data) );

imm_gen           immediate (.instr(instr), .imm(imm) );

Mux_2X1_32bit	  Operand_A (.A(rs1_data), .B(PC_four), .Sel(op_a_sel), .OUT(operand_a_temp) );
Mux_2X1_32bit	  Operand_B (.A(rs2_data), .B(imm), .Sel(op_b_sel), .OUT(operand_b) );
assign operand_a = operand_a_temp & {32{~zero_op_a}};

/////////////// Execute ///////////////
brcomp	      branch_comp (.rs1_data(rs1_data), .rs2_data(rs2_data), .br_unsigned(br_unsigned), . br_less(br_less), .br_equal(br_equal) );
ALU           Compute     (.operand_a(operand_a), .operand_b(operand_b), .alu_op(alu_op), .alu_data(alu_data) );


/////////////// Memory Access ////////////

lsu		LS_IO	  (.clk_i(clk_i), .rst_ni(rst_ni), .st_en(mem_wren),
                           .ld_halfword(mem_halfword), .ld_byte(mem_byte), .addr(alu_data[11:0]), .st_data(rs2_data), .ld_data(ld_data),
                           .io_sw(io_sw_i),     .io_lcd(io_lcd_o),   .io_ledg(io_ledg_o), .io_ledr(io_ledr_o),
                           .io_hex0(io_hex0_o), .io_hex1(io_hex1_o), .io_hex2(io_hex2_o), .io_hex3(io_hex3_o),
                           .io_hex4(io_hex4_o), .io_hex5(io_hex5_o), .io_hex6(io_hex6_o), .io_hex7(io_hex7_o)  );

////////////// Write Back ////////////////

Mux_4X1_32bit    Write_data (.Sel(wb_sel), .I0(alu_data), .I1(ld_data), .I2(PC_four), .I3(PC_four), .OUT(rd_data) );


// CONTROL UNIT

ctrl_unit      Controller  (.instr(instr), .br_less(br_less), .br_equal(br_equal),
                            .br_sel(br_sel), .br_unsigned(br_unsigned),
                            .rd_wren(rd_wren), .mem_wren(mem_wren), .mem_byte(mem_byte), .mem_halfword(mem_halfword),
                            .op_a_sel(op_a_sel), .op_b_sel(op_b_sel), .zero_op_a(zero_op_a), .alu_op(alu_op), .wb_sel(wb_sel) );





endmodule
