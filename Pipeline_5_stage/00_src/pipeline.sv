module pipeline(
		input  logic clk_i, rst_ni, 
		input  logic [31:0] io_sw_i,
		output logic [31:0] pc_debug_o, next_PC,
		output logic [31:0] io_lcd_o,  io_ledg_o, io_ledr_o,
		output logic [31:0] io_hex0_o, io_hex1_o, io_hex2_o, io_hex3_o,
		output logic [31:0] io_hex4_o, io_hex5_o, io_hex6_o, io_hex7_o 
);

wire logic [31:0] nxt_PC, PC, instr, PC_four, BTB_PC, alu_PC, PC_for_BTB;
wire logic [31:0] operand_a, operand_b, PC_before_branch, br_PC_ID, br_PC_EX, br_PC_MEM;
wire logic [1:0]  select_PC;
wire logic br_sel_EX_MEM, bit4_add;
wire logic instr_fetch_en, IF_buffer_en;
wire logic predicted_bit, br_taken, br_result;  // br_result: result of branch instruciton is complete (taken or not taken)
wire logic BTB_br_taken, BTB_taken_ID, BTB_taken_EX, BTB_already_taken;
wire logic br_not_taken_miss, br_taken_miss, flush, Hit;

////////////////////////// IF Stage //////////////////////////////
wire logic [31:0] PC_four_ID, PC_four_EX, PC_four_MEM, PC_four_WB;

