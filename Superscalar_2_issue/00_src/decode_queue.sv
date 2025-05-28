//
import aqua_pkg::*;

module decode_queue #(parameter int DEPTH = 16) (
    input  logic          i_clk             ,   // Clock
    input  logic          i_rstn            ,   // Reset
    input  logic          i_sch_dque_request,   // request from chedule unit to decode queue
    input  decode_t [1:0] i_dec_dque_data   ,   // data from decoders to decode queue
    output decode_t [1:0] o_decode          ,   // data from decode queue to schedule unit
    output logic          o_dque_sch_ack    ,   // acknoledgement from decode queue to schedule unit
    output logic          o_dque_sch_ready  ,   // ready from decode queue to schedule unit
    output logic          o_dque_fbuff_busy     // bussy from decode queue to fetch
    );

    // localparam int ADDRWIDTH = $clog2(DEPTH);

logic   wren;    // FIFO_PUSH enable
logic   rden;    // FIFO_POP  enable
logic   empty;   // Indicate FIFO is Empty

assign wren = i_rstn & (i_dec_dque_data[0].valid | i_dec_dque_data[1].valid);
assign rden = i_rstn &  i_sch_dque_request;
assign o_dque_sch_ready = ~empty;

sync_fifo #(.ENTRIES(DEPTH)) queue (
    .i_clk       (i_clk            ),
    .i_rstn      (i_rstn           ),
    .i_wren      (wren             ),
    .i_rden      (rden             ),
    .i_decode    (i_dec_dque_data  ),
    .o_decode    (o_decode         ),
    .o_data_valid(o_dque_sch_ack   ),
    .o_full      (o_dque_fbuff_busy),
    .o_empty     (empty            ),
    .o_aempty    (                 ),
    .o_afull     (                 )
);

endmodule: decode_queue











// ==============================================================================

module sync_fifo #(parameter int ENTRIES = 16)(
    input  logic          i_clk       ,
    input  logic          i_rstn      ,
    input  logic          i_wren      ,        // FIFO_PUSH
    input  logic          i_rden      ,        // FIFO_POP
    input  decode_t [1:0] i_decode    ,        // data_in
    output logic          o_full      ,        // HIGH when FIFO is full
    output logic          o_afull     ,
    output logic          o_empty     ,        // HIGH when FIFO is empty
    output logic          o_aempty    ,
    output decode_t [1:0] o_decode    ,        // data_out
    output logic          o_data_valid         // Output data is valid
    );

// Local parameters
localparam int ADDRWIDTH = $clog2(ENTRIES);

logic [ADDRWIDTH:0]   rd_count;         // D - Read  pointer
logic [ADDRWIDTH:0]   wr_count;         // D - Write pointer
logic [ADDRWIDTH:0]   rd_count_next;    // Q - Read  pointer
logic [ADDRWIDTH:0]   wr_count_next;    // Q - Write pointer
logic [ADDRWIDTH-1:0] rd_addr;          // Read  Address
logic [ADDRWIDTH-1:0] wr_addr;          // Write Address
logic                 wr_allow;         // Read  Enable
logic                 rd_allow;         // Write Enable


// Fifo internal memory
decode_t [1:0] mem [ENTRIES];

assign rd_addr       = rd_count[ADDRWIDTH-1:0];
assign wr_addr       = wr_count[ADDRWIDTH-1:0];
assign rd_count_next = rd_count + 1;
assign wr_count_next = wr_count + 1;

assign wr_allow      = i_wren & ~o_full ;    // Allow to PUSH when FIFO is not Full
assign rd_allow      = i_rden & ~o_empty;    // Allow to POP  when FIFO is not Empty

// FIFO buffer
always @(posedge i_clk, negedge i_rstn) begin : proc_memory
    if (!i_rstn)  for (int i = 0; i < ENTRIES; i++) begin
                         mem[wr_addr] <= {$bits(o_decode){1'b0}};
    end
    else if(wr_allow)    mem[wr_addr] <= i_decode;
    else                 mem[wr_addr] <= mem[wr_addr];
end


// Write pointer
always @(posedge i_clk, negedge i_rstn) begin : proc_write_pointer
    if (~i_rstn)          wr_count <=  {(ADDRWIDTH +1){1'b0}};
    else if (wr_allow)    wr_count <=  wr_count_next;
    else                  wr_count <=  wr_count     ;
end


// Read pointer
always @(posedge i_clk, negedge i_rstn) begin : proc_read_pointer
    if (~i_rstn)          rd_count  <=  {(ADDRWIDTH +1){1'b0}};
    else if (rd_allow)    rd_count  <=  rd_count_next;
    else                  rd_count  <=  rd_count     ;
end


// Output assignment
assign o_decode     = mem[rd_addr];
assign o_data_valid = rd_allow;
assign o_empty      = ~|(wr_count ^ rd_count);        // When wr_count = rd_count      = 0
assign o_aempty     = ~|(wr_count ^ rd_count_next);   // When wr_count = rd_count_next = 0

// When
assign o_full       =   (wr_count[ADDRWIDTH] ^ rd_count[ADDRWIDTH]) & (~|(wr_addr ^ rd_addr));
assign o_afull      =   (wr_count_next[ADDRWIDTH] ^ rd_count[ADDRWIDTH]) &
                        (~|(wr_count_next[ADDRWIDTH-1:0] ^ rd_addr));


endmodule: sync_fifo

