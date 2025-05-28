module branch_unit (
    input  logic        clk_i,
    input  logic        rst_n,
    input  logic        br_update,          // HIGH when actual Branch result from BRU is known
    input  logic        br_update_taken,    // HIGH when actual Branch result from BRU is TAKEN
    input  logic [31:0] br_update_target,   // Actual branch target address provided by BRU when updating
    input  logic [31:0] br_update_PC,
    input  logic [31:0] PC_fetch,           // Current program counter for prediction
    output logic [31:0] prd_target,         // Predicted branch target address
    output logic        prd_taken           // Indicates a prediction is made
);

wire logic hit;                  // BTB hit
wire logic [31:0] BTB_target;    // BTB's predicted target
wire logic gshare_prd_bit;   

BTB Target_Table   (.clk_i(clk_i),
                    .rst_n(rst_n),
                    .br_update(br_update),         
                    .br_update_taken(br_update_taken),   
                    .br_update_valid(1'b1),    
                    .br_update_PC(br_update_PC),
                    .br_update_target(br_update_target),  
                    .PC_fetch(PC_fetch),         
                    .BTB_target(BTB_target),        
                    .hit(hit)                 
);


GSharePredictor gshare_predictor (.clk_i(clk_i),
                                  .rst_n(rst_n),
                                  .PC_fetch(PC_fetch),
                                  .br_update_PC(br_update_PC),
                                  .br_update(br_update),
                                  .br_update_taken(br_update_taken),
                                  .prediction_bit(gshare_prd_bit)
);

assign prd_taken  = (~br_update) & hit & gshare_prd_bit;
assign prd_target = BTB_target;  

endmodule : branch_unit





module BTB (
    input  logic        clk_i,
    input  logic        rst_n,
    input  logic        br_update,          // HIGH when actual Branch result from BRU is known
    input  logic        br_update_taken,    // HIGH when actual Branch result from BRU is TAKEN
    input  logic        br_update_valid,    
    input  logic [31:0] br_update_PC,
    input  logic [31:0] br_update_target,   // Actual branch target address provided by BRU when updating
    input  logic [31:0] PC_fetch,           // Current program counter for prediction
    output logic [31:0] BTB_target,         // Branch target address stored in BTB
    output logic        hit                 // Indicates a BTB hit
);

// BTB with 64 entries
reg [23:0] BTB_tag   [0:63];            // Tags
reg [31:0] BTA       [0:63];            // Branch Target Address
reg        BTB_valid [0:63];            // Valid bits

wire logic [23:0] w_tag;
wire logic [5:0]  w_index;
assign w_tag   = br_update_PC[31:8];                // Extract tag   from PC
assign w_index = br_update_PC[7:2];                 // Extract index from PC


always @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 63; i++) begin
            BTB_tag[i]    <= 24'b0;
            BTB_valid[i]  <= 1'b0;
            BTA[i]        <= 32'b0;
        end
    end
    else if (br_update) begin           // Append or Update BTB
        BTB_tag[w_index]   <= w_tag;
        BTB_valid[w_index] <= br_update_valid;
        BTA[w_index]       <= br_update_target;
    end
    else begin
        BTB_tag[w_index]   <= BTB_tag[w_index];
        BTB_valid[w_index] <= BTB_valid[w_index];
        BTA[w_index]       <= BTA[w_index];
    end
end


// Outputs
wire logic [23:0] r_tag;
wire logic [5:0]  r_index;
wire logic        r_valid;
wire logic        r_exist;

assign r_tag   = PC_fetch[31:8];                // Extract tag   from PC
assign r_index = PC_fetch[7:2];                 // Extract index from PC
assign r_valid = BTB_valid[r_index];
assign r_exist = (r_tag == BTB_tag[r_index]) ? 1 : 0;


assign hit   = r_valid & r_exist;                     // Valid entry and tag match
assign BTB_target = BTA[r_index] & {32{hit}};         // Predicted target address

endmodule : BTB




module GSharePredictor(
    input  logic        clk_i,
    input  logic        rst_n,
    input  logic [31:0] PC_fetch,
    input  logic [31:0] br_update_PC,
    input  logic        br_update,
    input  logic        br_update_taken,
    output logic        prediction_bit   // HIGH = predicted taken
);
// GHR size = 8.
// Larger GHR might improve accuracy but higher cost due to the size of PHT
// Size of PHT = 2^sizeof(GHR) 
// The LSB of GHR is the oldest/newest bit. GHR shift in from LSB.


reg [7:0] GHR;                 // Global History Register      (Store recent branch pattern)
reg [1:0] PHT [0:255];         // Pattern History Table (PHT)  (Sotre 2-bit predictor)

wire logic [7:0] pht_index_update;
wire logic [7:0] pht_index_update_buff;
wire logic [1:0] current_counter_update;
wire logic [1:0] new_counter;
assign pht_index_update         = br_update_PC[9:2] ^ GHR;   // XORing to get Index sharing of PC anf GHR
assign current_counter_update   = PHT[pht_index_update];

//register_8bit    buffer  (.clk(clk_i), .rst_n(rst_n), .en(1'b1), .D(pht_index_update), .Q(pht_index_update_buff) );


always_ff @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) for (int i = 0; i < 255; i++)   PHT[i]                 <= 2'b00;
    else                                        PHT[pht_index_update]  <= new_counter;
end

left_shift_register_8bit      GHR_update   (.clk(clk_i),
                                            .rst_n(rst_n),
                                            .en(br_update),
                                            .D_in(br_update_taken),
                                            .Q(GHR)
);


// Logic Optimized: Br_update must be set for changes
saturation_adder_2bit     predictor_adder (.carry_in(br_update),
                                           .sub_mode(br_update_taken),
                                           .data_in (current_counter_update),
                                           .data_out(new_counter)
);

wire logic [7:0] pht_index_predict;
wire logic [1:0] current_counter_predict;
assign pht_index_predict        = PC_fetch[9:2] ^ GHR;   // XORing to get Index sharing of PC anf GHR
assign current_counter_predict  = PHT[pht_index_predict];
assign prediction_bit           = current_counter_predict[1];

endmodule : GSharePredictor






// Circuit Achieved by using Karnaugh map
module saturation_adder_2bit(
    input        carry_in,      // Carry in for adding to the data (also acts as enable pin)
    input        sub_mode,      // HIGH to enter saturation subtraction
    input  [1:0] data_in,
    output [1:0] data_out
);

// Rename signal
wire logic [1:0] X;
wire logic Y, M;
assign X = data_in;
assign Y = carry_in;
assign M = sub_mode;

assign data_out[0] = (X[0] & ~Y) | (X[1] & ~X[0] & Y) | (M & ~X[0] & Y) | (M & X[1] & Y);
assign data_out[1] = (X[1] & ~Y) | (X[1] &  X[0])     | (M &  X[0] & Y) | (M & X[1] & Y);

endmodule : saturation_adder_2bit