mux_4X1_32bit     PC_sel    (.D0(PC_four), .D1(alu_PC), .D2(BTB_PC), .D3(PC_before_branch), .sel(select_PC), .Y(nxt_PC) );
register_32bit    PC_reg    (.clk(clk_i),   .rst_n(rst_ni), .en  (instr_fetch_en), .D(nxt_PC), .Q(PC) );
instr_ROM         Next_Ins  (.clk_i(clk_i), .rst_n(rst_ni), .rden(instr_fetch_en & ~flush), .PC(PC), .instr(instr) );
full_adder_32bit  PC_add4   (.A(PC), .B({29'b0, bit4_add, 2'b0}), .Invert_B(1'b0), .C_in(1'b0), .Sum(PC_four), .C_out() );
D_flip_flop       Init_add4 (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(1'b1), .Q(bit4_add) );  

//mux_2X1_32bit	store_br_PC (.A(PC), .B(br_PC_MEM), .sel(br_result),  .Y(PC_for_BTB) );
branch_unit       PRD       (.clk_i(clk_i), .rst_n(rst_ni), .PC_fetch(PC), .prd_target(BTB_PC), .prd_taken(BTB_br_taken),
                             .br_update(br_result), .br_update_PC(PC_four_MEM), .br_update_taken(br_taken), .br_update_target(alu_PC)       );



// select_PC = 2'b00:     next_PC = PC + 4           (default)
// select_PC = 2'b01:     next_PC = alu_PC           (When BTB missed or "Not taken" mis-prediction)
// select_PC = 2'b10:     next_PC = BTB_PC           (When BTB hit and taken)
// select_PC = 2'b11:     next_PC = PC_before_branch (When BTB hit and taken but it is misprediction)
assign select_PC[0] = (br_not_taken_miss) | (br_taken_miss);
assign select_PC[1] = (BTB_br_taken)      | (br_taken_miss);

assign br_not_taken_miss =  br_result &  br_taken & ~BTB_taken_EX; // BTB "Not-taken" mis-prediction OR BTB miss
assign br_taken_miss     =  br_result & ~br_taken &  BTB_taken_EX; // BTB "Taken" mis-prediction 
assign flush  = br_not_taken_miss | br_taken_miss;

// Buffer to ID stage
register_32bit    br_PC_buffer_ID  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(IF_buffer_en), .D(PC), .Q(br_PC_ID) );
register_32bit    PC4_buffer_ID    (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(IF_buffer_en), .D(PC_four), .Q(PC_four_ID) );

// In case prediction is incorrect and we need to restore that previous PC
// Target provided by ALU always taken unless "BTB_already_taken" == 1'b1
register_32bit    Br_restore_PC    (.clk(clk_i), .rst_n(rst_ni), .en(br_result &  br_taken), .D(PC_four), .Q(PC_before_branch) );



////////////////////////// ID Stage /////////////////////////////////

wire logic [31:0] rs1_data, rs1_data_EX, imm;
wire logic [31:0] rs2_data, rs2_data_EX, rs2_data_MEM, WB_data;
wire logic [31:0] imm_EX, rs1_data_forward, rs2_data_forward;
wire logic [4:0]  rs1, rs1_EX;
wire logic [4:0]  rs2, rs2_EX;
wire logic [4:0]  rd, rd_EX, rd_MEM, rd_WB;
wire logic [3:0]  alu_op, alu_op_EX;
wire logic [1:0]  wb_sel, wb_sel_EX, wb_sel_MEM, wb_sel_WB;
wire logic op_a_PC, op_b_imm, op_a_PC_EX, op_b_imm_EX;
wire logic br_instr, br_instr_EX;
wire logic br_unsigned, br_unsigned_EX, zero_op_a, zero_op_a_EX;
wire logic rd_wren,  rd_wren_EX,  rd_wren_MEM,  rd_wren_WB;
wire logic mem_wren, mem_wren_EX, mem_wren_MEM;
wire logic mem_byte,     mem_byte_EX,     mem_byte_MEM;
wire logic mem_halfword, mem_halfword_EX, mem_halfword_MEM;
wire logic BEQ_on, BNE_on, BLT_U,    BGE_U,    JAL_on, JALR_on;
wire logic BEQ_EX, BNE_EX, BLT_U_EX, BGE_U_EX, JAL_EX, JALR_EX;
wire logic NONE_RS1, NONE_RS2,   NONE_RS1_EX, NONE_RS2_EX;
wire logic NONE_RD,  NONE_RD_EX, NONE_RD_MEM, NONE_RD_WB;
wire logic ForwardA_WB_ID, ForwardB_WB_ID;
wire logic MemRead, MemRead_EX, NOP;


assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign rd  = instr[11:7];

regfile            reg_32X32    (.clk_i(clk_i), .rst_ni(rst_ni), .rd_wren(rd_wren_WB),
                                 .rs1_addr(rs1), .rs2_addr(rs2), .rd_addr(rd_WB),
                                 .rd_data(WB_data), .rs1_data(rs1_data), .rs2_data(rs2_data) );

imm_gen            immediate    (.instr(instr), .imm(imm) );


// CONTROL UNIT
ctrl_unit           Controller  (.instr(instr), .br_unsigned(br_unsigned), .BEQ(BEQ_on), .BNE(BNE_on), .BLT_U(BLT_U), .BGE_U(BGE_U), .branch(br_instr),
                                 .rd_wren(rd_wren), .mem_wren(mem_wren), .mem_byte(mem_byte), .mem_halfword(mem_halfword), .MemRead(MemRead),
                                 .op_a_PC(op_a_PC), .op_b_imm(op_b_imm), .zero_op_a(zero_op_a), .alu_op(alu_op), .wb_sel(wb_sel),
                                 .NONE_RS1(NONE_RS1), .NONE_RS2(NONE_RS2), .NONE_RD(NONE_RD), .JAL(JAL_on), .JALR(JALR_on) );


hazard_detection    read_B4_LD  (.rs1_ID(rs1), .rs2_ID(rs2), .rd_EX(rd_EX), .MemRead_EX(MemRead_EX),
                                 .IF_buffer_Write(IF_buffer_en), .PC_Write(instr_fetch_en), .NOP(NOP) );          


// Buffer to EX stage
mux_2X1_32bit	  WB_to_ID_rs1 (.A(rs1_data), .B(WB_data), .sel(ForwardA_WB_ID),  .Y(rs1_data_forward) );
mux_2X1_32bit	  WB_to_ID_rs2 (.A(rs2_data), .B(WB_data), .sel(ForwardB_WB_ID),  .Y(rs2_data_forward) );

register_32bit    br_PC_buffer_EX     (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(br_PC_ID), .Q(br_PC_EX) );
register_32bit    PC4_buffer_EX       (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(PC_four_ID), .Q(PC_four_EX) );
register_32bit    RS1_data_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(rs1_data_forward), .Q(rs1_data_EX) );
register_32bit    RS2_data_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(rs2_data_forward), .Q(rs2_data_EX) );
register_32bit    imm_buffer_EX       (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(imm),  .Q(imm_EX)  );

