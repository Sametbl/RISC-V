import aqua_pkg::*;

module alu(
    input  alu_issue_t    i_abt_alu_pkg,          // Input data
    output uv_buff_t      o_alu_buff_pkg,         // Output data
    
    input  debug_t        i_abt_alu_debug
);

// Rename signal for readability
operator_e    instr_in;
logic [31:0]  operand_a;
logic [31:0]  operand_b;

// Temporary Data signal
logic [31:0]  OR_d;             // Result of OR  operation (OR)
logic [31:0]  AND_d;            // Result of AND operation (AND)
logic [31:0]  XOR_d;            // Result of XOR operation (XOR)
logic [31:0]  cmp_d;            // Result of Comparison, 32-bit exteneded (SLT, SLTU)
logic [31:0]  adder_d;          // Result of addition/subtraction (ADD, SUB)
logic [31:0]  shifter_d;        // Result of Shifter module (SRA, SLL, SRL)
logic [31:0]  output_d;         // Final result (selected output)
logic [31:0]  reserved;         // Reserved, default value = 32'b0

// Control signal
logic         reserved_sel;
logic         adder_ctrl;             // Select addition or subtration
logic         cmp_crtl;               // Select signed or unsigned comparison
logic [1:0]   shifter_ctrl;           // Shifter mode: Righ or Left shift, Arithmetic or logical
logic [4:0]   shifter_amount;         // Shift amount
logic [2:0]   output_sel;             // Selecting signal for Mux to select the output


assign operand_a = i_abt_alu_pkg.operand_a;       // Input operand A
assign operand_b = i_abt_alu_pkg.operand_b;       // Input operand B
assign instr_in  = i_abt_alu_pkg.instr_op;        // Instruction selector


// shifter_crtl = 2'b00 : shift Right logical (default) , when alu_op == 4'b1000
// shifter_crtl = 2;b01 : shift Left  logical           , when alu_op == 4'b0111
// shifter_crtl = 2'b10 : shift Right Arithmetic        , when alu_op == 4'b1001
// shifter_crtl = 2'b11 : Reserved

assign adder_ctrl      = (instr_in == SUB);
assign cmp_crtl        = (instr_in == SLTU);
assign shifter_ctrl[0] = (instr_in == SLL);       // Shift Left Logical
assign shifter_ctrl[1] = (instr_in == SRA);       // Shift Right Arithmetic
assign shifter_amount  =  operand_b[4:0];


// ADD - SUB instructions
full_adder_32bit  ADD_SUB (
                    .A       (operand_a ),
                    .B       (operand_b ),
                    .Invert_B(adder_ctrl),
                    .C_in    (adder_ctrl),
                    .Sum     (adder_d   ),
                    .C_out   (          )
);

// SLT/SLTU instructions - Set if Less Than
assign cmp_d[31:1] = 31'b0;
comparator_32bit  Ins_SLT_U   (
                    .A          (operand_a),
                    .B          (operand_b),
                    .is_unsigned(cmp_crtl ),
                    .smaller    (cmp_d[0] ),
                    .equal      (         ),
                    .larger     (         )
);

// SHIFTER instructions - LOGICAL - ARITHMETIC
shifter_32bit     Ins_S_3mode (
                    .data_in     (operand_a     ),
                    .shift_amount(shifter_amount),
                    .mode        (shifter_ctrl  ),
                    .data_out    (shifter_d     )
);


// Logical instructions - AND, OR, XOR
assign OR_d  = operand_a | operand_b;
assign AND_d = operand_a & operand_b;
assign XOR_d = operand_a ^ operand_b;


