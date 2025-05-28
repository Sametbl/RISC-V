module forwarding_unit(
    input  logic [4:0] rs1_EX, rs2_EX,          // rs to compare with rd
    input  logic [4:0] rs1_ID, rs2_ID,          // rs to compare with rd    
    input  logic [4:0] MEM_rd, WB_rd,           // rd from MEM/WB to compare with rs
    input  logic WB_MEM, WB_WB,                 // Regfile Write Enable signal from MEM/WB stages
    input  logic NONE_RS1_EX, NONE_RS2_EX,      // "rs1_EX" or "rs2_EX" are immediate value
    input  logic NONE_RS1_ID, NONE_RS2_ID,      // "rs1_ID" or "rs2_ID" are immediate value
    input  logic NONE_RD_MEM, NONE_RD_WB,       // "rd" in MEM and WB stage is immediate value
    output logic ForwardA_MEM, ForwardB_MEM,    // MEM ---> EX  (control MUX 2X1)
    output logic ForwardA_WB, ForwardB_WB,       // WB  ---> EX  (control MUX 2X1)
    output logic ForwardA_WB_ID, ForwardB_WB_ID // WB  ---> ID  (control MUX 2X1)    
);
wire logic Not_R0_MEM, Not_R0_WB;
assign Not_R0_MEM = MEM_rd[4] | MEM_rd[3] | MEM_rd[2] | MEM_rd[1] | MEM_rd[0];
assign Not_R0_WB  = WB_rd[4]  | WB_rd[3]  | WB_rd[2]  | WB_rd[1]  | WB_rd[0] ;

wire logic rd_MEM_eq_rs1_EX, rd_MEM_eq_rs2_EX;
comparator_5bit   RS1_EX_vs_rd_MEM  (.A(rs1_EX), .B(MEM_rd), .equal(rd_MEM_eq_rs1_EX), .larger(), .smaller() );
comparator_5bit   RS2_EX_vs_rd_MEM  (.A(rs2_EX), .B(MEM_rd), .equal(rd_MEM_eq_rs2_EX), .larger(), .smaller() );

wire logic rd_WB_eq_rs1_EX, rd_WB_eq_rs2_EX;
comparator_5bit   RS1_EX_vs_rd_WB   (.A(rs1_EX), .B(WB_rd),  .equal(rd_WB_eq_rs1_EX), .larger(), .smaller() );
comparator_5bit   RS2_EX_vs_rd_WB   (.A(rs2_EX), .B(WB_rd),  .equal(rd_WB_eq_rs2_EX), .larger(), .smaller() );

wire logic rd_WB_eq_rs1_ID, rd_WB_eq_rs2_ID;
comparator_5bit   RS1_ID_vs_rd_WB   (.A(rs1_ID), .B(WB_rd),  .equal(rd_WB_eq_rs1_ID), .larger(), .smaller() );
comparator_5bit   RS2_ID_vs_rd_WB   (.A(rs2_ID), .B(WB_rd),  .equal(rd_WB_eq_rs2_ID), .larger(), .smaller() );

assign ForwardA_WB_ID = Not_R0_WB & WB_WB & rd_WB_eq_rs1_ID  & ~(NONE_RD_WB | NONE_RS1_ID);
assign ForwardB_WB_ID = Not_R0_WB & WB_WB & rd_WB_eq_rs2_ID  & ~(NONE_RD_WB | NONE_RS2_ID);

assign ForwardA_MEM = Not_R0_MEM & WB_MEM & rd_MEM_eq_rs1_EX & ~(NONE_RD_MEM | NONE_RS1_EX);
assign ForwardB_MEM = Not_R0_MEM & WB_MEM & rd_MEM_eq_rs2_EX & ~(NONE_RD_MEM | NONE_RS2_EX);
assign ForwardA_WB  = Not_R0_WB  & WB_WB  & rd_WB_eq_rs1_EX  & ~(NONE_RD_WB  | NONE_RS1_EX);
assign ForwardB_WB  = Not_R0_WB  & WB_WB  & rd_WB_eq_rs2_EX  & ~(NONE_RD_WB  | NONE_RS2_EX);

endmodule
