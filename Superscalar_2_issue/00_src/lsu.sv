//`include "timescale.svh"
//`include "aqua_pkg.sv"
import aqua_pkg::*;
module lsu #(parameter int LSU_ADDR_W = 32)(
    input  logic            i_clk        ,
    input  logic            i_rst_n      ,
    input  mem_req_t        i_agu_lsu_pkg,
    //input  logic            en_lsu,
    output uv_buff_t        o_lsu_buff,
    // Peripherals
    input  logic    [31:0]  i_sw,
    output logic    [31:0]  o_hex [8],
    output logic    [31:0]  o_ledg,
    output logic    [31:0]  o_ledr,
    output logic    [31:0]  o_lcd

);

logic [31:0] address;
logic [31:0] rdata_dmem;
logic [31:0] mem_data;
logic [31:0] wdata;
logic [3:0]  bytemask;
logic        write;
logic        valid;
/*I want to hold the value*/
logic [4:0]  i_instr;
logic [4:0]  rd_addr;
logic        wr_en;
logic        is_instr2;
logic [LSU_ADDR_W - 1 : 0] address_hold;
always @(posedge i_clk or negedge i_rst_n) begin

  rd_addr      <= i_agu_lsu_pkg.rd_addr;
  wr_en        <= i_agu_lsu_pkg.wr_en;
  is_instr2    <= i_agu_lsu_pkg.is_instr2;
  valid        <= i_agu_lsu_pkg.valid;
  i_instr      <= i_agu_lsu_pkg.instr;
  address_hold <= address;
  read_SB_hold <= read_SB; 
  read_SH_hold <= read_SH; 
  read_SW_hold <= read_SW; 

end
//
logic opcode_LB, opcode_LH, opcode_LW, opcode_LBU, opcode_LHU;
logic opcode_SB, opcode_SH, opcode_SW;

assign address = i_agu_lsu_pkg.target_addr;
assign wdata   = i_agu_lsu_pkg.data;
//assign valid   = i_agu_lsu_pkg.valid;

assign opcode_LB  = (i_agu_lsu_pkg.instr == LB);
assign opcode_LH  = (i_agu_lsu_pkg.instr == LH);
assign opcode_LW  = (i_agu_lsu_pkg.instr == LW);
assign opcode_LBU = (i_agu_lsu_pkg.instr == LBU);
assign opcode_LHU = (i_agu_lsu_pkg.instr == LHU);
assign opcode_SB  = (i_agu_lsu_pkg.instr == SB);
assign opcode_SH  = (i_agu_lsu_pkg.instr == SH);
assign opcode_SW  = (i_agu_lsu_pkg.instr == SW);




// LB, LBU, SB : bytemask = 4'b0001;
// LH, LHU, SH : bytemask = 4'b0011;
// LW, SW :      bytemask = 4'b1111;

logic  write_SB, write_SH, write_SW;
assign write_SB    = opcode_SB;
assign write_SH    = opcode_SH & (~address[0]); // can write in 00 and 10
assign write_SW    = opcode_SW & ((~address[1]) & (~address[0])); // can write in 00

assign write       = (write_SW | write_SH | write_SB) & i_agu_lsu_pkg.valid;    // Store
//enable read
logic  read_SB, read_SH, read_SW;
logic  read_SB_hold, read_SH_hold, read_SW_hold;
assign read_SB     = (opcode_LB | opcode_LBU);
assign read_SH     = (opcode_LH | opcode_LHU) & (~address[0]);
assign read_SW     = (opcode_LW) & ((~address[1]) & (~address[0]));
//byte mask
assign bytemask[0] =  opcode_LW | opcode_SW |               // Word
                      opcode_LH | opcode_LHU | opcode_SH |  // Halfbyte
                      opcode_LB | opcode_LBU | opcode_SB;   // Byte

assign bytemask[1] =  opcode_LW | opcode_SW  |              // Word
                      opcode_LH | opcode_LHU | opcode_SH;   // Halfbyte

assign bytemask[2] =  opcode_LW | opcode_SW;
assign bytemask[3] =  opcode_LW | opcode_SW;

logic [7:0] input_mem  [256];
logic [7:0] output_mem [256];
logic [31:0] o_output_mem_data;
logic [31:0] o_input_mem_data;

