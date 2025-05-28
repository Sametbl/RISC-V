# Update filelist
TARGET = -f ./LSU_flist.f

# Update .ron file name
WAVE_RON = ./LSU.ron

# Update top module (testbench module)
TOP = LSU_tb
SEED = 1

FLAGS =  --binary -Wall --trace --sv --timing
FLAGS += -O3 --compiler gcc -CFLAGS -std=gnu++20
FLAGS += -x-initial unique
FLAGS += -x-assign unique
FLAGS += --assert
FLAGS += --build -j 0 --quiet --trace-fst

#Remove this while debugging
FLAGS += --Wno-PINCONNECTEMPTY --Wno-IMPORTSTAR
FLAGS += -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME -Wno-UNDRIVEN

LFLAGS = --lint-only --sv --timing
RFLAGS =  +verilator+seed+$(SEED)
RFLAGS += +verilator+quiet

.PHONY: lint
lint:
	@echo "-> LINT"
	verilator $(LFLAGS) $(TARGET)

.PHONY: sim
sim:
	@echo "-> SIMULATION"
	verilator $(FLAGS) $(TARGET) 2>&1 | tee log

.PHONY: run
run:
	@echo "-> RUN"
	./obj_dir/V$(TOP) $(RFLAGS)

.PHONY: wave
wave:
	surfer wave.vcd

.PHONY: wavefrom
waveform:
	surfer wave.vcd -s $(WAVE_RON)

.PHONY: clean
clean:
	@echo "-> CLEAN"
	@rm -rf ./obj_dir *.vcd



.PHONY: all
all: 
	@echo "-> Build all"
	$(MAKE) clean
	$(MAKE) lint
	$(MAKE) sim
	$(MAKE) run
	$(MAKE) wave




