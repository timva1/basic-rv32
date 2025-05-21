bin_files_from_asm: 
	@mkdir -p bin/tests/${TEST}
	@riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -c tests/${TEST}/instr.s -o bin/tests/${TEST}/instr.o
	@riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -o bin/tests/${TEST}/instr.elf bin/tests/${TEST}/instr.o
	@riscv64-unknown-elf-objcopy -O binary bin/tests/${TEST}/instr.elf bin/tests/${TEST}/instr.bin
	@xxd -p -c 4 bin/tests/${TEST}/instr.bin | awk '{ print substr($$0,7,2) substr($$0,5,2) substr($$0,3,2) substr($$0,1,2) }' > bin/tests/${TEST}/instr.mem
bin_files: 
	@mkdir -p bin/tests/${TEST}
	@riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -S tests/${TEST}/main.c -o bin/tests/${TEST}/main.s
	@riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -c build/start.s -o bin/tests/${TEST}/start.o
	@riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -c bin/tests/${TEST}/main.s -o bin/tests/${TEST}/instr.o
	@riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -T build/linker.ld bin/tests/${TEST}/start.o bin/tests/${TEST}/instr.o -o bin/tests/${TEST}/prgm.elf 
	@riscv64-unknown-elf-objcopy -O binary bin/tests/${TEST}/prgm.elf bin/tests/${TEST}/prgm.bin
	@(echo "00000000"; yes "00000000" | head -n 16; \
	xxd -p -c 4 bin/tests/${TEST}/prgm.bin | awk '{ print substr($$0,7,2) substr($$0,5,2) substr($$0,3,2) substr($$0,1,2) }') \
	> bin/tests/${TEST}/prgm.mem
compile_tb_asm:
	@mkdir -p bin/tests/${TEST}
	@iverilog -o bin/tests/${TEST}/${TEST}.out tests/tb_asm.v src/exec.v src/ifetch.v src/sram_4kb.v
compile_tb_c:
	@mkdir -p bin/tests/${TEST}
	@iverilog -o bin/tests/${TEST}/${TEST}.out tests/tb_c.v src/exec.v src/ifetch.v src/sram_4kb.v
run_test_c:
	@mkdir -p results/${TEST}
	@python3 tests/${TEST}/init_sram.py
	@vvp bin/tests/${TEST}/${TEST}.out +instr=bin/tests/${TEST}/prgm.mem +mem=bin/tests/${TEST}/prgm.mem +wave=results/${TEST}/waveforms.vcd +out=results/${TEST}/sram_final.mem > results/${TEST}/result.txt
run_test_asm:
	@mkdir -p results/${TEST}
	@python3 tests/${TEST}/init_sram.py
	@vvp bin/tests/${TEST}/${TEST}.out +instr=bin/tests/${TEST}/instr.mem +mem=bin/tests/${TEST}/init_sram.mem +wave=results/${TEST}/waveforms.vcd +out=results/${TEST}/sram_final.mem > results/${TEST}/result.txt
test_shifts:
	make bin_files_from_asm TEST=shifts
	make compile_tb_asm TEST=shifts
	make run_test_asm TEST=shifts
test_fib:
	make bin_files_from_asm TEST=fibonacci
	make compile_tb_asm TEST=fibonacci
	make run_test_asm TEST=fibonacci
test_primes:
	make bin_files TEST=primes
	make compile_tb_c TEST=primes
	make run_test_c TEST=primes
test_all:
	@make test_shifts
	@make test_fib
	@make test_primes