initial for (int i = 0; i < 256; i++) begin output_mem[i] = 0; input_mem[i] = 0; end;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) for (int i=0; i<256; i++) output_mem[i] <= 0;
    else begin
        if (write & (address[31:8] == 24'h4xxxxx)) begin
            output_mem[address    ] <= wdata[7:0]   & {8{bytemask[0]}};
            output_mem[address + 1] <= wdata[15:8]  & {8{bytemask[1]}};
            output_mem[address + 2] <= wdata[23:16] & {8{bytemask[2]}};
            output_mem[address + 3] <= wdata[31:24] & {8{bytemask[3]}};
        end
        o_output_mem_data [7:0]     <= output_mem[address]     & {8{bytemask[0]}};
        o_output_mem_data [15:8]    <= output_mem[address + 1] & {8{bytemask[1]}};
        o_output_mem_data [23:16]   <= output_mem[address + 2] & {8{bytemask[2]}};
        o_output_mem_data [31:24]   <= output_mem[address + 3] & {8{bytemask[3]}};
    end
end

assign o_hex[0][7:0]   = output_mem[8'h00];
assign o_hex[0][15:8]  = output_mem[8'h01];
assign o_hex[0][23:16] = output_mem[8'h02];
assign o_hex[0][31:24] = output_mem[8'h03];

assign o_hex[1] = {output_mem[8'h07],output_mem[8'h06],output_mem[8'h05],output_mem[8'h04]};
assign o_hex[2] = {output_mem[8'h0B],output_mem[8'h0A],output_mem[8'h09],output_mem[8'h08]};
assign o_hex[3] = {output_mem[8'h0F],output_mem[8'h0E],output_mem[8'h0D],output_mem[8'h0C]};
assign o_hex[4] = {output_mem[8'h13],output_mem[8'h12],output_mem[8'h11],output_mem[8'h10]};
assign o_hex[5] = {output_mem[8'h17],output_mem[8'h16],output_mem[8'h15],output_mem[8'h14]};
assign o_hex[6] = {output_mem[8'h1B],output_mem[8'h1A],output_mem[8'h19],output_mem[8'h18]};
assign o_hex[7] = {output_mem[8'h1F],output_mem[8'h1E],output_mem[8'h1D],output_mem[8'h1C]};
assign o_ledg   = {output_mem[8'h23],output_mem[8'h22],output_mem[8'h21],output_mem[8'h20]};
assign o_ledr   = {output_mem[8'h27],output_mem[8'h26],output_mem[8'h25],output_mem[8'h24]};
assign o_lcd    = {output_mem[8'h2B],output_mem[8'h2A],output_mem[8'h29],output_mem[8'h28]};

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) for (int i=0; i<256; i++) input_mem[i] <= 0;
    else begin
        input_mem[0] <= i_sw[7:0]  ;
        input_mem[1] <= i_sw[15:8] ;
        input_mem[2] <= i_sw[23:16];
        input_mem[3] <= i_sw[31:24];

        o_input_mem_data [7:0]     <= input_mem[address]     & {8{bytemask[0]}};
        o_input_mem_data [15:8]    <= input_mem[address + 1] & {8{bytemask[1]}};
        o_input_mem_data [23:16]   <= input_mem[address + 2] & {8{bytemask[2]}};
        o_input_mem_data [31:24]   <= input_mem[address + 3] & {8{bytemask[3]}};
    end
end

logic [31:0] dmem_data;

dmem     ex_dmem(
    .i_clk     (i_clk)   ,
    .i_rst_n   (i_rst_n) ,
    .i_wren    (write)   ,
    .i_wdata   (wdata)   ,
    .i_addr    (address) ,
    .i_bytemask(bytemask),
    .o_mem_data(dmem_data) // replace `mem_data` with `dmem_data``
);

always_comb begin : proc_mem_data_select
    case (address_hold[31:28])
        4'h0: mem_data = dmem_data;
        4'h1: mem_data = dmem_data;
        4'h2: mem_data = dmem_data;
        4'h3: mem_data = dmem_data;
        4'h4: mem_data = o_output_mem_data;
        4'h5: mem_data = o_input_mem_data;
        default: mem_data = 32'h0;
    endcase
end

always_comb begin : proc_lsu_extend_msb
    case (i_instr)
        LB:             rdata_dmem = (read_SB_hold) ? {{24{mem_data[7]}},  mem_data[7:0]} : 32'b0;
        LH:             rdata_dmem = (read_SH_hold) ? {{16{mem_data[15]}}, mem_data[15:0]} : 32'b0;
        LBU:            rdata_dmem = (read_SB_hold) ? {24'h0, mem_data[7:0]} : 32'b0;
        LHU:            rdata_dmem = (read_SH_hold) ? {16'h0, mem_data[15:0]} : 32'b0;
        LW:             rdata_dmem = (read_SW_hold) ? mem_data : 32'b0;
        default :       rdata_dmem = 32'h0;
    endcase
end

/*
assign o_lsu_buff.data_buff = rdata_dmem;
assign o_lsu_buff.rd_buff   = i_agu_lsu_pkg.rd_addr;
assign o_lsu_buff.wr_en     = i_agu_lsu_pkg.wr_en;
assign o_lsu_buff.is_instr2 = i_agu_lsu_pkg.is_instr2;
assign o_lsu_buff.valid     = valid;
*/
assign o_lsu_buff.data_buff = rdata_dmem;
assign o_lsu_buff.rd_buff   = rd_addr;
assign o_lsu_buff.wr_en     = wr_en;
assign o_lsu_buff.is_instr2 = is_instr2;
assign o_lsu_buff.valid     = valid;
// Debug
logic lsu_wren_db;
logic is_instr2_db;

assign lsu_wren_db = i_agu_lsu_pkg.wr_en;
assign is_instr2_db = i_agu_lsu_pkg.is_instr2;

endmodule : lsu



