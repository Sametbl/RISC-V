-f ./../../00_src/datapath_components/datapath_components_flist.f
./../../00_src/include/aqua_pkg.sv
./../../00_src/include/riscv_pkg.sv


./../../00_src/aqua_processor.sv
./../../00_src/next_pc_unit.sv
./../../00_src/instr_fetch.sv
./../../00_src/instruction_cache.sv
./../../00_src/branch_unit.sv
./../../00_src/decoder.sv
./../../00_src/decode_queue.sv
./../../00_src/schedule_unit.sv
./../../00_src/regfile.sv
./../../00_src/forwarding_unit.sv
./../../00_src/arbitrator.sv
./../../00_src/alu.sv
./../../00_src/bru.sv
./../../00_src/agu.sv
./../../00_src/lsu.sv
./../../00_src/dmem.sv
./../../01_bench/aqua_processor_tb.sv

./config.vlt
--timescale  1ns/1ps
--top-module aqua_processor_tb
