bin_files: 
	mkdir -p bin/tests/${TEST}
	riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -c tests/${TEST}/instr.s -o bin/tests/${TEST}/instr.o
	riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -o bin/tests/${TEST}/instr.elf bin/tests/${TEST}/instr.o
	riscv64-unknown-elf-objcopy -O binary bin/tests/${TEST}/instr.elf bin/tests/${TEST}/instr.bin
	xxd -p -c 4 bin/tests/${TEST}/instr.bin | awk '{ print substr($$0,7,2) substr($$0,5,2) substr($$0,3,2) substr($$0,1,2) }' > bin/tests/${TEST}/instr.mem
compile_tb:
	mkdir -p bin/tests/${TEST}
	iverilog -o bin/tests/${TEST}/${TEST}.out tests/tb.v src/exec.v src/ifetch.v src/sram_4kb.v
run_test:
	mkdir -p results/${TEST}
	python3 tests/${TEST}/init_sram.py
	vvp bin/tests/${TEST}/${TEST}.out +instr=bin/tests/${TEST}/instr.mem +mem=bin/tests/${TEST}/init_sram.mem +wave=results/${TEST}/waveforms.vcd > results/${TEST}/result.txt
test_shifts:
	make bin_files TEST=shifts
	make compile_tb TEST=shifts
	make run_test TEST=shifts
test_all:
	make test_shifts