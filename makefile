ifetch_test:
	mkdir -p bin/ifetch-test
	mkdir -p waveforms/ifetch-test
	iverilog -o bin/ifetch-test/ifetch_test src/ifetch_tb.v src/ifetch.v src/sram_4kb.v
	vvp bin/ifetch-test/ifetch_test
	gtkwave waveforms/ifetch-test/ifetch_test.vcd
exec_test:
	python3 src/init_sram.py
	make bin_exec_test
	mkdir -p bin/exec-test
	mkdir -p waveforms/exec-test
	iverilog -o bin/exec-test/exec_test src/exec_tb.v src/exec.v src/ifetch.v src/sram_4kb.v
	vvp bin/exec-test/exec_test
	gtkwave waveforms/exec-test/exec_test.vcd
bin_exec_test:
	mkdir -p bin/exec-test
	riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -c src/exec_test.s -o bin/exec-test/exec_test.o
	riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -o bin/exec-test/exec_test.elf bin/exec-test/exec_test.o
	riscv64-unknown-elf-objcopy -O binary bin/exec-test/exec_test.elf bin/exec-test/exec_test.bin
	xxd -p -c 4 bin/exec-test/exec_test.bin | awk '{ print substr($$0,7,2) substr($$0,5,2) substr($$0,3,2) substr($$0,1,2) }' > bin/exec-test/exec_test.mem
bin_exec_reg_load_test:
	mkdir -p bin/exec-reg-load-test
	riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -c src/exec_reg_load_test.s -o bin/exec-reg-load-test/exec_reg_load_test.o
	riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -o bin/exec-reg-load-test/exec_reg_load_test.elf bin/exec-reg-load-test/exec_reg_load_test.o
	riscv64-unknown-elf-objcopy -O binary bin/exec-reg-load-test/exec_reg_load_test.elf bin/exec-reg-load-test/exec_reg_load_test.bin
	xxd -p -c 4 bin/exec-reg-load-test/exec_reg_load_test.bin | awk '{ print substr($$0,7,2) substr($$0,5,2) substr($$0,3,2) substr($$0,1,2) }' > bin/exec-reg-load-test/exec_reg_load_test.mem

