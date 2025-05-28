module Mux_32X1(
		input  logic [4:0] Sel,
		input  logic [31:0] I,
		output logic OUT
);
wire logic Top, Bottom;
Mux_16X1		 Layer1_1 (.Sel(Sel[3:0]), .I(I[15:0]),  .OUT(Bottom));
Mux_16X1		 Layer1_2 (.Sel(Sel[3:0]), .I(I[31:16]), .OUT(Top));
Mux_2X1		 Layer2   (.Sel(Sel[4]), .A(Bottom), .B(Top), .OUT(OUT));											
endmodule 

//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------

module Mux_16X1(
		input  logic [3:0] Sel,
		input  logic [15:0] I,
		output logic OUT
);
wire logic Top, Bottom;
Mux_8X1		 Layer1_1 (.Sel(Sel[2:0]), .I(I[7:0]),  .OUT(Bottom));
Mux_8X1		 Layer1_2 (.Sel(Sel[2:0]), .I(I[15:8]), .OUT(Top));
Mux_2X1		 Layer2   (.Sel(Sel[3]), .A(Bottom), .B(Top), .OUT(OUT));								
							
endmodule 


//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------
module Mux_8X1(
	 input  logic [2:0] Sel,
	 input  logic [7:0] I,
	 output logic OUT
);
 logic Bottom, Top;
 Mux_4X1			Layer1_1 (.Sel(Sel[1:0]), .I(I[3:0]), .OUT(Bottom));
 Mux_4X1 		Layer1_2 (.Sel(Sel[1:0]), .I(I[7:4]), .OUT(Top));
 Mux_2X1			Layer2   (.Sel(Sel[2]), .A(Bottom), .B(Top), .OUT(OUT));
endmodule


//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------
module Mux_4X1(
	 input  logic [3:0] I,
	 input  logic [1:0] Sel,
	 output logic OUT
);
wire logic Top, Bottom;
Mux_2X1      Layer1_1 (.Sel(Sel[0]), .A(I[0]),   .B(I[1]), .OUT(Bottom));
Mux_2X1      Layer1_2 (.Sel(Sel[0]), .A(I[2]),   .B(I[3]), .OUT(Top));
Mux_2X1      Layer2   (.Sel(Sel[1]), .A(Bottom), .B(Top),  .OUT(OUT));
endmodule




//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------
module Mux_2X1(
	 input  logic A, B,
	 input  logic Sel,
	 output logic OUT
);
assign OUT = (A & ~Sel) | (B & Sel);
endmodule










