-f ./../../0_datapath_components/datapath_components_flist.f

./../00_src/FPU_adder_32bit.sv
./../00_src/exception_handler.sv
./../00_src/exp_unit.sv
./../00_src/fract_unit.sv
./../00_src/normalization_unit.sv
./../00_src/mantissa_align_unit.sv
./../00_src/sign_unit.sv
./../00_src/LZC_32bit.sv

./../01_bench/FPU_adder_32bit_tb.sv

--timescale 1ns/1ps
--top-module  FPU_adder_32bit_tb
