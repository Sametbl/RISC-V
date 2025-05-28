module scoreboard (
    input logic i_clk,
    input logic i_rstn,

    input decode_s    i_dque_sch_decode_0,
    input decode_s    i_dque_sch_decode_1,
    input logic [0:0] o_sch_dque_request ,
    input decode_s    o_sch_decode_0     ,
    input decode_s    o_sch_decode_1
    );
endmodule: scoreboard
