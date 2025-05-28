module hazard_detection(
    input  logic [4:0] rs1_ID, rs2_ID,  
    input  logic [4:0] rd_EX,   
    input  logic MemRead_EX,          // MemRead signal in EX stage
    output logic PC_Write,            // Enable signal to fetch new PC
    output logic IF_buffer_Write,     // Enable signal to write to IF/ID buffers
    output logic NOP                  // "stall" signals
);
wire logic rd_EX_not_R0, Hazard;
wire logic rd_EX_eq_rs1, rd_EX_eq_rs2;

assign rd_EX_not_R0 = rd_EX[4] | rd_EX[3] | rd_EX[2] | rd_EX[1] | rd_EX[0];

comparator_5bit   RS1_VS_RD_EX  (.A(rs1_ID), .B(rd_EX), .equal(rd_EX_eq_rs1), .larger(), .smaller() );
comparator_5bit   RS2_VS_RD_EX  (.A(rs2_ID), .B(rd_EX), .equal(rd_EX_eq_rs2), .larger(), .smaller() );

assign Hazard = MemRead_EX & rd_EX_not_R0 & (rd_EX_eq_rs1 | rd_EX_eq_rs2);
assign PC_Write        = ~Hazard;
assign IF_buffer_Write = ~Hazard;
assign NOP             =  Hazard;


endmodule
