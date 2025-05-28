module lsu(
	input  logic clk_i, rst_ni, st_en, 
	input  logic ld_halfword, ld_byte, // additional signal
	input  logic [11:0] addr,  // 0x000 ---> 0xFFF
	input  logic [31:0] st_data, io_sw,
	output logic [31:0] ld_data, io_lcd, io_ledg, io_ledr,
	output logic [31:0] io_hex0, io_hex1, io_hex2, io_hex3, io_hex4, io_hex5, io_hex6, io_hex7 
);

// 0x000 ---> 0x3FF : Data Memory
// 0x400 ---> 0x4FF : IO_output
// 0x500 ---> 0x5FF : IO_Switch
// 0x600 ---> 0xFFF : Reserved 

// 12345470 = 0100 0111 0000 
reg [7:0] d_memory [4095:0];  // data memory   
reg [31:0] sw_memory;

wire logic io_addr, sw_addr, reserved;
reg [31:0] Word, st_data_temp;
assign io_addr  = ~addr[11] &  addr[10] & ~addr[9] & ~addr[8];  // 0x3FF < addr < 0x500 
assign sw_addr  = ~addr[11] &  addr[10] & ~addr[9] &  addr[8];  // 0x4FF < addr < 0x600
assign reserved =  addr[11] | (addr[10] & addr[9]);             // addr > 5FF (>= 0110 0000 0000)

assign st_data_temp[7:0]   = st_data[7:0];
assign st_data_temp[15:8]  = st_data[15:8]  & {8 {~ld_byte}};                 // All LOW when executing SB
assign st_data_temp[31:16] = st_data[31:16] & {16{~(ld_byte | ld_halfword)}}; // All LOW when executing SB, SH

always_ff@(posedge clk_i, negedge rst_ni) begin
	if(!rst_ni) begin
			Word <= 32'b0;
			for (int i = 0; i < 1023; i = i + 1) begin
				d_memory[i] <= 8'b0;  // Free all mem space
			end
	end
	else if (st_en) begin 		              // Including output peripheral
			d_memory[addr]   <= st_data_temp[7:0];
			d_memory[addr+1] <= st_data_temp[15:8];
			d_memory[addr+2] <= st_data_temp[23:16];
			d_memory[addr+3] <= st_data_temp[31:24];
			Word             <= 32'b0;
	end
	else if (io_addr | sw_addr | reserved) begin
            Word <= 32'b0; 
	end
	else begin
			Word[7:0]   <= d_memory[addr];
			Word[15:8]  <= d_memory[addr+1];
			Word[23:16] <= d_memory[addr+2];
			Word[31:24] <= d_memory[addr+3];
	end
end


wire logic sel_hex0, sel_hex1, sel_hex2, sel_hex3, sel_hex4, sel_hex5, sel_hex6, sel_hex7; 
wire logic sel_LEDG, sel_LEDR, sel_LCD;
wire logic [3:0] mux_sel;

// Input Peripheral memory (always updating)
register_32bit		switch(.en(1'b1),  .clk(clk_i), .rst_n(rst_ni), .D(io_sw), .Q(sw_memory) ); 
// Output Peripheral memory
register_32bit		hex0  (.en(sel_hex0 & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_hex0) ); 
register_32bit		hex1  (.en(sel_hex1 & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_hex1) ); 
register_32bit		hex2  (.en(sel_hex2 & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_hex2) ); 
register_32bit		hex3  (.en(sel_hex3 & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_hex3) ); 
register_32bit		hex4  (.en(sel_hex4 & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_hex4) ); 
register_32bit		hex5  (.en(sel_hex5 & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_hex5) ); 
register_32bit		hex6  (.en(sel_hex6 & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_hex6) ); 
register_32bit		hex7  (.en(sel_hex7 & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_hex7) ); 
register_32bit		ledr  (.en(sel_LEDR & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_ledr) ); 
register_32bit		ledg  (.en(sel_LEDG & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_ledg) ); 
register_32bit		lcd   (.en(sel_LCD  & st_en),  .clk(clk_i), .rst_n(rst_ni), .D(st_data_temp), .Q(io_lcd)  ); 


// Select signal for "{ld_data}"																	// Default: mux_sel = 0000 (data memory)
assign sel_hex0    = (io_addr) & ~addr[7] & ~addr[6] & ~addr[5] & ~addr[4]; // x400, mux_sel = 0001
assign sel_hex1    = (io_addr) & ~addr[7] & ~addr[6] & ~addr[5] &  addr[4]; // x410, mux_sel = 0010
assign sel_hex2    = (io_addr) & ~addr[7] & ~addr[6] &  addr[5] & ~addr[4]; // x420, mux_sel = 0011
assign sel_hex3    = (io_addr) & ~addr[7] & ~addr[6] &  addr[5] &  addr[4]; // x430, mux_sel = 0100
assign sel_hex4    = (io_addr) & ~addr[7] &  addr[6] & ~addr[5] & ~addr[4]; // x440, mux_sel = 0101
assign sel_hex5    = (io_addr) & ~addr[7] &  addr[6] & ~addr[5] &  addr[4]; // x450, mux_sel = 0110
assign sel_hex6    = (io_addr) & ~addr[7] &  addr[6] &  addr[5] & ~addr[4]; // x460, mux_sel = 0111
assign sel_hex7    = (io_addr) & ~addr[7] &  addr[6] &  addr[5] &  addr[4]; // x470, mux_sel = 1000
assign sel_LEDR    = (io_addr) &  addr[7] & ~addr[6] & ~addr[5] & ~addr[4]; // x480, mux_sel = 1001
assign sel_LEDG    = (io_addr) &  addr[7] & ~addr[6] & ~addr[5] &  addr[4]; // x490, mux_sel = 1010
assign sel_LCD     = (io_addr) &  addr[7] & ~addr[6] &  addr[5] & ~addr[4]; // x4A0, mux_sel = 1011
// mul_sel = 1100 : sw_memory
assign mux_sel[0] = sel_hex0 | sel_hex2 | sel_hex4 | sel_hex6 | sel_LEDR | sel_LCD;
assign mux_sel[1] = sel_hex1 | sel_hex2 | sel_hex5 | sel_hex6 | sel_LEDG | sel_LCD;
assign mux_sel[2] = sel_hex3 | sel_hex4 | sel_hex5 | sel_hex6 | sw_addr;
assign mux_sel[3] = sel_hex7 | sel_LEDR | sel_LEDG | sel_LCD  | sw_addr;

wire logic [31:0] ld_data_temp;
mux_16X1_32bit     LOAD (.sel(mux_sel),   .Y(ld_data_temp),
                         .D0(Word),       .D1(io_hex0), .D2(io_hex1),  .D3(io_hex2),
                         .D4(io_hex3),    .D5(io_hex4), .D6(io_hex5),  .D7(io_hex6),				
                         .D8(io_hex7),    .D9(io_ledr), .D10(io_ledg), .D11(io_lcd),
                         .D12(sw_memory), .D13(32'b0),  .D14(32'b0),   .D15(32'b0)  ); 

assign ld_data[7:0]   = ld_data_temp[7:0];                                   
assign ld_data[15:8]  = ld_data_temp[15:8]  & {8 {~ld_byte}};		            // all LOW for LH, LW,.. instructions	    
assign ld_data[31:16] = ld_data_temp[31:16] & {16{~(ld_byte | ld_halfword)}}; // all LOW for LH, LW,.. instructions
endmodule
	
	
	
	
	
	

