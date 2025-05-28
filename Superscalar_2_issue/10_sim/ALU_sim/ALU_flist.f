-f ./../../00_src/datapath_components/datapath_components_flist.f
./../../00_src/include/aqua_pkg.sv
./../../00_src/include/riscv_pkg.sv


./../../00_src/ALU.sv
./../../01_bench/ALU_tb.sv
./config.vlt
--timescale 1ns/1ps
--top-module   ALU_tb
