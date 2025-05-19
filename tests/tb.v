`timescale 1ns/1ns

module test;

    reg rst_n = 0;
    initial begin
        # 10 rst_n = 1; // start in reset mode
        # 1000 $finish;
    end

    reg clk = 0; // 500MHz clock
    integer i;
    always #1 begin 
        clk = !clk;
        if (halted) begin // exit sequence
            if (
                ex.sram.mem_array[0] +
                ex.sram.mem_array[1] +
                ex.sram.mem_array[2] +
                ex.sram.mem_array[3] +
                ex.sram.mem_array[4] +
                ex.sram.mem_array[5] +
                ex.sram.mem_array[6] +
                ex.sram.mem_array[7] +
                ex.sram.mem_array[8] +
                ex.sram.mem_array[9] +
                ex.sram.mem_array[10] +
                ex.sram.mem_array[11] +
                ex.sram.mem_array[12] +
                ex.sram.mem_array[13] +
                ex.sram.mem_array[14] ==
                ex.sram.mem_array[15] - 1
                ) begin
                    $display("Success");
                end else begin
                    $display("ERROR: the sum the tests (%d) does not match the reference value (%d)",
                        ex.sram.mem_array[0] +
                        ex.sram.mem_array[1] +
                        ex.sram.mem_array[2] +
                        ex.sram.mem_array[3] +
                        ex.sram.mem_array[4] +
                        ex.sram.mem_array[5] +
                        ex.sram.mem_array[6] +
                        ex.sram.mem_array[7] +
                        ex.sram.mem_array[8] +
                        ex.sram.mem_array[9] +
                        ex.sram.mem_array[10] +
                        ex.sram.mem_array[11] +
                        ex.sram.mem_array[12] +
                        ex.sram.mem_array[13] +
                        ex.sram.mem_array[14],
                        ex.sram.mem_array[15] - 1
                        );
                    $display("---------- diagnostic info ----------");
                    for (i = 0; i < 16; i = i + 1) begin
                        $display("sram[%d] = 32'h%h (%d)", i, ex.sram.mem_array[i], ex.sram.mem_array[i]);
                    end
                    $display("---------- --------------- ----------");
                end
            $finish;
        end
    end

    reg [1023:0] instr_filename;
    reg [1023:0] mem_filename;
    reg [1023:0] wave_filename;
    initial begin
        if (!$value$plusargs("instr=%s", instr_filename)) begin
            $display("ERROR: no instruction file ('isntr=' argument) given");
            $finish;
        end
        if (!$value$plusargs("mem=%s", mem_filename)) begin
            $display("ERROR: no memory file ('mem=' argument) given");
            $finish;
        end
        if (!$value$plusargs("wave=%s", wave_filename)) begin
            $display("ERROR: no waveform file ('wave=' argument) given");
            $finish;
        end

        $readmemh(instr_filename, ni.instr_mem.mem_array);
        $readmemh(mem_filename, ex.sram.mem_array);

        $dumpfile(wave_filename);
        $dumpvars(0, test);
    end

    wire [31:0] f_instr;
    wire [31:0] f_pc;

    wire e_otp_rdy;
    wire i_otp_rdy;
    wire e_j_flag;
    wire [31:0] e_pc_next;
    wire halted;
    
    cpu_ifetch ni (
        .clk(clk), 
        .rst_n(rst_n), 
        .e_pc_next(e_pc_next),
        .e_j_flag(e_j_flag),
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
        .f_pc(f_pc),
        .e_j_flag(e_j_flag),
        .e_pc_next(e_pc_next),
        .halted(halted)
    );

endmodule
