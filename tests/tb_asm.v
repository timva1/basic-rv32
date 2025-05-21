`timescale 1ns/1ns

module test;

    reg rst_n = 0;
    initial begin
        # 10 rst_n = 1; // start in reset mode
        # 100000 $finish;
    end

    reg clk = 0; // 500MHz clock
    integer i, results_start;
    reg [1023:0] ram_out_filename;
    integer ram_out_file;

    always #1 begin 
        clk = !clk;
        if (halted) begin // exit sequence
            if ($value$plusargs("out=%s", ram_out_filename)) begin
                $display("outputting final sram");
                ram_out_file = $fopen(ram_out_filename, "w");
                for (i = 0; i < 1024; i = i + 1) begin
                    $fwrite(ram_out_file, "32'h%08x (32'd%10d)\n", ex.sram.mem_array[i], ex.sram.mem_array[i]);
                end
                $fclose(ram_out_file);
            end else begin
                $display("couldn't output final sram (no +out arg)");
            end

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
                ex.sram.mem_array[14] +
                ex.sram.mem_array[15] -
                1 ==
                ex.sram.mem_array[16]
                ) begin
                    $display("Success!!!!!");
                end else begin
                    $display("ERROR: the sum the tests minus 1 (32'h%h) does not match the reference value (32'h%h)",
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
                        ex.sram.mem_array[14] +
                        ex.sram.mem_array[15] -
                        1,
                        ex.sram.mem_array[16]
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

    wire [31:0] f_instr_next;
    wire [31:0] f_pc_next;
    wire e_valid;
    wire i_valid;
    wire jump_select;
    wire [31:0] e_pc_next;
    wire halted;
    wire i_clk_en;
    wire e_clk_en;

    ifetch ni (
        .clk(clk),
        .rst_n(rst_n),
        .e_pc_next(e_pc_next),
        .jump_select(jump_select),
        .e_valid(e_valid),
        .e_clk_en(e_clk_en),
        .i_clk_en(i_clk_en),
        .i_valid(i_valid),
        .f_instr_next(f_instr_next),
        .f_pc_next(f_pc_next)
    );

    exec ex (
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(i_valid),
        .f_instr_next(f_instr_next),
        .f_pc_next(f_pc_next),
        .i_clk_en(i_clk_en),
        .e_pc_next(e_pc_next),
        .halted(halted),
        .jump_select(jump_select),
        .e_valid(e_valid),
        .e_clk_en(e_clk_en)
    );

endmodule
