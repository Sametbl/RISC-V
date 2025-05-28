
// This module in integrated in "next_pc_unit"

module branch_unit (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_br_update_en,       // HIGH when actual Branch result from BRU is known
    input  logic        i_br_update_valid,
    input  logic        i_br_update_taken,    // HIGH when actual Branch result from BRU is TAKEN
    input  logic [31:0] i_br_update_pc,
    input  logic [31:0] i_br_update_target,   // Actual branch target provided by BRU when updating
    input  logic [31:0] i_current_pc,         // Current program counter for prediction
    output logic [31:0] o_prd_target,         // Predicted branch target address
    output logic        o_prd_taken,          // Indicates a prediction is made
    output logic        o_prd_miss_t,         // When Taken Prediction is FALSE
    output logic        o_prd_miss_nt         // When not_taken Prediction is FLASE
);

logic hit_1;
logic hit_2;
logic [31:0] prd_target_1;
logic [31:0] prd_target_2;
logic prediction_bit;
logic prd_taken_ID;
logic prd_taken_IS;
logic prd_taken_IS2;
logic prd_taken_EX;
logic prd_taken_EX2;

BTB   Target_Table (.i_clk             (i_clk                             ),
                    .i_rst_n           (i_rst_n                           ),
                    .i_current_pc      (i_current_pc                      ),
                    .i_current_pc_four (i_current_pc + 32'd4              ),
                    .i_br_update_en    (i_br_update_en & i_br_update_valid),
                    .i_br_update_pc    (i_br_update_pc                    ),
                    .i_br_update_valid (1'b1                              ),
                    .i_br_update_target(i_br_update_target                ),
                    .o_BTB_target_1    (prd_target_1                      ),
                    .o_BTB_target_2    (prd_target_2                      ),
                    .o_hit_1           (hit_1                             ),
                    .o_hit_2           (hit_2                             )
);


// Dynamic Predictor Instance
dynamic_predictor    predictor (
                    .i_clk            (i_clk                             ),
                    .i_rst_n          (i_rst_n                           ),
                    .i_br_update_en   (i_br_update_en & i_br_update_valid),
                    .i_br_update_taken(i_br_update_taken                ),
                    .o_prediction_bit (prediction_bit                    )
);

// Buffer the branch prediction and pass it to the EX stage for checking whether its correct
D_flip_flop prd_ID (.clk(i_clk), .rst_n(i_rst_n), .en(1'b1), .D(o_prd_taken),   .Q(prd_taken_ID));
D_flip_flop prd_IS (.clk(i_clk), .rst_n(i_rst_n), .en(1'b1), .D(prd_taken_ID),  .Q(prd_taken_IS));
D_flip_flop prd_IS2(.clk(i_clk), .rst_n(i_rst_n), .en(1'b1), .D(prd_taken_IS),  .Q(prd_taken_IS2));
D_flip_flop prd_EX (.clk(i_clk), .rst_n(i_rst_n), .en(1'b1), .D(prd_taken_IS2), .Q(prd_taken_EX));
D_flip_flop prd_EX2(.clk(i_clk), .rst_n(i_rst_n), .en(1'b1), .D(prd_taken_EX),  .Q(prd_taken_EX2));

mux #(.WIDTH(32), .NUM_INPUT(2)) mux_PC_four (
       .sel   (~hit_1),
       .i_mux ({prd_target_2, prd_target_1}),
       .o_mux (o_prd_target)
);


assign o_prd_taken   =  (hit_1 | hit_2) & prediction_bit;    // Not taken when updating BTB
assign o_prd_miss_t  =  i_br_update_en & i_br_update_valid & ~i_br_update_taken &  prd_taken_EX2;
assign o_prd_miss_nt =  i_br_update_en & i_br_update_valid &  i_br_update_taken & ~prd_taken_EX2;


endmodule : branch_unit







module BTB (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_br_update_en,       // HIGH when actual Branch result from BRU is known
    input  logic        i_br_update_valid,
    input  logic [31:0] i_br_update_pc,
    input  logic [31:0] i_br_update_target,   // Actual branch target provided by BRU when updating
    input  logic [31:0] i_current_pc,         // Current program counter for prediction
    input  logic [31:0] i_current_pc_four,    // Current program counter + 4 for prediction
    output logic [31:0] o_BTB_target_1,         // Branch target address stored in BTB
    output logic [31:0] o_BTB_target_2,         // Branch target address stored in BTB
    output logic        o_hit_1,                // Indicates a BTB hit
    output logic        o_hit_2                 // Indicates a BTB hit
);
// BTB with 64 entries
reg   [63:0][23:0] BTB_tag   ;            // Tags
reg   [63:0][31:0] BTA       ;            // Branch Target Address
reg   [63:0]       BTB_valid ;            // Valid bits

logic [23:0]       w_tag;
logic [5:0]        w_index;
assign w_tag    = i_br_update_pc[31:8];                // Extract tag   from PC
assign w_index  = i_br_update_pc[7:2];                 // Extract index from PC


always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        for (int i = 0; i < 63; i++) begin
            BTB_tag[i]    <= 24'b0;
            BTB_valid[i]  <= 1'b0;
            BTA[i]        <= 32'b0;
        end
    end
    else if (i_br_update_en) begin           // Append or Update BTB
        BTB_tag[w_index]   <= w_tag;
        BTB_valid[w_index] <= i_br_update_valid;
        BTA[w_index]       <= i_br_update_target;
    end
    else begin
        BTB_tag[w_index]   <= BTB_tag[w_index];
        BTB_valid[w_index] <= BTB_valid[w_index];
        BTA[w_index]       <= BTA[w_index];
    end
end


// Outputs
// PC
logic [23:0] r_tag_1;
logic [5:0]  r_index_1;
logic        r_valid_1;
logic        r_exist_1;

assign r_tag_1   = i_current_pc[31:8];                // Extract tag   from PC
assign r_index_1 = i_current_pc[7:2];                 // Extract index from PC
assign r_valid_1 = BTB_valid[r_index_1];
assign r_exist_1 = (r_tag_1 == BTB_tag[r_index_1]) ? 1 : 0;

assign o_hit_1        = r_valid_1 & r_exist_1;                     // Valid entry and tag match
assign o_BTB_target_1 = BTA[r_index_1] & {32{o_hit_1}};         // Predicted target address

// PC_four
logic [23:0] r_tag_2;
logic [5:0]  r_index_2;
logic        r_valid_2;
logic        r_exist_2;

assign r_tag_2   = i_current_pc_four[31:8];                // Extract tag   from PC
assign r_index_2 = i_current_pc_four[7:2];                 // Extract index from PC
assign r_valid_2 = BTB_valid[r_index_2];
assign r_exist_2 = (r_tag_2 == BTB_tag[r_index_2]) ? 1 : 0;


assign o_hit_2        = r_valid_2 & r_exist_2;                     // Valid entry and tag match
assign o_BTB_target_2 = BTA[r_index_2] & {32{o_hit_2}};         // Predicted target address


endmodule : BTB






module dynamic_predictor(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic i_br_update_en,          // HIGH when actual Branch result from BRU is known
    input  logic i_br_update_taken,    // HIGH when actual Branch result from BRU is TAKEN
    output logic o_prediction_bit      // HIGH when predicted to be taken
);

logic [1:0] D_predictor;
logic [1:0] Q_predictor;

always_ff @(posedge i_clk, negedge i_rst_n) begin : Register_with_preset
        if(!i_rst_n)       Q_predictor <= 2'b01;
        else               Q_predictor <= D_predictor;

end


// Logic Optimized: br_update_en must be set for changes
saturation_adder_2bit     predictor_adder (
                    .i_carry_in(i_br_update_en   ),
                    .i_sub_mode(i_br_update_taken),
                    .i_data_in (Q_predictor      ),
                    .o_data_out(D_predictor      )
);

assign o_prediction_bit = Q_predictor[1];       // When Predictor >= 2 or Predictor[1] == 1
endmodule : dynamic_predictor



// Circuit Achieved by using Karnaugh map
module saturation_adder_2bit(
    input        i_carry_in,      // Carry in for adding to the data (also acts as enable pin)
    input        i_sub_mode,      // HIGH to enter saturation add
    input  [1:0] i_data_in,
    output [1:0] o_data_out
);

// Rename signal
logic [1:0] X;
logic       Y;
logic       M;

assign X = i_data_in;
assign Y = i_carry_in;
assign M = i_sub_mode;

assign o_data_out[0] = (X[0] & ~Y) | (X[1] & ~X[0] & Y) | (M & ~X[0] & Y) | (M & X[1] & Y);
assign o_data_out[1] = (X[1] & ~Y) | (X[1] &  X[0])     | (M &  X[0] & Y) | (M & X[1] & Y);

// assign o_data_out[0] = (X[0] & ~Y) | (X[1] & ~X[0] & Y) | (~M & ~X[0] & Y) | (~M & X[1] & Y);
// assign o_data_out[1] = (X[1] & ~Y) | (X[1] & X[0]) | (~M & X[0] & Y) | (~M & X[1] & Y);

endmodule : saturation_adder_2bit