register_4bit     alu_op_buffer_EX    (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(alu_op),  .Q(alu_op_EX)  );
register_5bit     RS1_buffer_EX       (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(rs1),     .Q(rs1_EX)  );
register_5bit     RS2_buffer_EX       (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(rs2),     .Q(rs2_EX)  );
register_5bit     RD_buffer_EX        (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(1'b1), .D(rd),      .Q(rd_EX)  );

D_flip_flop       op_a_sel_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(op_a_PC),   .Q(op_a_PC_EX) );  
D_flip_flop       op_b_sel_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(op_b_imm),  .Q(op_b_imm_EX) );  
D_flip_flop       NONE_RS1_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(NONE_RS1),  .Q(NONE_RS1_EX) );  
D_flip_flop       NONE_RS2_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(NONE_RS2),  .Q(NONE_RS2_EX) );  
D_flip_flop       NONE_RD_buffer_EX   (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(NONE_RD),   .Q(NONE_RD_EX) );  
D_flip_flop       zero_op_A_buffer_EX (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(zero_op_a), .Q(zero_op_a_EX) );  

D_flip_flop       jal_signal_EX       (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(JAL_on),   .Q(JAL_EX) );  
D_flip_flop       jalr_signal_EX      (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(JALR_on),  .Q(JALR_EX) );  
D_flip_flop       BEQ_signal_EX       (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(BEQ_on),   .Q(BEQ_EX) );  
D_flip_flop       BNE_signal_EX       (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(BNE_on),   .Q(BNE_EX) );  
D_flip_flop       BLT_signal_EX       (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(BLT_U),    .Q(BLT_U_EX) );  
D_flip_flop       BGE_signal_EX       (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(BGE_U),    .Q(BGE_U_EX) );  
D_flip_flop       br_instr_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(br_instr), .Q(br_instr_EX) );  


D_flip_flop       wren_buffer_EX      (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(rd_wren),     .Q(rd_wren_EX) );  
D_flip_flop       wb_sel0_buffer_EX   (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(wb_sel[0]),   .Q(wb_sel_EX[0]) );  
D_flip_flop       wb_sel1_buffer_EX   (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(wb_sel[1]),   .Q(wb_sel_EX[1]) );  
D_flip_flop       br_unsign_buffer_EX (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(br_unsigned), .Q(br_unsigned_EX) );  


D_flip_flop       MemRead_buffer_EX   (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(MemRead),      .Q(MemRead_EX) );  
D_flip_flop       mem_wren_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(mem_wren),     .Q(mem_wren_EX) );  
D_flip_flop       halfword_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(mem_halfword), .Q(mem_halfword_EX) );  
D_flip_flop       readbyte_buffer_EX  (.clk(clk_i), .rst_n(rst_ni & ~flush), .en(~NOP), .D(mem_byte),     .Q(mem_byte_EX) );  
D_flip_flop       br_already_taken_EX (.clk(clk_i), .rst_n(rst_ni),          .en(~NOP), .D(BTB_br_taken), .Q(BTB_taken_ID) );  




/////////////////////////// EX stage /////////////////////////////////
wire logic [31:0] alu_data_EX, alu_data_MEM, alu_data_WB, operand_a_temp;
wire logic [31:0] rs1_data_Forwarded, rs2_data_Forwarded;
wire logic [31:0] pc_ex;
wire logic [1:0] rs1_sel, rs2_sel;
wire logic br_less, br_equal, br_greater, br_taken_EX;
wire logic ForwardA_MEM, ForwardA_WB, ForwardB_MEM, ForwardB_WB;

assign rs1_sel[0] = ForwardA_MEM;
assign rs1_sel[1] = ForwardA_WB & ~ForwardA_MEM; // prefer Forwarding from MEM and WB

