`timescale 1ps/1ps
import aqua_pkg::*;

module regfile (
    input   logic          i_clk,
    input   logic          i_rst_n,
    input   writeback_t    i_wb_rf_pkg,
    input   rs_addr_t      i_sch_rf_pkg,
    output  rs_data_t      o_rf_abt_pkg
);


// Rename signals to enhance readability
logic [4:0]  rs1_addr_instr1;
logic [4:0]  rs2_addr_instr1;
logic [4:0]  rs1_addr_instr2;
logic [4:0]  rs2_addr_instr2;
logic [31:0] rs1_dat_instr1;
logic [31:0] rs2_dat_instr1;
logic [31:0] rs1_dat_instr2;
logic [31:0] rs2_dat_instr2;

logic [4:0]  rd_addr_instr1;     // Input:  destination addr
logic [4:0]  rd_addr_instr2;     // Input:  destination addr
logic [31:0] rd_dat_instr1;      // Input:  destination data
logic [31:0] rd_dat_instr2;      // Input:  destination data
logic        wren_instr1;        // Input:  write enable
logic        wren_instr2;        // Input:  write enable


logic [31:0][31:0] R;
logic [31:0]       wren_reg_2hot;     // 32-bit encoded enable signal of regfile
logic [31:0]       wren_instr1_1hot;  // 32-bit encoded mux signals of instr_1
logic [31:0]       wren_instr2_1hot;  // 32-bit encoded mux signals of instr_2

assign rs1_addr_instr1 = i_sch_rf_pkg.rs1_addr_instr1;      // Source registers (4)
assign rs2_addr_instr1 = i_sch_rf_pkg.rs2_addr_instr1;
assign rs1_addr_instr2 = i_sch_rf_pkg.rs1_addr_instr2;
assign rs2_addr_instr2 = i_sch_rf_pkg.rs2_addr_instr2;
assign rd_addr_instr1  = i_wb_rf_pkg.rd_addr_instr1;        // Destination registers (2)
assign rd_addr_instr2  = i_wb_rf_pkg.rd_addr_instr2;
assign rd_dat_instr1   = i_wb_rf_pkg.rd_data_instr1;        // Data of destination registers (2)
assign rd_dat_instr2   = i_wb_rf_pkg.rd_data_instr2;
assign wren_instr1     = i_wb_rf_pkg.wren_instr1;           // Write enable signal (2)
assign wren_instr2     = i_wb_rf_pkg.wren_instr2;


//---------------------- READ REGFILE --------------------------------

mux #(.WIDTH(32), .NUM_INPUT(32)) rs1_instr1 (.sel(rs1_addr_instr1), .i_mux(R), .o_mux(rs1_dat_instr1));
mux #(.WIDTH(32), .NUM_INPUT(32)) rs2_instr1 (.sel(rs2_addr_instr1), .i_mux(R), .o_mux(rs2_dat_instr1));
mux #(.WIDTH(32), .NUM_INPUT(32)) rs1_instr2 (.sel(rs1_addr_instr2), .i_mux(R), .o_mux(rs1_dat_instr2));
mux #(.WIDTH(32), .NUM_INPUT(32)) rs2_instr2 (.sel(rs2_addr_instr2), .i_mux(R), .o_mux(rs2_dat_instr2));



//----------------------- WRITE DATA TO REGFILE ------------------------------
wire [31:0][31:0] rd_data;    // wiring

// Decode
decoder_5to32  wr_sel_instr1  (.en(wren_instr1), .sel(rd_addr_instr1), .Y(wren_instr1_1hot) );
decoder_5to32  wr_sel_instr2  (.en(wren_instr2), .sel(rd_addr_instr2), .Y(wren_instr2_1hot) );
assign wren_reg_2hot = (wren_instr1_1hot) | (wren_instr2_1hot);


// Selecting which data to Write
mux_2X1_32bit  d_reg0   (.sel(wren_instr2_1hot[0]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[0]));
mux_2X1_32bit  d_reg1   (.sel(wren_instr2_1hot[1]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[1]));
mux_2X1_32bit  d_reg2   (.sel(wren_instr2_1hot[2]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[2]));
mux_2X1_32bit  d_reg3   (.sel(wren_instr2_1hot[3]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[3]));
mux_2X1_32bit  d_reg4   (.sel(wren_instr2_1hot[4]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[4]));
mux_2X1_32bit  d_reg5   (.sel(wren_instr2_1hot[5]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[5]));
mux_2X1_32bit  d_reg6   (.sel(wren_instr2_1hot[6]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[6]));
mux_2X1_32bit  d_reg7   (.sel(wren_instr2_1hot[7]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[7]));
mux_2X1_32bit  d_reg8   (.sel(wren_instr2_1hot[8]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[8]));
mux_2X1_32bit  d_reg9   (.sel(wren_instr2_1hot[9]),  .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[9]));
mux_2X1_32bit  d_reg10  (.sel(wren_instr2_1hot[10]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[10]));
mux_2X1_32bit  d_reg11  (.sel(wren_instr2_1hot[11]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[11]));
mux_2X1_32bit  d_reg12  (.sel(wren_instr2_1hot[12]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[12]));
mux_2X1_32bit  d_reg13  (.sel(wren_instr2_1hot[13]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[13]));
mux_2X1_32bit  d_reg14  (.sel(wren_instr2_1hot[14]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[14]));
mux_2X1_32bit  d_reg15  (.sel(wren_instr2_1hot[15]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[15]));
mux_2X1_32bit  d_reg16  (.sel(wren_instr2_1hot[16]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[16]));
mux_2X1_32bit  d_reg17  (.sel(wren_instr2_1hot[17]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[17]));
mux_2X1_32bit  d_reg18  (.sel(wren_instr2_1hot[18]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[18]));
mux_2X1_32bit  d_reg19  (.sel(wren_instr2_1hot[19]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[19]));
mux_2X1_32bit  d_reg20  (.sel(wren_instr2_1hot[20]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[20]));
mux_2X1_32bit  d_reg21  (.sel(wren_instr2_1hot[21]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[21]));
mux_2X1_32bit  d_reg22  (.sel(wren_instr2_1hot[22]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[22]));
mux_2X1_32bit  d_reg23  (.sel(wren_instr2_1hot[23]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[23]));
mux_2X1_32bit  d_reg24  (.sel(wren_instr2_1hot[24]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[24]));
mux_2X1_32bit  d_reg25  (.sel(wren_instr2_1hot[25]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[25]));
mux_2X1_32bit  d_reg26  (.sel(wren_instr2_1hot[26]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[26]));
mux_2X1_32bit  d_reg27  (.sel(wren_instr2_1hot[27]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[27]));
mux_2X1_32bit  d_reg28  (.sel(wren_instr2_1hot[28]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[28]));
mux_2X1_32bit  d_reg29  (.sel(wren_instr2_1hot[29]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[29]));
mux_2X1_32bit  d_reg30  (.sel(wren_instr2_1hot[30]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[30]));
mux_2X1_32bit  d_reg31  (.sel(wren_instr2_1hot[31]), .A(rd_dat_instr1), .B(rd_dat_instr2), .Y(rd_data[31]));

// Storing/Writing data to registers
register  reg0  (.en(wren_reg_2hot[0] & 1'b0),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[0]),  .Q(R[0])  );
register  reg1  (.en(wren_reg_2hot[1]),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[1]),  .Q(R[1])  );
register  reg2  (.en(wren_reg_2hot[2]),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[2]),  .Q(R[2])  );
register  reg3  (.en(wren_reg_2hot[3]),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[3]),  .Q(R[3])  );
register  reg4  (.en(wren_reg_2hot[4]),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[4]),  .Q(R[4])  );
register  reg5  (.en(wren_reg_2hot[5]),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[5]),  .Q(R[5])  );
register  reg6  (.en(wren_reg_2hot[6]),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[6]),  .Q(R[6])  );
register  reg7  (.en(wren_reg_2hot[7]),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[7]),  .Q(R[7])  );
register  reg8  (.en(wren_reg_2hot[8]),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[8]),  .Q(R[8])  );
register  reg9  (.en(wren_reg_2hot[9]),  .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[9]),  .Q(R[9])  );
register  reg10 (.en(wren_reg_2hot[10]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[10]), .Q(R[10]) );
register  reg11 (.en(wren_reg_2hot[11]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[11]), .Q(R[11]) );
register  reg12 (.en(wren_reg_2hot[12]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[12]), .Q(R[12]) );
register  reg13 (.en(wren_reg_2hot[13]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[13]), .Q(R[13]) );
register  reg14 (.en(wren_reg_2hot[14]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[14]), .Q(R[14]) );
register  reg15 (.en(wren_reg_2hot[15]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[15]), .Q(R[15]) );
register  reg16 (.en(wren_reg_2hot[16]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[16]), .Q(R[16]) );
register  reg17 (.en(wren_reg_2hot[17]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[17]), .Q(R[17]) );
register  reg18 (.en(wren_reg_2hot[18]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[18]), .Q(R[18]) );
register  reg19 (.en(wren_reg_2hot[19]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[19]), .Q(R[19]) );
register  reg20 (.en(wren_reg_2hot[20]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[20]), .Q(R[20]) );
register  reg21 (.en(wren_reg_2hot[21]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[21]), .Q(R[21]) );
register  reg22 (.en(wren_reg_2hot[22]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[22]), .Q(R[22]) );
register  reg23 (.en(wren_reg_2hot[23]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[23]), .Q(R[23]) );
register  reg24 (.en(wren_reg_2hot[24]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[24]), .Q(R[24]) );
register  reg25 (.en(wren_reg_2hot[25]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[25]), .Q(R[25]) );
register  reg26 (.en(wren_reg_2hot[26]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[26]), .Q(R[26]) );
register  reg27 (.en(wren_reg_2hot[27]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[27]), .Q(R[27]) );
register  reg28 (.en(wren_reg_2hot[28]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[28]), .Q(R[28]) );
register  reg29 (.en(wren_reg_2hot[29]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[29]), .Q(R[29]) );
register  reg30 (.en(wren_reg_2hot[30]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[30]), .Q(R[30]) );
register  reg31 (.en(wren_reg_2hot[31]), .clk(i_clk), .rst_n(i_rst_n), .D(rd_data[31]), .Q(R[31]) );


// Output data for Source Reigsters (4)
assign o_rf_abt_pkg.rs1_data_instr1 = rs1_dat_instr1;
assign o_rf_abt_pkg.rs2_data_instr1 = rs2_dat_instr1;
assign o_rf_abt_pkg.rs1_data_instr2 = rs1_dat_instr2;
assign o_rf_abt_pkg.rs2_data_instr2 = rs2_dat_instr2;







// DEBUG
logic [31:0] R0, R8,  R16, R24;
logic [31:0] R1, R9,  R17, R25;
logic [31:0] R2, R10, R18, R26;
logic [31:0] R3, R11, R19, R27;
logic [31:0] R4, R12, R20, R28;
logic [31:0] R5, R13, R21, R29;
logic [31:0] R6, R14, R22, R30;
logic [31:0] R7, R15, R23, R31;

assign R0  = R[0] ;
assign R1  = R[1] ;
assign R2  = R[2] ;
assign R3  = R[3] ;
assign R4  = R[4] ;
assign R5  = R[5] ;
assign R6  = R[6] ;
assign R7  = R[7] ;
assign R8  = R[8] ;
assign R9  = R[9] ;
assign R10 = R[10];
assign R11 = R[11];
assign R12 = R[12];
assign R13 = R[13];
assign R14 = R[14];
assign R15 = R[15];
assign R16 = R[16];
assign R17 = R[17];
assign R18 = R[18];
assign R19 = R[19];
assign R20 = R[20];
assign R21 = R[21];
assign R22 = R[22];
assign R23 = R[23];
assign R24 = R[24];
assign R25 = R[25];
assign R26 = R[26];
assign R27 = R[27];
assign R28 = R[28];
assign R29 = R[29];
assign R30 = R[30];
assign R31 = R[31];




endmodule


module mux_2X1_32bit(
    input  logic         sel,
    input  logic  [31:0] A,
    input  logic  [31:0] B,
    output logic  [31:0] Y
);

assign Y = (sel == 1) ? B : A;

endmodule



