import aqua_pkg::*;

module dmem #(parameter int DMEM_W = 16) (
    input  logic             i_clk,
    input  logic             i_rst_n,
    input  logic             i_wren,
    input  logic [31:0]      i_wdata,
    input  logic [31:0]      i_addr,
    input  logic [3:0]       i_bytemask,
    output logic [31:0]      o_mem_data
);

logic [7:0]   mem [2**DMEM_W-1];

initial for (int i=0; i < 2**DMEM_W; i++) mem[i] = 0;


// Read - i_wren
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)    for (int i=0; i < 2**DMEM_W; i++)    mem[i] <= 0;
    else begin
        if (i_wren) begin
            // With 32 bit data, bitmask has 3 bits
            // lITTLE ENDIAN
            if (i_bytemask[0])     mem[i_addr]     <= i_wdata[7:0];
            if (i_bytemask[1])     mem[i_addr + 1] <= i_wdata[15:8];
            if (i_bytemask[2])     mem[i_addr + 2] <= i_wdata[23:16];
            if (i_bytemask[3])     mem[i_addr + 3] <= i_wdata[31:24];
        end

        o_mem_data [7:0]     <= mem[i_addr]     & {8{i_bytemask[0]}};
        o_mem_data [15:8]    <= mem[i_addr + 1] & {8{i_bytemask[1]}};
        o_mem_data [23:16]   <= mem[i_addr + 2] & {8{i_bytemask[2]}};
        o_mem_data [31:24]   <= mem[i_addr + 3] & {8{i_bytemask[3]}};

    end
end


endmodule : dmem
