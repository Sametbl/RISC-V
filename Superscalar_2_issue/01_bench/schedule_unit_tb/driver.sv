import aqua_pkg::*;

module driver (
    // inputs
    input  logic    i_clk              ,
    input  logic    i_rstn             ,
    input  logic    o_sch_dque_request ,
    // outputs
    output logic    i_dque_sch_ready   ,
    output logic    i_dque_sch_ack     ,
    output decode_s i_dque_sch_decode_0,
    output decode_s i_dque_sch_decode_1
    );

    always @(posedge i_clk) begin: proc_ff_stimuli
        i_dque_sch_ack      <= '1;
        /* verilator lint_off WIDTHTRUNC */
        i_dque_sch_ready    <= $urandom_range(0,1);
        /* verilator lint_off WIDTHTRUNC */
        i_dque_sch_decode_0.valid  <= '1;
        i_dque_sch_decode_1.valid  <= '1;
        if (o_sch_dque_request) begin
            i_dque_sch_decode_0.funct   <= funct_e'($urandom_range(0,4));
            i_dque_sch_decode_1.funct   <= funct_e'($urandom_range(0,4));
            /* verilator lint_off WIDTHTRUNC */
            i_dque_sch_decode_0.rd_addr <= $urandom_range(0,32)         ;
            i_dque_sch_decode_1.rd_addr <= $urandom_range(0,32)         ;
            /* verilator lint_off WIDTHTRUNC */
        end
    end

endmodule: driver
