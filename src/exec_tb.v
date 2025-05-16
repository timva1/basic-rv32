`timescale 1ns/1ns

// test register loading with lui and li instructions
module test;

    reg rst_n = 0;
    initial begin
        # 10 rst_n = 1; // start in reset mode
        # 120 $finish; // finish all tests
    end

    reg clk = 0; // 500MHz clock
    always #1 clk = !clk;

    initial begin
        $dumpfile("waveforms/exec-test/exec_test.vcd");
        $dumpvars(0, test);
        $dumpvars(0, 
            ex.sram.mem_array[0], 
            ex.sram.mem_array[1],
            ex.sram.mem_array[2], 
            ex.sram.mem_array[3], 
            ex.sram.mem_array[4],
            ex.sram.mem_array[5],
            ex.sram.mem_array[6],
            ex.sram.mem_array[7],
            ex.sram.mem_array[8],
            ex.sram.mem_array[9],
            ex.sram.mem_array[10]
        );
        $dumpvars(0, ni.instr_mem.mem_array[0], ni.instr_mem.mem_array[1]);
        $readmemh("bin/exec-test/exec_test.mem", ni.instr_mem.mem_array);
        $readmemh("src/exec_test_sram.mem", ex.sram.mem_array);
    end

    wire [31:0] f_instr;
    wire [31:0] f_pc;

    wire e_otp_rdy;
    wire i_otp_rdy;
    
    cpu_ifetch ni (
        .clk(clk), 
        .rst_n(rst_n), 
        .i_inp_rdy(e_otp_rdy),
        .i_otp_rdy(i_otp_rdy),
        .f_instr(f_instr), 
        .f_pc(f_pc)
    );

    exec ex (
        .clk(clk),
        .rst_n(rst_n),
        .e_inp_rdy(i_otp_rdy),
        .e_otp_rdy(e_otp_rdy),
        .f_instr(f_instr),
        .f_pc(f_pc)
    );

endmodule
