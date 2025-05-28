//-f ./../../00_src/datapath_components/datapath_components_flist.f
-I./../../00_src/datapath_components/comparator/comparator_32bit.sv
-I./../../00_src/datapath_components/comparator/comparator_5bit.sv
-I./../../00_src/datapath_components/comparator/comparator_4bit.sv
-I./../../00_src/datapath_components/comparator/equal_comparator_5bit.sv

./../../00_src/include/aqua_pkg.sv
./../../00_src/include/riscv_pkg.sv


./../../00_src/dmem.sv
./../../01_bench/Dmem_tb.sv
./config.vlt
--timescale 1ns/1ps
--top-module   Dmem_tb
