module cpu_ifetch 
#(
    parameter RESET_VECTOR = 32'h0000_0000,
    parameter INSTR_MEM_ADDR_WIDTH = 10
)
(
    input wire clk, 
    input wire rst_n,
    output reg [31:0] f_instr, 
    output reg [31:0] f_pc
);  

    localparam INSTR_MEM_SIZE = 1 << INSTR_MEM_ADDR_WIDTH;

    reg [31:0] i_pc;
    reg [31:0] i_next_pc;
    reg [31:0] instr_mem [0:INSTR_MEM_SIZE-1];

    always @ (posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            i_pc <= 32'h0;
            f_instr <= 32'h13; // NOP
            f_pc <= 32'h0;
        end else begin
            i_pc <= i_next_pc;
            f_instr <= instr_mem[i_pc[INSTR_MEM_ADDR_WIDTH + 1:2]];
            f_pc <= i_pc;
        end
    end

    always @* begin
        i_next_pc = i_pc + 4;
    end

endmodule