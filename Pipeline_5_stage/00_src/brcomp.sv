module brcomp(
	input  logic [31:0] rs1_data, rs2_data,
	input  logic br_unsigned,
	output logic br_less, br_equal, br_greater
);

comparator_32bit	 Compare (.A(rs1_data), .B(rs2_data), .is_unsigned(br_unsigned), .equal(br_equal), .smaller(br_less), .larger(br_greater) );
endmodule