// RESULT SELECTION
// D0 - output_sel = 3'b000:      output data = Full Adder   (default)
// D1 - output_sel = 3'b001:      output data = Comparator
// D2 - output_sel = 3'b010:      output data = Shifter
// D3 - output_sel = 3'b011:      output data = 32-bit XOR gate
// D4 - output_sel = 3'b100:      output data = 32-bit AND gate
// D5 - output_sel = 3'b101:      output data = 32-bit OR  gate
// D6 - output_sel = 3'b110:      RESERVED  or  output data = 0
// D7 - output_sel = 3'b111:      RESERVED  or  output data = 0


logic  [7:0][31:0] alu_mux_data_in;

assign reserved      =  32'b0;
assign reserved_sel  =  ~(i_abt_alu_pkg.valid);

assign output_sel[0] = (instr_in == SLT) | (instr_in == SLTU) |      // Comparator
                       (instr_in == XOR) | (instr_in == OR)   |      // XOR and OR gates
                        reserved_sel;

assign output_sel[1] = (instr_in == SRL) | (instr_in == SRA) | (instr_in == SLL) |  // Shifter
                       (instr_in == XOR) |                                          // XOR gates
                        reserved_sel;

assign output_sel[2] = (instr_in == AND) |
                       (instr_in == OR)  |
                        reserved_sel;

assign alu_mux_data_in[0] = adder_d;
assign alu_mux_data_in[1] = cmp_d;
assign alu_mux_data_in[2] = shifter_d;
assign alu_mux_data_in[3] = XOR_d;
assign alu_mux_data_in[4] = AND_d;
assign alu_mux_data_in[5] = OR_d;
assign alu_mux_data_in[6] = reserved;
assign alu_mux_data_in[7] = reserved;

mux  #(.WIDTH(32), .NUM_INPUT(8))  ALU_out  (
    .sel  (output_sel     ),
    .i_mux(alu_mux_data_in),
    .o_mux(output_d       )
);

assign o_alu_buff_pkg.data_buff = output_d;
assign o_alu_buff_pkg.rd_buff   = i_abt_alu_pkg.rd_addr;
assign o_alu_buff_pkg.wr_en     = i_abt_alu_pkg.wr_en;
assign o_alu_buff_pkg.valid     = i_abt_alu_pkg.valid;
assign o_alu_buff_pkg.is_instr2 = i_abt_alu_pkg.is_instr2;






// DEBUG
debug_instr     alu_db_instr;
register_idx    alu_db_rs1_addr;
register_idx    alu_db_rs2_addr;
register_idx    alu_db_rd_addr;
logic [31:0]    alu_db_rs1_data;
logic [31:0]    alu_db_rs2_data;
logic [31:0]    alu_db_rd_data;
logic [31:0]    alu_db_imm;
logic [31:0]    alu_db_pc;
logic [31:0]    alu_db_instr_asm;
logic           alu_db_wr_en;
logic           alu_db_valid;
logic           alu_db_prd_en;
logic           alu_db_is_instr2;


assign alu_db_instr      = i_abt_alu_debug.db_instr; 
assign alu_db_rs1_addr   = i_abt_alu_debug.db_rs1_addr; 
assign alu_db_rs2_addr   = i_abt_alu_debug.db_rs2_addr; 
assign alu_db_rd_addr    = i_abt_alu_debug.db_rd_addr; 
assign alu_db_rs1_data   = i_abt_alu_debug.db_rs1_data; 
assign alu_db_rs2_data   = i_abt_alu_debug.db_rs2_data; 
assign alu_db_rd_data    = output_d; 
assign alu_db_imm        = i_abt_alu_debug.db_imm; 
assign alu_db_pc         = i_abt_alu_debug.db_pc; 
assign alu_db_instr_asm  = i_abt_alu_debug.db_instr_asm; 
assign alu_db_wr_en      = i_abt_alu_debug.db_wr_en; 
assign alu_db_valid      = i_abt_alu_debug.db_valid; 
assign alu_db_prd_en     = i_abt_alu_debug.db_prd_en; 
assign alu_db_is_instr2  = i_abt_alu_debug.db_is_instr2; 



endmodule: alu





