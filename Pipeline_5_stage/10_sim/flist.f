      
-f ./../00_src/datapath_components/datapath_components_flist.f

./../00_src/brcomp.sv
./../00_src/regfile.sv
./../00_src/ALU.sv
./../00_src/ctrl_unit.sv
./../00_src/ImmGen.sv
./../00_src/instr_ROM.sv
./../00_src/lsu.sv
./../00_src/Forwarding_unit.sv
./../00_src/Hazard_detection.sv
./../00_src/BTB.sv
./../00_src/pipeline.sv
./../01_bench/pipeline_tb.sv


./config.vlt
--timescale 1ns/1ps
--top-module pipeline_tb
