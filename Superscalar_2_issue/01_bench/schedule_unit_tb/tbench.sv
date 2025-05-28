`define RESETPERIOD 50
`define FINISH      5000

import aqua_pkg::*;
module tbench;

    // Clock and reset generator
    logic i_clk;
    logic i_rstn;

    initial task_clock_gen(i_clk);
    initial task_reset(i_rstn, `RESETPERIOD);
    initial task_timeout(`FINISH);

    // Wave dumping
    initial begin : proc_dump_wave
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);
    end

    // Transaction
    //
    decode_s    i_dque_sch_decode_0;
    decode_s    i_dque_sch_decode_1;
    logic [0:0] i_dque_sch_ready   ;
    logic [0:0] i_dque_sch_ack     ;
    //
    logic [0:0] o_sch_dque_request ;
    decode_s    o_sch_decode_0     ;
    decode_s    o_sch_decode_1     ;

    driver driver_unit (
        .i_clk               (i_clk              ),
        .i_rstn              (i_rstn             ),
        .o_sch_dque_request  (o_sch_dque_request ),
        .i_dque_sch_decode_0 (i_dque_sch_decode_0),
        .i_dque_sch_decode_1 (i_dque_sch_decode_1),
        .i_dque_sch_ready    (i_dque_sch_ready   ),
        .i_dque_sch_ack      (i_dque_sch_ack     )
    );

    schedule_unit DUT (
        // inputs
        .i_clk               (i_clk              ),
        .i_rstn              (i_rstn             ),
        .i_dque_sch_decode_0 (i_dque_sch_decode_0),
        .i_dque_sch_decode_1 (i_dque_sch_decode_1),
        .i_dque_sch_ready    (i_dque_sch_ready   ),
        .i_dque_sch_ack      (i_dque_sch_ack     ),
        // outputs
        .o_sch_dque_request  (o_sch_dque_request ),
        .o_sch_decode_0      (o_sch_decode_0     ),
        .o_sch_decode_1      (o_sch_decode_1     )
    );

    scoreboard scoreboard_unit (
        .i_clk               (i_clk              ),
        .i_rstn              (i_rstn             ),
        .i_dque_sch_decode_0 (i_dque_sch_decode_0),
        .i_dque_sch_decode_1 (i_dque_sch_decode_1),
        .o_sch_dque_request  (o_sch_dque_request ),
        .o_sch_decode_0      (o_sch_decode_0     ),
        .o_sch_decode_1      (o_sch_decode_1     )
    );

    // Ignore this
    // Debug signal
    funct_e     i_funct0   = i_dque_sch_decode_0.funct;
    funct_e     i_funct1   = i_dque_sch_decode_1.funct;
    logic [4:0] i_rd_addr0 = i_dque_sch_decode_0.rd_addr;
    logic [4:0] i_rd_addr1 = i_dque_sch_decode_1.rd_addr;
    logic       i_valid0   = i_dque_sch_decode_0.valid;
    logic       i_valid1   = i_dque_sch_decode_1.valid;
    funct_e     o_funct0   = o_sch_decode_0.funct;
    funct_e     o_funct1   = o_sch_decode_1.funct;
    logic [4:0] o_rd_addr0 = o_sch_decode_0.rd_addr;
    logic [4:0] o_rd_addr1 = o_sch_decode_1.rd_addr;
    logic       o_valid0   = o_sch_decode_0.valid;
    logic       o_valid1   = o_sch_decode_1.valid;

endmodule: tbench
