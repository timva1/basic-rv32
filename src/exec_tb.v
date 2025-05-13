`timescale 1ns/1ns

// test register loading with lui and li instructions
module test;

    reg rst_n = 0;

    reg init = 1;
    reg init_clk = 0;
    always #1 init_clk = !init_clk;

    initial begin
        # 10 rst_n = 1; // start in reset mode
        # 126 init = 0; // time to initialize all registers but x0 (time for 1 lui and 1 li for each register)
        # 120 $finish; // finish all tests
    end

    reg clk_osc = 0; // regular clock driver, after initialization period (100MHz)
    always #5 clk_osc = !clk_osc;

    // clock driven by 100MHz oscillator unless if currently initializing
    wire clk = init ? init_clk : clk_osc;

    initial begin
        $dumpfile("waveforms/exec-test/exec_test.vcd");
        $dumpvars(0, test);
        $readmemh("bin/exec-test/exec_test.mem", ni.instr_mem);
    end

    wire [31:0] f_instr;
    wire [31:0] f_pc;
    
    cpu_ifetch ni (
        .clk(clk), 
        .rst_n(rst_n), 
        .f_instr(f_instr), 
        .f_pc(f_pc)
    );

    exec ex (
        .clk(clk),
        .rst_n(rst_n),
        .f_instr(f_instr),
        .f_pc(f_pc)
    );

endmodule
