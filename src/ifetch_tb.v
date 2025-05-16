`timescale 1ns/1ns

module test;
  reg rst_n = 0;
  initial begin
     rst_n = 0;
     # 10 rst_n = 1;
     # 100 $finish;
  end

  initial begin
        $readmemh("src/ifetch_instr.mem", ni.instr_mem.mem_array);
        // $display("Instruction memory [12'h00]: %h", instruction_memory[12'h00]);
    end

  reg clk = 0;
  always #5 clk = !clk;

  reg i_inp_rdy = 1'b1;
  wire [31:0] f_instr;
  wire [31:0] f_pc;
  
  cpu_ifetch ni (
    .clk(clk), 
    .rst_n(rst_n), 
    .i_inp_rdy(i_inp_rdy),
    .i_otp_rdy(),
    .f_instr(f_instr), 
    .f_pc(f_pc)
  );

  initial begin
     $dumpfile("waveforms/ifetch-test/ifetch_test.vcd");
     $dumpvars(0,test);
  end

endmodule