assign rs2_sel[0] = ForwardB_MEM;
assign rs2_sel[1] = ForwardB_WB & ~ForwardB_MEM;

assign operand_a = operand_a_temp & {32{~zero_op_a_EX}};

mux_4X1_32bit	  rs1_data_sel   (.D0(rs1_data_EX), .D1(alu_data_MEM), .D2(WB_data), .D3(WB_data), .sel(rs1_sel), .Y(rs1_data_Forwarded) );
mux_4X1_32bit	  rs2_data_sel   (.D0(rs2_data_EX), .D1(alu_data_MEM), .D2(WB_data), .D3(WB_data), .sel(rs2_sel), .Y(rs2_data_Forwarded) );

full_adder_32bit  curr_pc        (.A(PC_four_EX), .B(32'd4), .Invert_B(1'b1),  .C_in(1'b1), .Sum(pc_ex), .C_out() );
mux_2X1_32bit	  Operand_A_sel (.A(rs1_data_Forwarded), .B(pc_ex),  .sel(op_a_PC_EX),  .Y(operand_a_temp) );
mux_2X1_32bit	  Operand_B_sel (.A(rs2_data_Forwarded), .B(imm_EX), .sel(op_b_imm_EX), .Y(operand_b) );
alu               alu_exe       (.operand_a(operand_a), .operand_b(operand_b), .alu_op(alu_op_EX), .alu_data(alu_data_EX) );

brcomp	          branch_comp   (.rs1_data(rs1_data_Forwarded), .rs2_data(rs2_data_Forwarded), .br_unsigned(br_unsigned_EX),
	                             .br_less(br_less), .br_equal(br_equal), .br_greater(br_greater) );

assign br_taken_EX =  ( br_equal & BEQ_EX) | (~br_equal & BNE_EX) | (br_less & BLT_U_EX) | ( (br_greater | br_equal) & BGE_U_EX) | JAL_EX | JALR_EX;


forwarding_unit   forwarding  (.rs1_ID(rs1), .rs2_ID(rs2), .rs1_EX(rs1_EX), .rs2_EX(rs2_EX), .NONE_RS1_EX(NONE_RS1_EX), .NONE_RS2_EX(NONE_RS2_EX), 
                               .NONE_RS1_ID(NONE_RS1), .NONE_RS2_ID(NONE_RS2), .ForwardA_WB_ID(ForwardA_WB_ID), .ForwardB_WB_ID(ForwardB_WB_ID),
                               .MEM_rd(rd_MEM), .WB_rd(rd_WB), .WB_MEM(rd_wren_MEM), .WB_WB(rd_wren_WB), .NONE_RD_MEM(NONE_RD_MEM), .NONE_RD_WB(NONE_RD_WB),
                               .ForwardA_MEM(ForwardA_MEM), .ForwardB_MEM(ForwardB_MEM), .ForwardA_WB(ForwardA_WB), .ForwardB_WB(ForwardB_WB) );


// Buffer to MEM stage
register_32bit    br_PC_buffer_MEM (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(br_PC_EX  ), .Q(br_PC_MEM) );
register_32bit    PC4_buffer_MEM   (.clk(clk_i), .rst_n(rst_ni), .en(~NOP), .D(PC_four_EX), .Q(PC_four_MEM) );
register_32bit    RS2_buffer_MEM   (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(rs2_data_Forwarded), .Q(rs2_data_MEM) );
register_32bit    ALU_buffer_MEM   (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(alu_data_EX), .Q(alu_data_MEM) );
register_5bit     RD_buffer_MEM    (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(rd_EX),       .Q(rd_MEM)  );

D_flip_flop       wren_buffer_MEM     (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(rd_wren_EX),   .Q(rd_wren_MEM) );  
D_flip_flop       wb_sel0_buffer_MEM  (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(wb_sel_EX[0]), .Q(wb_sel_MEM[0]) );  
D_flip_flop       wb_sel1_buffer_MEM  (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(wb_sel_EX[1]), .Q(wb_sel_MEM[1]) );  
D_flip_flop       NONE_RD_buffer_MEM  (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(NONE_RD_EX),   .Q(NONE_RD_MEM) );  

D_flip_flop       mem_wren_buffer_MEM (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(mem_wren_EX),     .Q(mem_wren_MEM) );  
D_flip_flop       halfword_buffer_MEM (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(mem_halfword_EX), .Q(mem_halfword_MEM) );  
D_flip_flop       readbyte_buffer_MEM (.clk(clk_i), .rst_n(rst_ni), .en(~br_taken), .D(mem_byte_EX),     .Q(mem_byte_MEM) );  

register_32bit    BR_buffer_MEM        (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(alu_data_EX),  .Q(alu_PC) );
D_flip_flop       br_already_taken_MEM (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(BTB_taken_ID), .Q(BTB_taken_EX) );  
D_flip_flop       br_instr_buffer_MEM  (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(br_instr_EX),  .Q(br_result) );  
D_flip_flop       br_sel_buffer_MEM    (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(br_taken_EX),  .Q(br_taken) );  




//////////////////////////// MEM stage ///////////////////////////////
wire logic [31:0] ld_data, ld_data_WB;


lsu            LS_IO      (.clk_i(clk_i), .rst_ni(rst_ni), .st_en(mem_wren_MEM),
                           .ld_halfword(mem_halfword_MEM), .ld_byte(mem_byte_MEM), .addr(alu_data_MEM[11:0]), .st_data(rs2_data_MEM), .ld_data(ld_data),
                           .io_sw(io_sw_i),     .io_lcd(io_lcd_o),   .io_ledg(io_ledg_o), .io_ledr(io_ledr_o),
                           .io_hex0(io_hex0_o), .io_hex1(io_hex1_o), .io_hex2(io_hex2_o), .io_hex3(io_hex3_o),
                           .io_hex4(io_hex4_o), .io_hex5(io_hex5_o), .io_hex6(io_hex6_o), .io_hex7(io_hex7_o)  );


// Buffer to WB stage
register_32bit    PC_buffer_WB     (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(PC_four_MEM),  .Q(PC_four_WB) );
register_32bit    ALU_buffer_WB    (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(alu_data_MEM), .Q(alu_data_WB) );
register_32bit    LD_buffer_WB     (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(ld_data),      .Q(ld_data_WB) );
register_5bit     RD_buffer_WB     (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(rd_MEM),       .Q(rd_WB)  );

D_flip_flop       NONE_RD_buffer_WB   (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(NONE_RD_MEM),   .Q(NONE_RD_WB) );  
D_flip_flop       wren_buffer_WB      (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(rd_wren_MEM),   .Q(rd_wren_WB) );  
D_flip_flop       wb_sel0_buffer_WB   (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(wb_sel_MEM[0]), .Q(wb_sel_WB[0]) );  
D_flip_flop       wb_sel1_buffer_WB   (.clk(clk_i), .rst_n(rst_ni), .en(1'b1), .D(wb_sel_MEM[1]), .Q(wb_sel_WB[1]) );  

//////////////////////////// Write Back ///////////////////////////////

mux_4X1_32bit    Write_data (.sel(wb_sel_WB), .D0(alu_data_WB), .D1(ld_data_WB), .D2(PC_four_WB), .D3(PC_four_WB), .Y(WB_data) );









































































// DEBUG



// Verilator lint_off LATCH
//////////////////////////////////
//////////////////////////////////
//////////////////////////////////
////////////////////////////////// Debug signal
assign pc_debug_o = PC>>2;
assign next_PC = nxt_PC>>2;

// Show Current Instruction (For debugginh)
typedef enum bit [5:0] {
    LUI       = 6'b000000,
    AUIPC     = 6'b000001,
    JAL       = 6'b000010,      
    JALR      = 6'b000011,
    BEQ       = 6'b000100,
    BNE       = 6'b000101,
    BLT       = 6'b000110,
    BGE       = 6'b000111,
    BLTU      = 6'b001000,
    BGEU      = 6'b001001,
    LB        = 6'b001010,
    LH        = 6'b001011,
    LW        = 6'b001100,
    LBU       = 6'b001101,
    LHU       = 6'b001110,
    SB        = 6'b001111,
    SH        = 6'b010000,
    SW        = 6'b010001,
    ADDI      = 6'b010010,
    SLTI      = 6'b010011,
    SLTIU     = 6'b010100,
    XORI      = 6'b010101,
    ORI       = 6'b010110,
    ANDI      = 6'b010111,
    ADD       = 6'b011000,
    SUB       = 6'b011001,
    SLL       = 6'b011010,
    SLT       = 6'b011011,
    SLTU      = 6'b011100,
    XOR       = 6'b011101,
    SRL       = 6'b011110,
    SRA       = 6'b011111,
    OR        = 6'b100000,
    AND       = 6'b100001,
    FENCE     = 6'b100010,
    ECALL     = 6'b100011,
    EBREAK    = 6'b100100,
    SLLI      = 6'b100101,
    SRLI      = 6'b100110,
    SRAI      = 6'b100111,
    FENCE_TSO = 6'b101000,
    PAUSE     = 6'b101001  }  INS;

INS Pre_INS;

typedef enum bit [5:0] {R0  = 6'b000000, R1  = 6'b000001, R2  = 6'b000010, R3  = 6'b000011,
                        R4  = 6'b000100, R5  = 6'b000101, R6  = 6'b000110, R7  = 6'b000111,
                        R8  = 6'b001000, R9  = 6'b001001, R10 = 6'b001010, R11 = 6'b001011,
                        R12 = 6'b001100, R13 = 6'b001101, R14 = 6'b001110, R15 = 6'b001111,
                        R16 = 6'b010000, R17 = 6'b010001, R18 = 6'b010010, R19 = 6'b010011,
                        R20 = 6'b010100, R21 = 6'b010101, R22 = 6'b010110, R23 = 6'b010111,
                        R24 = 6'b011000, R25 = 6'b011001, R26 = 6'b011010, R27 = 6'b011011,
                        R28 = 6'b011100, R29 = 6'b011101, R30 = 6'b011110, R31 = 6'b011111, NONE_rs = 6'b100000, IMM = 6'b100001, NONE_rd = 6'b100010  } REG;

REG Pre_RS1, Pre_RS2, Pre_RD;
wire logic [6:0] opcode, funct7;
wire logic [2:0] funct3;	
wire logic ld_instr, st_instr, BR_instr, op_imm_instr, op_instr;
wire logic lui, auipc, jal, jalr;

assign opcode = instr[6:0];
assign funct3 = instr[14:12]; // ignore when not use
assign funct7 = instr[31:25]; // ignore when not use

assign ld_instr     = ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0000011
assign st_instr     = ~opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0100011
assign BR_instr     =  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 1100011
assign op_imm_instr = ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0010011
assign op_instr     = ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]; // 7'b 0110011
assign lui          = ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0];
assign auipc        = ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0];   
assign jal          =  opcode[6] &  opcode[5] & ~opcode[4] &  opcode[3] &  opcode[2] &  opcode[1] &  opcode[0];
assign jalr         =  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0];

////////////////// COMMON funct3 AND funct7 VALUES //////////////////
wire logic funct3_0, funct3_1, funct3_2, funct3_3, funct3_4, funct3_5, funct3_6, funct3_7;
wire logic funct7_0, funct7_32;
 
assign funct3_0 = ~funct3[2] & ~funct3[1] & ~funct3[0];  // funct3 = 3'b000
assign funct3_1 = ~funct3[2] & ~funct3[1] &  funct3[0];  // funct3 = 3'b001
assign funct3_2 = ~funct3[2] &  funct3[1] & ~funct3[0];  // funct3 = 3'b010
assign funct3_3 = ~funct3[2] &  funct3[1] &  funct3[0];  // funct3 = 3'b011
assign funct3_4 =  funct3[2] & ~funct3[1] & ~funct3[0];  // funct3 = 3'b100
assign funct3_5 =  funct3[2] & ~funct3[1] &  funct3[0];  // funct3 = 3'b101
assign funct3_6 =  funct3[2] &  funct3[1] & ~funct3[0];  // funct3 = 3'b110
assign funct3_7 =  funct3[2] &  funct3[1] &  funct3[0];  // funct3 = 3'b111

assign funct7_0  = ~funct7[6] & ~funct7[5] & ~funct7[4] & ~funct7[3] & ~funct7[2] & ~funct7[1] & ~funct7[0];  // funct7 = 7'b0000000
assign funct7_32 = ~funct7[6] &  funct7[5] & ~funct7[4] & ~funct7[3] & ~funct7[2] & ~funct7[1] & ~funct7[0];  // funct7 = 7'b0100000


always@(*) begin
         if(lui | auipc | jal)   Pre_RS1 = NONE_rs;
         else                    Pre_RS1 = REG'(rs1);

	 if(lui | auipc | jal | jalr | ld_instr | op_imm_instr)  Pre_RS2 = IMM;
	 else                                                    Pre_RS2 = REG'(rs2);

	 if(BR_instr | st_instr)   Pre_RD  = NONE_rd;
	 else                      Pre_RD  = REG'(rd);
end

always@(*) begin
      if(lui)                                            Pre_INS = LUI;
      else if (auipc)                                    Pre_INS = AUIPC;
      else if (jal)                                      Pre_INS = JAL;
      else if (jalr)                                     Pre_INS = JALR;
      else if (BR_instr & funct3_0)                      Pre_INS = BEQ;
      else if (BR_instr & funct3_1)                      Pre_INS = BNE;
      else if (BR_instr & funct3_4)                      Pre_INS = BLT;
      else if (BR_instr & funct3_5)                      Pre_INS = BGE;
      else if (BR_instr & funct3_6)                      Pre_INS = BLTU;
      else if (BR_instr & funct3_7)                      Pre_INS = BGEU;
      else if (op_imm_instr & funct3_0)                  Pre_INS = ADDI;
      else if (op_imm_instr & funct3_2)                  Pre_INS = SLTI;
      else if (op_imm_instr & funct3_3)                  Pre_INS = SLTIU;
      else if (op_imm_instr & funct3_4)                  Pre_INS = XORI;
      else if (op_imm_instr & funct3_6)                  Pre_INS = ORI;
      else if (op_imm_instr & funct3_7)                  Pre_INS = ANDI;
      else if (op_imm_instr & funct3_1 & funct7_0)       Pre_INS = SLLI;
      else if (op_imm_instr & funct3_5 & funct7_0)       Pre_INS = SRLI;
      else if (op_imm_instr & funct3_5 & funct7_32)      Pre_INS = SRAI;
      else if (op_instr & funct3_0 & funct7_0)           Pre_INS = ADD;
      else if (op_instr & funct3_0 & funct7_32)          Pre_INS = SUB;
      else if (op_instr & funct3_1 & funct7_0)           Pre_INS = SLL;
      else if (op_instr & funct3_2 & funct7_0)           Pre_INS = SLT;
      else if (op_instr & funct3_3 & funct7_0)           Pre_INS = SLTU;
      else if (op_instr & funct3_4 & funct7_0)           Pre_INS = XOR;
      else if (op_instr & funct3_5 & funct7_0)           Pre_INS = SRL;
      else if (op_instr & funct3_5 & funct7_32)          Pre_INS = SRA;
      else if (op_instr & funct3_6 & funct7_0)           Pre_INS = OR;
      else if (op_instr & funct3_7 & funct7_0)           Pre_INS = AND;
      else if (ld_instr & funct3_0)                      Pre_INS = LB;
      else if (ld_instr & funct3_1)                      Pre_INS = LH;
      else if (ld_instr & funct3_2)                      Pre_INS = LW;
      else if (ld_instr & funct3_4)                      Pre_INS = LBU;
      else if (ld_instr & funct3_5)                      Pre_INS = LHU;
      else if (st_instr & funct3_0)                      Pre_INS = SB;
      else if (st_instr & funct3_1)                      Pre_INS = SH;
      else if (st_instr & funct3_2)                      Pre_INS = SW;
     
end


endmodule
