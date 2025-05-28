`timescale 1ps/1ps
import aqua_pkg::*;

// Forwarding_cell module is defined at the end of file

module forwarding_unit(
    input   rs_addr_t       i_sch_fwd_pkg,
    input   uv_buff_t       i_alu_buff_1_pkg,     // Location 1
    input   uv_buff_t       i_alu_buff_2_pkg,     // Location 2
    input   uv_buff_t       i_alu_buff_3_pkg,     // Location 3
    input   uv_buff_t       i_bru_buff_1_pkg,     // Location 4
    input   uv_buff_t       i_bru_buff_2_pkg,     // Location 5
    input   uv_buff_t       i_bru_buff_3_pkg,     // Location 6
    input   uv_buff_t       i_mem_buff_1_pkg,     // Location 7
    input   uv_buff_t       i_mem_buff_2_pkg,     // Location 7
    output  forwarding_t    o_fwd_abt_pkg

);
logic [4:0] rs1_addr_instr1;
logic [4:0] rs2_addr_instr1;
logic [4:0] rs1_addr_instr2;
logic [4:0] rs2_addr_instr2;
logic [7:0] fwd_rs1_instr1;
logic [7:0] fwd_rs2_instr1;
logic [7:0] fwd_rs1_instr2;
logic [7:0] fwd_rs2_instr2;


assign rs1_addr_instr1 = i_sch_fwd_pkg.rs1_addr_instr1;
assign rs2_addr_instr1 = i_sch_fwd_pkg.rs2_addr_instr1;
assign rs1_addr_instr2 = i_sch_fwd_pkg.rs1_addr_instr2;
assign rs2_addr_instr2 = i_sch_fwd_pkg.rs2_addr_instr2;

//---------------------------- From U-pipe ---------------------------------
forwarding_cell    alu_buff_1 (.rs1_instr1(rs1_addr_instr1),   .rs2_instr1(rs2_addr_instr1),
                               .rs1_instr2(rs1_addr_instr2),   .rs2_instr2(rs2_addr_instr2),
                               .valid(i_alu_buff_1_pkg.valid), .wr_en(i_alu_buff_1_pkg.wr_en),
                               .rd_buffer(i_alu_buff_1_pkg.rd_buff),
                               .fwd_rs1_instr1(fwd_rs1_instr1[0]),
                               .fwd_rs2_instr1(fwd_rs2_instr1[0]),
                               .fwd_rs1_instr2(fwd_rs1_instr2[0]),
                               .fwd_rs2_instr2(fwd_rs2_instr2[0]));

forwarding_cell    alu_buff_2 (.rs1_instr1(rs1_addr_instr1),   .rs2_instr1(rs2_addr_instr1),
                               .rs1_instr2(rs1_addr_instr2),   .rs2_instr2(rs2_addr_instr2),
                               .valid(i_alu_buff_2_pkg.valid), .wr_en(i_alu_buff_2_pkg.wr_en),
                               .rd_buffer(i_alu_buff_2_pkg.rd_buff),
                               .fwd_rs1_instr1(fwd_rs1_instr1[1]),
                               .fwd_rs2_instr1(fwd_rs2_instr1[1]),
                               .fwd_rs1_instr2(fwd_rs1_instr2[1]),
                               .fwd_rs2_instr2(fwd_rs2_instr2[1]));

forwarding_cell    alu_buff_3 (.rs1_instr1(rs1_addr_instr1),   .rs2_instr1(rs2_addr_instr1),
                               .rs1_instr2(rs1_addr_instr2),   .rs2_instr2(rs2_addr_instr2),
                               .valid(i_alu_buff_3_pkg.valid), .wr_en(i_alu_buff_3_pkg.wr_en),
                               .rd_buffer(i_alu_buff_3_pkg.rd_buff),
                               .fwd_rs1_instr1(fwd_rs1_instr1[2]),
                               .fwd_rs2_instr1(fwd_rs2_instr1[2]),
                               .fwd_rs1_instr2(fwd_rs1_instr2[2]),
                               .fwd_rs2_instr2(fwd_rs2_instr2[2]));


//---------------------------- From V-pipe - alu/bru ---------------------------------
forwarding_cell    bru_buff_1 (.rs1_instr1(rs1_addr_instr1),   .rs2_instr1(rs2_addr_instr1),
                               .rs1_instr2(rs1_addr_instr2),   .rs2_instr2(rs2_addr_instr2),
                               .valid(i_bru_buff_1_pkg.valid), .wr_en(i_bru_buff_1_pkg.wr_en),
                               .rd_buffer(i_bru_buff_1_pkg.rd_buff),
                               .fwd_rs1_instr1(fwd_rs1_instr1[3]),
                               .fwd_rs2_instr1(fwd_rs2_instr1[3]),
                               .fwd_rs1_instr2(fwd_rs1_instr2[3]),
                               .fwd_rs2_instr2(fwd_rs2_instr2[3]));

forwarding_cell    bru_buff_2 (.rs1_instr1(rs1_addr_instr1),   .rs2_instr1(rs2_addr_instr1),
                               .rs1_instr2(rs1_addr_instr2),   .rs2_instr2(rs2_addr_instr2),
                               .valid(i_bru_buff_2_pkg.valid), .wr_en(i_bru_buff_2_pkg.wr_en),
                               .rd_buffer(i_bru_buff_2_pkg.rd_buff),
                               .fwd_rs1_instr1(fwd_rs1_instr1[4]),
                               .fwd_rs2_instr1(fwd_rs2_instr1[4]),
                               .fwd_rs1_instr2(fwd_rs1_instr2[4]),
                               .fwd_rs2_instr2(fwd_rs2_instr2[4]));

forwarding_cell    bru_buff_3 (.rs1_instr1(rs1_addr_instr1),   .rs2_instr1(rs2_addr_instr1),
                               .rs1_instr2(rs1_addr_instr2),   .rs2_instr2(rs2_addr_instr2),
                               .valid(i_bru_buff_3_pkg.valid), .wr_en(i_bru_buff_3_pkg.wr_en),
                               .rd_buffer(i_bru_buff_3_pkg.rd_buff),
                               .fwd_rs1_instr1(fwd_rs1_instr1[5]),
                               .fwd_rs2_instr1(fwd_rs2_instr1[5]),
                               .fwd_rs1_instr2(fwd_rs1_instr2[5]),
                               .fwd_rs2_instr2(fwd_rs2_instr2[5]));


//---------------------------- From V-pipe - Cache ---------------------------------
forwarding_cell    Cache_buff1(.rs1_instr1(rs1_addr_instr1),   .rs2_instr1(rs2_addr_instr1),
                               .rs1_instr2(rs1_addr_instr2),   .rs2_instr2(rs2_addr_instr2),
                               .valid(i_mem_buff_1_pkg.valid), .wr_en(i_mem_buff_1_pkg.wr_en),
                               .rd_buffer(i_mem_buff_1_pkg.rd_buff),
                               .fwd_rs1_instr1(fwd_rs1_instr1[6]),
                               .fwd_rs2_instr1(fwd_rs2_instr1[6]),
                               .fwd_rs1_instr2(fwd_rs1_instr2[6]),
                               .fwd_rs2_instr2(fwd_rs2_instr2[6]));

forwarding_cell    Cache_buff2(.rs1_instr1(rs1_addr_instr1),   .rs2_instr1(rs2_addr_instr1),
                               .rs1_instr2(rs1_addr_instr2),   .rs2_instr2(rs2_addr_instr2),
                               .valid(i_mem_buff_2_pkg.valid), .wr_en(i_mem_buff_2_pkg.wr_en),
                               .rd_buffer(i_mem_buff_2_pkg.rd_buff),
                               .fwd_rs1_instr1(fwd_rs1_instr1[7]),
                               .fwd_rs2_instr1(fwd_rs2_instr1[7]),
                               .fwd_rs1_instr2(fwd_rs1_instr2[7]),
                               .fwd_rs2_instr2(fwd_rs2_instr2[7]));



// ------------------------ Encoding Forwarding select signals ----------------------------
logic [15:0]    fwd_onehot_instr1_rs1;
logic [15:0]    fwd_onehot_instr1_rs2;
logic [15:0]    fwd_onehot_instr2_rs1;
logic [15:0]    fwd_onehot_instr2_rs2;
logic [3:0]     fwd_sel_instr1_rs1;    // Select signal for fowarding MUXs
logic [3:0]     fwd_sel_instr1_rs2;
logic [3:0]     fwd_sel_instr2_rs1;
logic [3:0]     fwd_sel_instr2_rs2;

assign fwd_onehot_instr1_rs1[0] = 1'b0;
assign fwd_onehot_instr1_rs1[1] = fwd_rs1_instr1[0];
assign fwd_onehot_instr1_rs1[2] = fwd_rs1_instr1[1] & ~fwd_rs1_instr1[0] & ~fwd_rs1_instr1[3];
assign fwd_onehot_instr1_rs1[3] = fwd_rs1_instr1[2] & ~fwd_rs1_instr1[1] & ~fwd_rs1_instr1[0] &
                                 ~fwd_rs1_instr1[4] & ~fwd_rs1_instr1[3];
assign fwd_onehot_instr1_rs1[4] = fwd_rs1_instr1[3];
assign fwd_onehot_instr1_rs1[5] = fwd_rs1_instr1[4] & ~fwd_rs1_instr1[0] & ~fwd_rs1_instr1[3];
assign fwd_onehot_instr1_rs1[6] = fwd_rs1_instr1[5] & ~fwd_rs1_instr1[1] & ~fwd_rs1_instr1[0] &
                                 ~fwd_rs1_instr1[4] & ~fwd_rs1_instr1[3];
assign fwd_onehot_instr1_rs1[7] = fwd_rs1_instr1[6];
assign fwd_onehot_instr1_rs1[8] = fwd_rs1_instr1[7] & ~fwd_rs1_instr1[6];


assign fwd_onehot_instr1_rs2[0] = 1'b0;
assign fwd_onehot_instr1_rs2[1] = fwd_rs2_instr1[0];
assign fwd_onehot_instr1_rs2[2] = fwd_rs2_instr1[1] & ~fwd_rs2_instr1[0] & ~fwd_rs2_instr1[3];
assign fwd_onehot_instr1_rs2[3] = fwd_rs2_instr1[2] & ~fwd_rs2_instr1[1] & ~fwd_rs2_instr1[0] &
                                 ~fwd_rs2_instr1[4] & ~fwd_rs2_instr1[3];
assign fwd_onehot_instr1_rs2[4] = fwd_rs2_instr1[3];
assign fwd_onehot_instr1_rs2[5] = fwd_rs2_instr1[4] & ~fwd_rs2_instr1[0] & ~fwd_rs2_instr1[3];
assign fwd_onehot_instr1_rs2[6] = fwd_rs2_instr1[5] & ~fwd_rs2_instr1[1] & ~fwd_rs2_instr1[0] &
                                 ~fwd_rs2_instr1[4] & ~fwd_rs2_instr1[3];
assign fwd_onehot_instr1_rs2[7] = fwd_rs2_instr1[6];
assign fwd_onehot_instr1_rs2[8] = fwd_rs2_instr1[7] & ~fwd_rs2_instr1[6];


assign fwd_onehot_instr2_rs1[0] = 1'b0;
assign fwd_onehot_instr2_rs1[1] = fwd_rs1_instr2[0];
assign fwd_onehot_instr2_rs1[2] = fwd_rs1_instr2[1] & ~fwd_rs1_instr2[0] & ~fwd_rs1_instr2[3];
assign fwd_onehot_instr2_rs1[3] = fwd_rs1_instr2[2] & ~fwd_rs1_instr2[1] & ~fwd_rs1_instr2[0] &
                                 ~fwd_rs1_instr2[4] & ~fwd_rs1_instr2[3];
assign fwd_onehot_instr2_rs1[4] = fwd_rs1_instr2[3];
assign fwd_onehot_instr2_rs1[5] = fwd_rs1_instr2[4] & ~fwd_rs1_instr2[0] & ~fwd_rs1_instr2[3];
assign fwd_onehot_instr2_rs1[6] = fwd_rs1_instr2[5] & ~fwd_rs1_instr2[1] & ~fwd_rs1_instr2[0] &
                                 ~fwd_rs1_instr2[4] & ~fwd_rs1_instr2[3];
assign fwd_onehot_instr2_rs1[7] = fwd_rs1_instr2[6];
assign fwd_onehot_instr2_rs1[8] = fwd_rs1_instr2[7] & ~fwd_rs1_instr2[6];


assign fwd_onehot_instr2_rs2[0] = 1'b0;
assign fwd_onehot_instr2_rs2[1] = fwd_rs2_instr2[0];
assign fwd_onehot_instr2_rs2[2] = fwd_rs2_instr2[1] & ~fwd_rs2_instr2[0] & ~fwd_rs2_instr2[3];
assign fwd_onehot_instr2_rs2[3] = fwd_rs2_instr2[2] & ~fwd_rs2_instr2[1] & ~fwd_rs2_instr2[0] &
                                 ~fwd_rs2_instr2[4] & ~fwd_rs2_instr2[3];
assign fwd_onehot_instr2_rs2[4] = fwd_rs2_instr2[3];
assign fwd_onehot_instr2_rs2[5] = fwd_rs2_instr2[4] & ~fwd_rs2_instr2[0] & ~fwd_rs2_instr2[3];
assign fwd_onehot_instr2_rs2[6] = fwd_rs2_instr2[5] & ~fwd_rs2_instr2[1] & ~fwd_rs2_instr2[0] &
                                 ~fwd_rs2_instr2[4] & ~fwd_rs2_instr2[3];
assign fwd_onehot_instr2_rs2[7] = fwd_rs2_instr2[6];
assign fwd_onehot_instr2_rs2[8] = fwd_rs2_instr2[7] & ~fwd_rs2_instr2[6];


assign fwd_onehot_instr1_rs1[15:9] = 7'b0;
assign fwd_onehot_instr1_rs2[15:9] = 7'b0;
assign fwd_onehot_instr2_rs1[15:9] = 7'b0;
assign fwd_onehot_instr2_rs2[15:9] = 7'b0;


encoder16_to_4  wr_enc_1  (.i_data(fwd_onehot_instr1_rs1), .o_data(fwd_sel_instr1_rs1));
encoder16_to_4  wr_enc_2  (.i_data(fwd_onehot_instr1_rs2), .o_data(fwd_sel_instr1_rs2));
encoder16_to_4  wr_enc_3  (.i_data(fwd_onehot_instr2_rs1), .o_data(fwd_sel_instr2_rs1));
encoder16_to_4  wr_enc_4  (.i_data(fwd_onehot_instr2_rs2), .o_data(fwd_sel_instr2_rs2));

assign o_fwd_abt_pkg.fwd_rs1_instr1  =  fwd_sel_instr1_rs1;
assign o_fwd_abt_pkg.fwd_rs2_instr1  =  fwd_sel_instr1_rs2;
assign o_fwd_abt_pkg.fwd_rs1_instr2  =  fwd_sel_instr2_rs1;
assign o_fwd_abt_pkg.fwd_rs2_instr2  =  fwd_sel_instr2_rs2;
assign o_fwd_abt_pkg.alu1_fwd_dat    =  i_alu_buff_1_pkg.data_buff;
assign o_fwd_abt_pkg.alu2_fwd_dat    =  i_alu_buff_2_pkg.data_buff;
assign o_fwd_abt_pkg.alu3_fwd_dat    =  i_alu_buff_3_pkg.data_buff;
assign o_fwd_abt_pkg.bru1_fwd_dat    =  i_bru_buff_1_pkg.data_buff;
assign o_fwd_abt_pkg.bru2_fwd_dat    =  i_bru_buff_2_pkg.data_buff;
assign o_fwd_abt_pkg.bru3_fwd_dat    =  i_bru_buff_3_pkg.data_buff;
assign o_fwd_abt_pkg.mem1_fwd_dat    =  i_mem_buff_1_pkg.data_buff;
assign o_fwd_abt_pkg.mem2_fwd_dat    =  i_mem_buff_2_pkg.data_buff;


endmodule








//----------------------------------------------------------------------------------
module forwarding_cell(
    input  logic [4:0] rs1_instr1, rs2_instr1,
    input  logic [4:0] rs1_instr2, rs2_instr2,
    input  logic [4:0] rd_buffer,
    input  logic valid, wr_en,
    output logic fwd_rs1_instr1,
    output logic fwd_rs2_instr1,
    output logic fwd_rs1_instr2,
    output logic fwd_rs2_instr2
);

logic rs1_instr1_matched, rs2_instr1_matched;
logic rs1_instr2_matched, rs2_instr2_matched;

// Equal_Comparator_5bit defined in "/Datapath Component"
equal_comparator_5bit  RS1_Instr1 (.A(rd_buffer), .B(rs1_instr1), .equal(rs1_instr1_matched));
equal_comparator_5bit  RS2_Instr1 (.A(rd_buffer), .B(rs2_instr1), .equal(rs2_instr1_matched));
equal_comparator_5bit  RS1_Instr2 (.A(rd_buffer), .B(rs1_instr2), .equal(rs1_instr2_matched));
equal_comparator_5bit  RS2_Instr2 (.A(rd_buffer), .B(rs2_instr2), .equal(rs2_instr2_matched));

assign fwd_rs1_instr1 = (rs1_instr1_matched) & (valid) & (wr_en);
assign fwd_rs2_instr1 = (rs2_instr1_matched) & (valid) & (wr_en);
assign fwd_rs1_instr2 = (rs1_instr2_matched) & (valid) & (wr_en);
assign fwd_rs2_instr2 = (rs2_instr2_matched) & (valid) & (wr_en);

endmodule

